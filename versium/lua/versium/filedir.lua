-----------------------------------------------------------------------------
-- Implements Versium API using using the local file system for storage.
--
-- (c) 2007, 2008  Yuri Takhteyev (yuri@freewisdom.org)
-- License: MIT/X, see http://sputnik.freewisdom.org/en/License
-----------------------------------------------------------------------------

module(..., package.seeall)
require("lfs")
local util = require("versium.util")
local errors = require("versium.errors")

-----------------------------------------------------------------------------
-- A table that describes what this versium implementation can and cannot do.
-----------------------------------------------------------------------------
capabilities = {
   can_save = true,
   has_history = true,
   is_persistent = true,
   supports_extra_fields = true,
}


-- A template used for generating the index file.
local INDEX_TEMPLATE=[[add_version{
version   = %q,
timestamp = %q,
author    = %q,
comment   = %q,%s
}
]]

-----------------------------------------------------------------------------
-- A table representing the class.
-----------------------------------------------------------------------------
local FileDirVersium = {}

-- And it's metatable
local FileDirVersium_mt = {__metatable={}, __index=FileDirVersium}

-----------------------------------------------------------------------------
-- Instantiates a new FileDirVersium object that represents a connection to
-- a storage system.  This is the only function that this module exports.
-- 
-- @param params         a table of parameters (we'll be using param.dir as
--                       the storage directory).
-- @return               a new versium object.
-----------------------------------------------------------------------------
function new(params)
   assert(params.dir, "parameter 'dir' is required")
   local new_versium = {dir=params.dir, node_table={}}
   local new_versium = setmetatable(new_versium, FileDirVersium_mt)
   for x in lfs.dir(params.dir) do
      if x:len() > 2 then
         new_versium.node_table[util.fs_unescape_id(x)] = 1
      end
   end
   return new_versium 
end

-----------------------------------------------------------------------------
-- Returns the data stored in the node as a string and a table representing
-- the node's metadata.  Returns nil if the node doesn't exist.  Throws an
-- error if anything else goes wrong.
--
-- @param id             a node id.
-- @param version        [optional] the desired version of the node (defaults
--                       to current).
-- @return               a byte-string representing the data stored in the
--                       node or nil if the node could not be loaded or nil.
-- @return               a table representing the metadata, including the
--                       following fields (see get_node_history()) or nil.
-- @see get_node_history
-----------------------------------------------------------------------------
function FileDirVersium:get_node(id, version)
   assert(id)
   if not self:node_exists(id) then
      return nil
   end
   local history = self:get_node_history(id) or {}
   assert(#history > 0, "History should have at least one item in it")

   local metadata
   if version and tonumber(version) then
      -- version N is listed as N-latest
      metadata = history[#history-tonumber(version)+1]
   else
      metadata = history[1] -- i.e., the _latest_ version
   end
   assert(metadata.version) -- should come from history
   local path = self.dir.."/"..util.fs_escape_id(id).."/"..metadata.version
   local data = util.read_file(path, id)
   assert(data)
   return data, metadata
end

-----------------------------------------------------------------------------
-- Returns true if the node with this id exists and false otherwise.
-- 
-- @param id             a node id.
-- @return               true or false.
-----------------------------------------------------------------------------
function FileDirVersium:node_exists(id)
   return self.node_table[id] ~= nil
end

-----------------------------------------------------------------------------
-- Returns a table with the metadata for the latest version of the node. Same
-- as get_node_history(id)[1] in case of this implementation.
-- 
-- @param id             a node id.
-- @return               the metadata for the latest version (see 
--                       get_node_history()).
-- @see get_node_history
-----------------------------------------------------------------------------
function FileDirVersium:get_node_info(id)
   assert(id)
   return self:get_node_history(id)[1]
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
function FileDirVersium:get_node_ids(prefix, limit)
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
function FileDirVersium:save_version(id, data, author, comment, extra, timestamp)
   assert(id)
   assert(data)
   assert(author)
   local node_path = self.dir.."/"..util.fs_escape_id(id)
   -- create a directory if necessary
   if not self:node_exists(id) then
      lfs.mkdir(node_path)
      self.node_table[id] = 1
   end
   -- load history, figure out the new revision ID, write data to file
   local raw_history = get_raw_history(self.dir, id)
   local history = parse_raw_history(raw_history)
   local new_version_id = string.format("%06d", #history + 1)
   util.write_file(node_path.."/"..new_version_id, data, id)
   -- generate and save the new index
   local t = os.date("*t")
   timestamp = timestamp or string.format("%02d-%02d-%02d %02d:%02d:%02d", 
                                          t.year, t.month, t.day, t.hour, t.min, t.sec)
   local extra_buffer = ""
   for k,v in pairs(extra or {}) do
      extra_buffer = extra_buffer..string.format("\n [%q] = %q, ", k, v)
   end                                
   local new_history = string.format(INDEX_TEMPLATE, 
                                     new_version_id, timestamp, author, 
                                     comment, extra_buffer) 
   util.write_file(self.dir.."/"..util.fs_escape_id(id).."/index", new_history..raw_history, id)

   return new_version_id
end

--x--------------------------------------------------------------------------
-- Returns the raw history of the node from the given directory.
------------------------------------------------------------------------------
local function get_raw_history(dir, id)
   local path = dir.."/"..util.fs_escape_id(id).."/index"
   local raw_history = util.read_file_if_exists(path)
   return raw_history
end

--x--------------------------------------------------------------------------
-- Parses raw history file into a table, filters by timestamp prefix.
-----------------------------------------------------------------------------
local function parse_history(raw_history, prefix, limit)
   local all_versions = {}
   local more
   prefix = "" --prefix or ""
   local preflen = prefix:len()
   local counter = 0
   local f = loadstring(raw_history)
   local environment = {
      add_version = function (values)
                       if values.timestamp:sub(1, preflen) == prefix then
                          if counter == limit then
                             more = true
                          else 
                             table.insert(all_versions, values)
                             counter = counter + 1
                          end
                       end
                    end 
   }
   setfenv(f, environment)
   f()
   return all_versions
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
function FileDirVersium:get_node_history(id, prefix)
   assert(id)
   if not self:node_exists(id) then return nil end

   local raw_history = get_raw_history(self.dir, id)
   assert(raw_history:len() > 0)
   local history = parse_history(raw_history, prefix)
   return history
end

