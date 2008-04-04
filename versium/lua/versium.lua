module(..., package.seeall)

---------------------------------------------------------------------------------------------------
-- <b>Implements core Versium functionality</b> (just versioned storage).                        --
---------------------------------------------------------------------------------------------------


require("versium.util")

local Versium = {}
local Versium_mt = {__metatable = {}, __index = Versium}

---------------------------------------------------------------------------------------------------
-- Instantiates a new Versium object.
-- 
-- @param args           the arguments (with the name implementation module as args.storage and the
--                       the parameters to pass to the implementation module as args.params).
-- @return               a new versium object.
---------------------------------------------------------------------------------------------------
function new(args)
   local obj = setmetatable({}, Versium_mt)

   local storage_mod = require(args.storage or "versium.storage.simple")
   obj.storage = storage_mod.open(args.params, obj)
   return obj 
end


---------------------------------------------------------------------------------------------------
-- Returns a table representing the node with a given id.
--
-- @param id             the id of the desired node.
-- @param version        the desired version of the node (defaults to latest).
-- @return               the node as a table with its data in node.data.
---------------------------------------------------------------------------------------------------
function Versium:get_node(id, version)
   assert(id and id:len() > 0)
   if not self:node_exists(id) then
      return nil
   end
   local node = self.storage:get_node(self:escape_id(id), version)
   node.id = self:unescape_id(node.id)
   assert(node.data)
   assert(node.id)
   assert(node.version)
   return node
end

---------------------------------------------------------------------------------------------------
-- Returns a table representing a node that doesn't actually exist yet.
--
-- @param id             the id of the desired node.
-- @return               the node stub as a string.
---------------------------------------------------------------------------------------------------
function Versium:get_stub(id)
   assert(id and id:len() > 0)
   local node = self.storage:get_stub(self:escape_id(id))
   node.id = self:unescape_id(node.id)
   assert(node.data)
   assert(node.id)
   assert(node.version)
   return node   
end

---------------------------------------------------------------------------------------------------
-- Returns true if the node exists and false otherwise.
-- 
-- @param id             an id of an node.
-- @return               true or false.
---------------------------------------------------------------------------------------------------
function Versium:node_exists(id)
   assert(id and id:len() > 0)
   return self.storage:node_exists(self:escape_id(id))
end

---------------------------------------------------------------------------------------------------
-- Returns a table with the metadata for the latest version of the node, same as get_history(id)[1] 
-- but potentially cheaper.  If the node doesn't exist, "nil" is returned.
-- 
-- @param id             an id of an node.
-- @return               the metadata for the latest version or nil.
---------------------------------------------------------------------------------------------------
function Versium:get_node_info(id)
   assert(id and id:len() > 0)
   return self.storage:get_node_info(self:escape_id(id))
end

---------------------------------------------------------------------------------------------------
-- Lists ids for all existing nodes.
--
-- @param args.prefix    a prefix to be used for filtering nodes
-- @return               a list of IDs.
---------------------------------------------------------------------------------------------------
function Versium:get_node_ids(args)
   local ids = {}
   local args = args or {}
   args.prefix = args.prefix or ""
   local preflen = args.prefix:len()
   local id
   for i, v in ipairs(self.storage:get_node_ids(args)) do
      id = self:unescape_id(v)
      if id:sub(1, preflen) == args.prefix then
         table.insert(ids, id)
      end
   end
   return ids
end

---------------------------------------------------------------------------------------------------
-- Saves a new version of the node (or throws an error).
--
-- @param id             the id of the node (required).
-- @param data           the value to save (required, but "" is ok).
-- @param author         the user name to be associated with the change (required).
-- @param comment        the change comment (optional).
-- @param extra          any extra metadata (optional, depends on the storage module).
-- @param timestamp      the timestamp to use when saving the revision (optional).
-- @return               the version of ID of the new node.
---------------------------------------------------------------------------------------------------
function Versium:save_version(id, data, author, comment, extra, timestamp)
   assert(id and id:len() > 0)
   assert(data, "empty string is ok, but nil is not")
   assert(author and author:len() > 0, "author is required")
   -- comment and extra params are optional
   return self.storage:save_version(self:escape_id(id), data, author, comment, extra, timestamp)
end

---------------------------------------------------------------------------------------------------
-- Returns the history of the node as a list of tables, each representing a revision of the node 
-- (with fields like version, author, comment, and extra).  The version can be filtered by a time
-- prefix.  Returns an empty table if the node does not exist.
--
-- @param id             the id of the node.
-- @param prefix         time prefix (e.g., "2007-12", optional).
-- @return               a list of tables representing the versions (the list will be empty if the 
--                       node doesn't exist).
---------------------------------------------------------------------------------------------------
function Versium:get_node_history (id, prefix)
   assert(id and id:len() > 0) -- prefix is optional though
   return self.storage:get_node_history(self:escape_id(id), prefix)
end



---------------------------------------------------------------------------------------------------
-- Escapes a node id to make it safe for use as a file name.
-- 
-- @param id             a node id.
-- @return               an escaped node id.
---------------------------------------------------------------------------------------------------
function Versium:escape_id(id)
   assert(id and id:len() > 0)
   return id:gsub("%%", "%%25"):gsub(":", "%%3A"):gsub("/", "%%2F")
end


---------------------------------------------------------------------------------------------------
-- Un-escapes a node id. (See escape_id().)
-- 
-- @param id             an escaped node id.
-- @return               the original node id.
---------------------------------------------------------------------------------------------------
function Versium:unescape_id(id)
   assert(id and id:len() > 0)
   return id:gsub("%%2F", "/"):gsub("%%3A", ":"):gsub("%%25", "%%")
end

errors = {
   NODE_DOES_NOT_EXIST = "Node does not exit: %s"
}

---------------------------------------------------------------------------------------------------
-- Throws an error coming from a storage module.
--  
-- @param error_message  the error message.
-- @param ...            error-specific additional parameters.
-- @return               nothing (an error will be thrown).
---------------------------------------------------------------------------------------------------
function storage_error(error_message, ...)
   error ("Versium storage error: " .. string.format(error_message, ...))
end
