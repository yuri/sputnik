---------------------------------------------------------------------------------------------------
-- Provides an implementation of versium storage using the local file system.
---------------------------------------------------------------------------------------------------
module(..., package.seeall)
require("lfs")
local luaenv = require("versium.luaenv")

-- A template used for generating the index file.
INDEX_TEMPLATE=[[add_version{
 version   = %s,
 timestamp = %s,
 author    = %s,
 comment   = %s,%s
}
]]

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

SimpleVersiumStorage = {}

---------------------------------------------------------------------------------------------------
-- Instantiates a new SimpleVersiumStorage object.
-- 
-- @param impl           the implementation module.
-- @param params         the parameters to pass to the implementation.
-- @return               a new versium object.
---------------------------------------------------------------------------------------------------
function SimpleVersiumStorage.new(self, params, versium)
   local dir = params.dir
   local obj = {dir=dir, node_table={}, versium=versium}
   setmetatable(obj, self)
   self.__index = self
   for x in lfs.dir(dir) do
      if x:len() > 2 then
         obj.node_table[x] = 1
      end
   end
   return obj 
end

---------------------------------------------------------------------------------------------------
-- Returns a table representing the node with a given id.
--
-- @param version        the desired version of the node (defaults to current).
-- @return               the node as table with its content in node.data.
---------------------------------------------------------------------------------------------------
function SimpleVersiumStorage.get_node(self, id, version)
   local history = self:get_node_history(id) or {}
   if not history or #history == 0 then
      versium.storage_error(versium.errors.NODE_DOES_NOT_EXIST, tostring(id))
   end
   local node
   if version and tonumber(version) then
      node = history[#history-tonumber(version)+1]  -- version "0" is listed _last_ in history
   else
      node = history[1] -- i.e., the _latest_ version
   end
   assert(node.version) -- should come from history
   node.id = id
   node.data = _read_file(self.dir.."/"..id.."/"..node.version)
   return node
end

---------------------------------------------------------------------------------------------------
-- Returns a table representing a node that doesn't actually exist yet.
--
-- @return               the stub of the node as a table.
---------------------------------------------------------------------------------------------------
function SimpleVersiumStorage.get_stub(self, id)
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
function SimpleVersiumStorage.node_exists (self, id)
   assert(id)
   return self.node_table[id]
end

---------------------------------------------------------------------------------------------------
-- Returns a table with the metadata for the latest version of the node. Same as 
-- get_node_history(id)[1] in case of this implementation.
-- 
-- @param id             an id of an node.
-- @return               the metadata for the latest version or nil.
---------------------------------------------------------------------------------------------------
function SimpleVersiumStorage.get_node_info (self, id)
   assert(id)
   return self:get_node_history(id)[1]
end

---------------------------------------------------------------------------------------------------
-- Returns a list of IDs of all nodes in the repository, in no particular order.
-- 
-- @return               a list of IDs.
---------------------------------------------------------------------------------------------------
function SimpleVersiumStorage.get_node_ids (self)
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
function SimpleVersiumStorage.save_version (self, id, data, author, comment, extra)
   assert(id)
   assert(data)
   assert(author)
   local node_path = self.dir.."/"..id
   -- create a directory if necessary
   if not self:node_exists(id) then
      lfs.mkdir(node_path)
      self.node_table[id] = 1
   end
   -- load history, figure out what the new revision ID would be, write data to file
   local history, raw_history = self:get_node_history(id)
   local new_version_id = string.format("%06d", #history + 1)
   _write_file(node_path.."/"..new_version_id, data)
   -- generate and save the new index
   local t = os.date("*t")
   local timestamp = string.format("%02d-%02d-%02d %02d:%02d:%02d", 
                                   t.year, t.month, t.day, t.hour, t.min, t.sec)
   local extra_buffer = ""
   for k,v in pairs(extra or {}) do
      extra_buffer = extra_buffer.."\n "..k.."     = "..self.versium:longquote(v)..","
   end                                
   local new_history = string.format(INDEX_TEMPLATE, 
                                     self.versium:longquote(new_version_id),
                                     self.versium:longquote(timestamp),
                                     self.versium:longquote(author), 
                                     self.versium:longquote(comment),
                                     extra_buffer) 
   _write_file(self.dir.."/"..id.."/index", new_history..raw_history)

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
function SimpleVersiumStorage.get_node_history (self, id, prefix)
   assert(id)
   local raw_history = _read_file_if_exists(self.dir.."/"..id.."/index")
   local all_versions = {}
   luaenv.make_sandbox{add_version = function (values)
                                        table.insert(all_versions, values)
                                     end 
                       }.do_lua(raw_history)
   return all_versions, raw_history
end

---------------------------------------------------------------------------------------------------
-- Creates a new SimpleVersiumStorage object.
-- 
-- @param params         the parameters to pass to the implementation.
-- @param versium        a generic versium instance.
-- @return               the new versium storage object.
---------------------------------------------------------------------------------------------------

function open(params, versium)
   return SimpleVersiumStorage:new(params, versium)
end
