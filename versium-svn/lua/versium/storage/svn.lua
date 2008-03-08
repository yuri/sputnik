---------------------------------------------------------------------------------------------------
-- Provides an implementation of versium storage using Subversion.
---------------------------------------------------------------------------------------------------

module(..., package.seeall)
require("lfs")
require("svn")
local luaenv = require("versium.luaenv")


---------------------------------------------------------------------------------------------------
-- Opens a file "safely" (i.e., with error messages).
-- 
-- @param path           the file path.
-- @param mode           the access mode ("r", "w", "a", etc.)
-- @return               a file handle.
---------------------------------------------------------------------------------------------------
local function _open_file(path, mode, strict)
   assert(path)
   local f = io.open(path, mode)
   if (not f) and strict then
      versium.storage_error("File Versium: Can't open file: %s in mode %s", path, (mode or "r"))
   end
   return f
end

---------------------------------------------------------------------------------------------------
-- Writes data to a file (to be replaced with atomic write).
-- 
-- @param path           the file path.
-- @param data           data to be written to the file.
-- @return               nothing
---------------------------------------------------------------------------------------------------
local function _write_file(path, data)
   assert(path)
   assert(data)
   local f = _open_file(path, "w", true)
   f:write(data)
   f:close()
end

---------------------------------------------------------------------------------------------------
-- An auxiliary function for reading the content of a file.
-- 
-- @param path           the file path.
-- @return               the data read from the file as a string.
---------------------------------------------------------------------------------------------------
local function _read_file(path)
   assert(path)
   local f = _open_file(path, "r", true)
   local data = f:read("*all")
   f:close()
   return data
end

---------------------------------------------------------------------------------------------------
-- Reads data from a file without complaining if the file doesn't exist.
-- 
-- @param path           the file path.
-- @return               the data read from the file or "" if the file doesn't exist.
---------------------------------------------------------------------------------------------------
local function _read_file_if_exists(path)
   assert(path)
   local f = _open_file(path, "r", false)
   if f then
      local data = f:read("*all")
      f:close()
      return data
   else
      return ""
   end
end


---------------------------------------------------------------------------------------------------
-- Gets the last name of a path
-- 
-- @param path           a path like "/home/dir/file
-- @return               the name after the last "/"
---------------------------------------------------------------------------------------------------

local function fileName (path)
	local n = #path
	for i=n, 1, -1 do
		if string.sub (path, i, i) == '/' then
			return string.sub (path, i+1, n)
		end
	end

	return ""
end


---------------------------------------------------------------------------------------------------
-- Builds the node table
-- 
-- @param obj            a Versium object
-- @return               nothing
---------------------------------------------------------------------------------------------------

local function build_node_table (obj)
	local node_table = {}
	local wc = obj.wc

	--gets the list of the files
	local t = svn.list (wc)
	--number of the last revision
	local n = 0

	for file, r in pairs (t) do
		node_table[file] = {}
		if r > n then
			n = r
		end
	end

	--get the "versium:version" property of the files in each revision, so
	--we can associate the Versium revision number with the SVN revision number
	for i=n, 1, -1 do
		local prop = svn.propget (wc, "versium:version", i)
        for path, v in pairs (prop) do
			local s = loadstring ('return ' .. v) ()
			node_table [fileName (path)][s] = i
		end
	end

	obj.node_table = node_table


end



SVNVersiumStorage = {}

---------------------------------------------------------------------------------------------------
-- Instantiates a new SVNVersiumStorage object.
-- 
-- @param impl           the implementation module.
-- @param params         the parameters to pass to the implementation.
-- @return               a new versium object.
---------------------------------------------------------------------------------------------------
function SVNVersiumStorage:new(params, versium)
	local reposurl = params.reposurl
	local wc = params.wc
  	local obj = {reposurl=reposurl, node_table = {}, wc = wc, versium=versium}
  	svn.checkout (reposurl, wc)
	build_node_table (obj)
   setmetatable(obj, self)
	self.__index = self
	return obj         
end

---------------------------------------------------------------------------------------------------
-- Returns a table representing the node with a given id.
--
-- @param id             the node id.
-- @param version        the desired version of the node (defaults to current).
-- @return               the node as table with its content in node.data.
---------------------------------------------------------------------------------------------------
function SVNVersiumStorage:get_node(id, version)
	--did not understand the "OR" in "simple.lua'
 	local history = self:get_node_history(id) or {}
	if not history or #history == 0 then
      versium.storage_error(versium.errors.NODE_DOES_NOT_EXIST, tostring(id))
   end

   local node
   if version and tonumber(version) then
      node = history[#history-tonumber(version)+1]
   else
      node = history[1]
   end
	assert(node.version) -- should come from history
   node.id = id
   node.data = svn.cat (self.wc.."/"..id, self.node_table [id][version])
   return node
end

---------------------------------------------------------------------------------------------------
-- Returns a table representing a node that doesn't actually exist yet.
--
-- @return               the stub of the node as a table.
---------------------------------------------------------------------------------------------------
function SVNVersiumStorage:get_stub(id)
   return {
      version = "000000",
      data = "",
      id = id,
   }
end

---------------------------------------------------------------------------------------------------
-- Returns true if the node with this id exists and false otherwise.
-- 
-- @param id             an id of an node.
-- @return               true or false.
---------------------------------------------------------------------------------------------------
function SVNVersiumStorage:node_exists(id)
	assert(id)
	return self.node_table [id] ~= nil
end

---------------------------------------------------------------------------------------------------
-- Returns a table with the metadata for the latest version of the node. Same as 
-- get_node_history(id)[1] in case of this implementation.
-- 
-- @param id             an id of an node.
-- @return               the metadata for the latest version or nil.
---------------------------------------------------------------------------------------------------
function SVNVersiumStorage:get_node_info(id)
	assert(id)
	return self:get_node_history(id)[1]
end

---------------------------------------------------------------------------------------------------
-- Returns a list of IDs of all nodes in the repository, in no particular order.
-- 
-- @return               a list of IDs.
---------------------------------------------------------------------------------------------------
function SVNVersiumStorage:get_node_ids()
	local ids = {} 
   for id, _ in pairs(self.node_table) do
      ids[#ids+1] = id
   end
   return ids
end

---------------------------------------------------------------------------------------------------
-- Saves a new version of the node.
--
-- @param id             the id of the node (required).
-- @param data           the value to save (required, but "" is ok).
-- @param author         the user name to be associated with the change (required).
-- @param comment        the change comment (optional).
-- @param extra          any extra metadata (optional).
-- @return               the version id of the new node.
---------------------------------------------------------------------------------------------------
function SVNVersiumStorage:save_version(id, data, author, comment, extra, timestamp)
	assert(id)
   assert(data)
   assert(author)

	local node_path = self.wc.."/"..id
  
   _write_file(node_path, data)

   local history, raw_history
   local new_version_id

   -- adds the file to repository if necessary
   if not self:node_exists(id) then
	  svn.add (node_path)
	  new_version_id = string.format ("%06d", 1)
	  self.node_table [id] = {}
   else
     history, raw_history = self:get_node_history(id)
	  new_version_id = string.format("%06d", #history + 1)
   end

   local t = os.date("*t")
   local timestamp = string.format("%02d-%02d-%02d %02d:%02d:%02d", 
				   t.year, t.month, t.day,
				   t.hour, t.min, t.sec)


   local extra_buffer = ""
   for k,v in pairs(extra or {}) do
      extra_buffer = extra_buffer.."\n "..k.."     = "..self.versium:longquote(v)..","
   end
   svn.propset (node_path, "versium:version", self.versium:longquote (new_version_id))
   svn.propset (node_path, "versium:timestamp", self.versium:longquote (timestamp))
   svn.propset (node_path, "versium:author", self.versium:longquote (author))
   svn.propset (node_path, "versium:comment", self.versium:longquote (comment))
   svn.propset (node_path, "versium:comment", self.versium:longquote (comment))

   local rev = svn.commit (self.wc)
   
   self.node_table [id][new_version_id] = rev

   svn.update (self.wc)

   return new_version_id
end

---------------------------------------------------------------------------------------------------
-- Returns the history of the node as a list of tables, each representing a revision of the node 
-- (with fields like version, author, comment, and extra).  The version can be filtered by a time
-- prefix. Returns an empty table if the node does not exist.
--
-- @param id             the id of the node.
-- @param prefix         time prefix.
-- @return               two values: 
--                           (1) a list of tables representing the versions (the list will be empty
--                               if the node doesn't exist)
--                           (2) the raw prepresentation of nodes history (as lua code).
---------------------------------------------------------------------------------------------------
function SVNVersiumStorage:get_node_history(id, prefix)
	assert(id)
   
   	local raw_history = "" 
	
	if self.node_table [id] ~= nil then

   		local node_path = self.wc .. "/" .. id
   		local log = svn.log (node_path)
   
	    local t = {}
   		for k, _ in pairs (log) do
			t[#t+1] = k
		end
		table.sort (t)
	    for i, r in ipairs (t) do
        	local s = "add_version{"
	    	local prop = svn.proplist (node_path, r)
	  		prop = prop [self.reposurl .. "/" .. id]
	  		s = s .. "\n version = " .. prop ["versium:version"]
	  		s = s .. ",\n timestamp = " .. prop ["versium:timestamp"]
	  		s = s .. ",\n author = " .. prop ["versium:author"]
	  		s = s .. ",\n comment = " .. prop ["versium:comment"] .. ",\n}\n"
	  		raw_history = s .. raw_history
   		end
	end

   local all_versions = {}

   	luaenv.make_sandbox{add_version = function (values)
                                        table.insert(all_versions, values)
                                     end 
                       }.do_lua(raw_history)

   return all_versions, raw_history
end

---------------------------------------------------------------------------------------------------
-- Creates a new SVNVersiumStorage object.
-- 
-- @param params         the parameters to pass to the implementation.
-- @param versium        a generic versium instance.
-- @return               the new versium storage object.
---------------------------------------------------------------------------------------------------

function open(params, versium)
   return SVNVersiumStorage:new(params, versium)
end



