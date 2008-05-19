-----------------------------------------------------------------------------
-- Defines a class for a document-to-table mapper on top of Versium.
--
--
-- (c) 2007, 2008  Yuri Takhteyev (yuri@freewisdom.org)
-- License: MIT/X, see http://sputnik.freewisdom.org/en/License
-----------------------------------------------------------------------------

module(..., package.seeall)

require("saci.node")
local Saci = {}
local Saci_mt = {__metatable={}, __index=Saci}

-----------------------------------------------------------------------------
-- Creates a new instance of Saci.
-- 
-- @param module_name    versium module name to use for storage.
-- @param versium_params parameters to use when creating the storage module
--                       instance.
-- @param root_prototype [optional] the id of the node to be used as the root
--                       prototype (defaults to "@Root").
-- @return               an instance of "Saci".
-----------------------------------------------------------------------------
function new(module_name, versium_params, root_prototype_id)
   local repo = setmetatable({}, Saci_mt)
   repo.root_prototype_id = root_prototype_id or "@Root"
   assert(module_name)
   module_name = module_name
   local versium_module = require(module_name)
   repo.versium = versium_module.new(versium_params)
   return repo
end

-----------------------------------------------------------------------------
-- Returns true if the node exists and false otherwise.
-- 
-- @param id             an id of an node.
-- @return               true or false.
-----------------------------------------------------------------------------
function Saci:node_exists(id)
   return self.versium:node_exists(id)
end

-----------------------------------------------------------------------------
-- Turns a node represented as a Lua table into a string representation which
-- could later be inflated again.
--
-- @param node           A versium node as a table.
-- @return               The string representation of the versium node.
-----------------------------------------------------------------------------
function Saci:deflate(node)
   local buffer = ""
   for k,v in pairs(node) do
      if k~="__index" then
         buffer = buffer.."\n "..k.."= "..string.format("%q", tostring(v))
      end
   end
   return buffer
end

-----------------------------------------------------------------------------
-- Retrieves data from Versium and creates a Saci node from it.  If Versium
-- returns nil then Saci will check if it has a method get_fallback_node()
-- (which must be set by the client) and will use it to retrieve a fallback
-- node if it is defined.  If not, it will just return nil.
--
-- @param id             the id of the desired node.
-- @param version        the desired version of the node (defaults to latest).
-- @return               (1) a newly created instance of saci.node.Node,
--                       (2) 'true' if the node returned is a stub (nil
--                           otherwise).
-----------------------------------------------------------------------------
function Saci:get_node(id, version)
   assert(id)
   assert(type(id)=="string")

   -- first check if the id has a slash.  if so, identify the parent, and ask
   -- it about the child.
   local parent_id, rest = string.match(id, "^(.+)/(.-)$")
   if parent_id then
      local parent = self:get_node(parent_id)
      if parent then
         local node = parent:get_child(rest)
         if node then
            return node
         end
      end
   end

   -- ok, either we've got an atomic node, or the parent doesn't exist, or
   -- the parent didn't give us anything.  proceed to the normal method.
   local data = self.versium:get_node(id, version)
   if data then
      return self:make_node(data, id)
   end

   -- no luck, check if we have a fallback function
   if self.get_fallback_node then
      local prototype = nil
      local node, stub = self:get_fallback_node(id, version)
      return node, stub
   end
end

-----------------------------------------------------------------------------
-- Returns revision information for the specified version of the node with a
-- given id, or for the latest version.
--
-- @param id             the id of the desired node
-- @param version        [optional] the id of the revision that we want to
--                       know about (defaults to latest version).
-- @return               a table with revision metadata, just like versium's
--                       get_node_info()
-----------------------------------------------------------------------------
function Saci:get_node_info(id, version)
   return self.versium:get_node_info(id, version)
end

-----------------------------------------------------------------------------
-- Creates a node from a data string.
--
-- @param data           data for the node
-- @param id             the id of the desired node
-- @return               the version tag for the latest version of the node
-----------------------------------------------------------------------------
function Saci:make_node(data, id)
   return saci.node.new{data=data, id=id, repository=self}   
end

-----------------------------------------------------------------------------
-- Saves a node.
--
-- @param node           the node to be saved.
-- @param author         the .user name associated with the change (required).
-- @param comment        a comment associated with this change (optional).
-- @param extra          extra params (optional).
-- @return               nothing
-----------------------------------------------------------------------------
function Saci:save_node(node, author, comment, extra)
   assert(node.id)
   self.versium:save_version(node.id, self:deflate(node.raw_values), author,
                             comment, extra)
end

-----------------------------------------------------------------------------
-- Returns the history of edits to the node, optionally filtered by time
-- prefix (e.g., "2007-12") and/or capped at a certain number.
--
-- @param id             the id of the node.
-- @param prefix         [optional] a date prefix (e.g., "2007-12").
-- @param limit          [optional] a maxium number of records to return.
-- @return               history as a table.
-----------------------------------------------------------------------------
function Saci:get_node_history(id, prefix, limit)
   assert(id)
   local versium_history = self.versium:get_node_history(id, prefix, limit)
   for i,v in ipairs(versium_history) do
      v.get_node = function() self:get_node(id, v.version) end
   end
   return versium_history
end

-----------------------------------------------------------------------------
-- Retrieves multiple data nodes from Versium and retuns Saci nodes created
-- from them.  If Versium returns an empty table, then Saci will also return
-- an empty table.  This function always returns the most recent version of 
-- each node
--
-- @param prefix         the desired node prefix
-- @return               a table containing the returned Saci nodes, indexed
--                       by node name.
-----------------------------------------------------------------------------
function Saci:get_nodes_prefix(prefix)
   -- Only allow this when the versium repository has the get_nodes_prefix
   -- capability
   if not self.versium.capabilities.get_nodes_prefix then
      return {}
   end

   assert(prefix)

   -- Fetch the data from versium, for the given prefix
   local data = self.versium:get_nodes_prefix(prefix)
   local nodes = {}

   if next(data) then
      -- There are some nodes to process, so process them
      for id in pairs(data) do
         nodes[id] = self:make_node(data[id], id)
      end
   end

   return nodes
end

-- vim:ts=3 ss=3 sw=3 expandtab
