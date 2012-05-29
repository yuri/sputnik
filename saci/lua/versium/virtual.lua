-----------------------------------------------------------------------------
-- Provides an implementation of non-persistent versium storage using Lua
-- tables that reside in memory.  This storage driver is provided primarily
-- for testing purposes.
-----------------------------------------------------------------------------

module(..., package.seeall)

VirtualVersiumStorage = {}

---------------------------------------------------------------------------------------------------
-- Instantiates a new VirtualVersiumStorage object.
-- 
-- @param impl           the implementation module.
-- @param params         the parameters to pass to the implementation.
-- @return               a new versium object.
---------------------------------------------------------------------------------------------------
function VirtualVersiumStorage:new(params, versium)
   local obj = {}
   setmetatable(obj, self)
   self.__index = self

   -- Establish the table used for node storage
   obj.store = {
      nodes = {},
      index = {},
   }
   return obj 
end

---------------------------------------------------------------------------------------------------
-- Returns a table representing the node with a given id.
--
-- @param id             the node id.
-- @param version        the desired version of the node (defaults to current).
-- @return               the node as table with its content in node.data.
---------------------------------------------------------------------------------------------------
function VirtualVersiumStorage:get_node(id, version)
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
   node.data = self.store.nodes[id][node.version]
   return node
end

---------------------------------------------------------------------------------------------------
-- Returns a table representing a node that doesn't actually exist yet.
--
-- @return               the stub of the node as a table.
---------------------------------------------------------------------------------------------------
function VirtualVersiumStorage:get_stub(id)
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
function VirtualVersiumStorage:node_exists(id)
   assert(id)
   return self.store.nodes[id] ~= nil
end

---------------------------------------------------------------------------------------------------
-- Returns a table with the metadata for the latest version of the node. Same as 
-- get_node_history(id)[1] in case of this implementation.
-- 
-- @param id             an id of an node.
-- @return               the metadata for the latest version or nil.
---------------------------------------------------------------------------------------------------
function VirtualVersiumStorage:get_node_info(id)
   assert(id)
   return self:get_node_history(id)[1]
end

---------------------------------------------------------------------------------------------------
-- Returns a list of IDs of all nodes in the repository, in no particular order.
-- 
-- @return               a list of IDs.
---------------------------------------------------------------------------------------------------
function VirtualVersiumStorage:get_node_ids()
   local ids = {} 
   for id, _ in pairs(self.store.nodes) do
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
function VirtualVersiumStorage:save_version(id, data, author, comment, extra, timestamp)
   assert(id)
   assert(data)
   assert(author)
   -- load history, figure out what the new revision ID would be, write data to file
   local history, raw_history = self:get_node_history(id)
   local new_version_id = string.format("%06d", #history + 1)

   if not self.store.nodes[id] then
      self.store.nodes[id] = {}
      self.store.index[id] = {}
   end

   self.store.nodes[id][new_version_id] = data

   -- generate and save the new index
   local t = os.date("*t")
   timestamp = timestamp or string.format("%02d-%02d-%02d %02d:%02d:%02d", 
                                          t.year, t.month, t.day, t.hour, t.min, t.sec)

   -- store the history in the index table by inserting it at the beginning
   table.insert(self.store.index[id], 1, {
      id = id,
      version = new_version_id,
      timestamp = timestamp,
      author = author,
      comment = comment,
   })

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
---------------------------------------------------------------------------------------------------
function VirtualVersiumStorage:get_node_history(id, prefix)
   assert(id)
   return self.store.index[id] or {}
end

---------------------------------------------------------------------------------------------------
-- Creates a new VirtualVersiumStorage object.
-- 
-- @param params         the parameters to pass to the implementation.
-- @param versium        a generic versium instance.
-- @return               the new versium storage object.
---------------------------------------------------------------------------------------------------

function open(params, versium)
   return VirtualVersiumStorage:new(params, versium)
end

-- vim:ts=3 ss=3 sw=3 expandtab
