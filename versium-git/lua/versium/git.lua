-----------------------------------------------------------------------------
-- Implements Versium API using git as the backend.
--
-- (c) 2007, 2008  Yuri Takhteyev (yuri@freewisdom.org)
-- License: MIT/X, see http://sputnik.freewisdom.org/en/License
-----------------------------------------------------------------------------

module(..., package.seeall)
require("lfs")

local util = require("versium.util")
local errors = require("versium.errors")

-----------------------------------------------------------------------------
-- A table that describes what this versium implementation can do.
-----------------------------------------------------------------------------
capabilities = {
   can_save = true,
   has_history = true,
   is_persistent = true,
   supports_extra_fields = true,
}

-----------------------------------------------------------------------------
-- A table representing the class and it's metatable.
-----------------------------------------------------------------------------
local GitVersium = {}
local GitVersium_mt = {__metatable={}, __index=GitVersium}

-----------------------------------------------------------------------------
-- Instantiates a new GitVersium object that represents access to
-- a storage system.  This is the only function that this module exports.
-- 
-- @param params         a table of params; we expect to find as the first
--                       entry the path to the directory where we'll be
--                       storing the data, and optionally the command to use
--                       for calling git (params.git_command).
-- @return               a new versium object.
-----------------------------------------------------------------------------
function new(params)
   assert(params[1], "the first parameter is required")
   -- Make a table of existing nodes.  Note that since we do this only in the
   -- beginning and only update it later with nodes that we create, we won't
   -- pick up any new nodes that were created bypassing this instance.
   local node_table = {}
   local file_extension = params.file_extension or ".lua"
   local git_dir = params[1]
   local function make_node_list(dir)
      for filename in lfs.dir(git_dir..dir) do
         local path = dir..filename
         local len = path:len()
         if filename:sub(filename:len()-3) == file_extension then
            node_table[util.fs_unescape_id(path:sub(1, path:len()-4))] = 1
         elseif filename:sub(1,1)~="." and lfs.attributes(git_dir..path).mode == "directory" then
            make_node_list(path.."/")
         end
      end
   end
   make_node_list("")
   local new_versium = { dir=git_dir, node_table=node_table,
                         git_command=params.command or "git",
                         file_extension=file_extension }
   return setmetatable(new_versium, GitVersium_mt)
end

--x--------------------------------------------------------------------------
-- Runs a git command in current directory.
--
-- @param ...            Any number of strings, which are concatenated with
--                       spaces between them and attached to the git command.
-- @return               The string returned by git on stdout.
-----------------------------------------------------------------------------
function GitVersium:git(...)
   lfs.chdir(self.dir)
   local command = self.git_command.." "..table.concat({...}, " ")
   -- note that if the command files, the error will go to the error stream,
   -- we won't see it.  all we'll know is that we will get "" when reading
   -- the output.
   local pipe = io.popen(command)
   local output = pipe:read("*all")
   pipe:close()
   return output
end

--x--------------------------------------------------------------------------
-- Returns the path to the file that stores the node with this id.
--
-- @param id             a node id.
-- @return               the path relative to the git repository root.
-----------------------------------------------------------------------------

function GitVersium:id2path(id)
   return util.fs_escape_id_but_keep_slash(id)..self.file_extension
end

--x--------------------------------------------------------------------------
-- Creates all directories that form the given path.
--
-- @param path           a file path (relative to self.dir).
-----------------------------------------------------------------------------

function GitVersium:make_path(path)
   local ready_path=self.dir
   for dir in path:gmatch("([^/]*)/") do
      ready_path = ready_path.."/"..dir
      pcall(lfs.mkdir, ready_path)
   end
end

-----------------------------------------------------------------------------
-- Returns the data stored in the node as a string and a table representing
-- the node's metadata.  Returns nil if the node doesn't exist.  Throws an
-- error if anything else goes wrong.
--
-- @param id             a node id.
-- @param version        [optional] the desired version of the node (defaults
--                       to latest).
-- @return               a byte-string representing the data stored in the
--                       node or nil if the node could not be loaded or nil.
-- @see get_node_history
-----------------------------------------------------------------------------
function GitVersium:get_node(id, version)
   assert(id)
   if not self:node_exists(id) then
      return nil
   end
   if version then
      return self:git("show", version..":"..self:id2path(id))
   else
      local data = util.read_file(self.dir.."/"..self:id2path(id), id)
      assert(data)
      return data
   end
end

-----------------------------------------------------------------------------
-- Returns true if the node with this id exists and false otherwise.
-- 
-- @param id             a node id.
-- @return               true or false.
-----------------------------------------------------------------------------
function GitVersium:node_exists(id)
   return self.node_table[id] ~= nil
end

-----------------------------------------------------------------------------
-- Returns a table with the metadata for the latest version of the node. Same
-- as get_node_history(id)[1] in case of this implementation.
-- 
-- @param id             a node id.
-- @param version        [optional] the desired version of the node (defaults
--                       to latest).
-- @return               the metadata for the latest version (see 
--                       get_node_history()).
-- @see get_node_history
-----------------------------------------------------------------------------
function GitVersium:get_node_info(id, version)
   assert(id)
   local history = self:get_node_history(id) or {}
   assert(#history > 0, "History should have at least one item in it")

   if version then
      for i, commit in ipairs(history) do
         if commit.version == version then
            return commit
         end
      end
   else
      return history[1] -- i.e., the _latest_ version
   end
end

-----------------------------------------------------------------------------
-- Returns a list of existing node ids, up to a certain limit.  (If no limit
-- is specified, all ids are returned.)  The ids can be optionally filtered
-- by prefix.  (In this case, the limit applies to the number of ids that
-- are being _returned_.)  The ids can be returned in any order.
--
-- @param prefix         [optional] a prefix to filter the ids (defaults to
--                       "").
-- @param limit          [optional] the maximum number of ids to return.
-- @return               a list of node ids.
-- @return               true if there are more ids left.
-----------------------------------------------------------------------------
function GitVersium:get_node_ids(prefix, limit)
   local ids = {}
   local counter = 0
   prefix = prefix or ""
   local preflen = prefix:len()
   for id, _ in pairs(self.node_table) do
      if id:sub(1, preflen) == prefix then
         if counter == limit then
            return ids, true
         else
            table.insert(ids, id)
            counter = counter + 1
         end
      end
   end
   return ids
end

-----------------------------------------------------------------------------
-- Saves a new version of the node.
--
-- @param id             the id of the node.
-- @param data           the value to save ("" is ok).
-- @param author         the user name to be associated with the change.
-- @param comment        [optional] the change comment.
-- @param extra          [optional] a table of additional metadata.
-- @param timestamp      [optional] a timestamp to use.
-- @return               the version id of the new node.
-----------------------------------------------------------------------------
function GitVersium:save_version(id, data, author, comment, extra, timestamp)
   assert(id)
   assert(data)
   assert(author)
   -- write
   local path = self:id2path(id)
   self:make_path(path)
   util.write_file(self.dir.."/"..path, data, id)

   if comment=="" or comment==nil then
      comment = "(no comment)"
   end
   if extra then
      comment = comment.."\n\n---extra-fields-------------------------\n"
      for k, v in pairs(extra) do
         comment = comment..string.format("%s=%q\n", k, v)
      end
   end
   local tmp_file=os.tmpname()
   util.write_file(tmp_file, comment, id)

   -- commit
   if author=="" then
      author = "anonymous" 
   end
   author = author.." <"..author.."@sputnik>"

   self:git("add", path)
   local message = self:git("commit", "-F ", tmp_file, 
                                   string.format("--author %q", author))
   self.node_table[id] = 1
   if message:sub(1,14) == "Created commit" then
      return message:sub(15,22)
   else
      return nil, message
   end
end

-----------------------------------------------------------------------------
-- Returns the history of the node as a list of tables.  Each table
-- represents a revision of the node and has the following fields:
-- "version" (the id of the revision), "author" (the author who made the
-- revision), "comment" (the comment attached to the revision or nil), 
-- "extra" (a table of additional fields or nil).  The history can be
-- filtered by a time prefix.  Returns an empty table if the node does not
-- exist.
--
-- @param id             the id of the node.
-- @param prefix         time prefix.
-- @return               a list of tables representing the versions (the list
--                       will be empty if the node doesn't exist).
-----------------------------------------------------------------------------
function GitVersium:get_node_history(id, prefix)
   assert(id)
   if not self:node_exists(id) then return nil end
   local path = self:id2path(id)
   local comments_and_names = self:git("log", '--pretty=format:"%ae %s"', path)
   -- use comments and names to decide what's the longest string of =='s.
   local max_eqs = ""
   for eqs in comments_and_names:gmatch("(=+)") do
      if eqs:len() > max_eqs:len() then
         max_eqs = eqs
      end
   end
   local format = '--pretty=format:"'.."table.insert(commits, "
                     .."{version='%h', timestamp='%ct', author='%ae',"
                     .." comment=["..max_eqs.."=[%s%n%n%b]="..max_eqs.."]})"
                     ..'"'
   local history_as_lua = "commits = {}\n"
                          ..self:git("log", format, path)
                          .."\nreturn commits"

   local history = loadstring(history_as_lua)()
   local divider="^(.*)%-%-%-extra%-fields%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-(.*)$"
   for i, commit in ipairs(history) do
      commit.comment = commit.comment:gsub("\n\n<unknown>$", "")
      local before, after = commit.comment:match(divider)
      if before then
         commit.comment = before
         commit.timestamp = os.date("!%Y-%m-%d %H:%M:%S", commit.timestamp)
         local f, err=loadstring(after)
         if err then return nil, err end
         setfenv(f, {})
         pcall(f)
         for k,v in pairs(getfenv(f)) do
            commit[k] = v
         end
      end

      commit.author = commit.author:gsub("@sputnik$", "")
      if commit.author == "anonymous" then
         commit.author = ""
      end
   end
   return history
end

