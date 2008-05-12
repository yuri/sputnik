-----------------------------------------------------------------------------
-- Creates a representation of a single data "node" with support for
-- inheritance and field activation.
--
-- (c) 2007, 2008  Yuri Takhteyev (yuri@freewisdom.org)
-- License: MIT/X, see http://sputnik.freewisdom.org/en/License
-----------------------------------------------------------------------------

module(..., package.seeall)
require("saci.sandbox")

--x--------------------------------------------------------------------------
-- A table of functions used for "activating" fields, that is turning them
-- from strings into tables or functions.
-----------------------------------------------------------------------------
local Activators = {}

--x--------------------------------------------------------------------------
-- Turns Lua code into a table of values defined by that code.
--
-- @param value          Lua code as string.
-- @param repo           the Saci repository.
-- @return               the environment created by running the code.
-----------------------------------------------------------------------------

Activators.lua = function(value, repo) 
   local mt = {__index = repo.config}
   local config = setmetatable({}, mt)
   local sandbox = saci.sandbox.new(config)
   sandbox.logger = repo.logger
   return sandbox:do_lua(value)
end

--x--------------------------------------------------------------------------
-- Turns a list of tokens (e.g. node IDs) represented as one token per line
-- into a table of tokens.
--
-- @param value          a list of tokens as a \n-delimited string.
-- @param repo           The Saci repository.
-- @return               a table of tokens.
-----------------------------------------------------------------------------

Activators.list = function(value, repo)
   local nodes = {}
   for line in (value or ""):gmatch("[^%s]+") do
      table.insert(nodes, line)
   end
   return nodes
end



local Node = {}
local Node_mt = {
   __index = function(t,key)
                return t.active_values[key] or t.inherited_values[key]
                       or t.raw_values[key] or Node[key]
   end
}

-----------------------------------------------------------------------------
-- Creates a new instance of Node.  This is the only function this module 
-- exposes and the only one you should be using directly.  The instance that
-- this function returns has methods that can then be used to manipulate the
-- node.
-- 
-- @param args           a table arguments, including the following fields:
--                       args.data (the raw data for the node, required),
--                       args.metadata (the metadata for the node, required),
--                       args.id (the id of the node, required),
--                       args.repository (the saci instance, required)
--
-- @repository           the repository to which this Node belongs.
-- @return               an instance of "SputnikRepository".
-----------------------------------------------------------------------------
function new(args)
   local node = setmetatable({raw_values={}, inherited_values={}, active_values={}}, Node_mt)

   assert(args.data)
   assert(args.metadata)
   assert(args.id)
   node.data = args.data
   node.metadata = args.metadata
   node.id = args.id
   assert(args.repository)
   assert(args.root_prototype_id)
   node.repository = args.repository
   node.root_prototype_id = args.root_prototype_id

   node.raw_values = saci.sandbox.new():do_lua(args.data)
   assert(node.raw_values, "the sandbox should give us a table")

   node:apply_inheritance()
   node:activate()

   return node
end

---------------------------------------------------------------------------------------------------
-- Returns the edits to the node.
--
-- @param prefix         an optional date prefix (e.g., "2007-12").
-- @return               edits as a table.
---------------------------------------------------------------------------------------------------
function Node:get_history(prefix)
   return self.repository:get_node_history(self.id, prefix)
end
  
---------------------------------------------------------------------------------------------------
-- Returns the node as a string (used for debugging).
---------------------------------------------------------------------------------------------------
function Node:tostring()
   local buf = "================= "..self._id.." ========\n"
   for field, fieldinfo in pairs(self.fields) do
      buf = buf.."~~~~~~~ "..field.." ("..(fieldinfo.proto or "")..") ~~~~\n"
      buf = buf..(self._inactive[field] or "")
      buf = buf.."\n"
   end
   buf = buf.."~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n"
   return buf
end

-----------------------------------------------------------------------------
-- Applies inheritance form page's prototype.  The inherited values are
-- stored in self.inherited_values.
-----------------------------------------------------------------------------
function Node:apply_inheritance()

   -- If this is the ultimate prototype, then there is no further.
   assert(self.root_prototype_id)
   assert(self.id)
   if self.id == self.root_prototype_id then
      self.inherited_values = self.raw_values
      return
   end
   if (self.raw_values.prototype or ""):len() == 0 then
      self.raw_values.prototype = nil
   end

   local prototype_id = self.raw_values.prototype or self.root_prototype_id
   local proto_values = self.repository:get_node(prototype_id).inherited_values
   assert(proto_values.fields, "The prototype node must define fields")
 
   -- Apply inheritance from the prototype, using the information in the 'fields' field to decide 
   -- how to handle each field.  Note that we use this page's "fields" table rather than the fields
   -- table from the prototype. However, the "fields" field itself must _always_ be inherited as a 
   -- matter of bootstrapping.
   
   -- An auxilary function to concat field values.  Note that it inserts an extra "\n" between the values, 
   -- to make sure that we can contatenate stretches of Lua code.
   local function concat(x,y, verbose)
      if verbose then 
         print ("1<<"..(x or "-")..">>")
         print ("2<<"..(y or "-")..">>")
         print ("=<<"..(x or "") .. "\n" .. (y or "")..">>")
      end
      local buf = ""
      if x and x:len() > 0 then
         buf = x
      end
      if y and y:len() > 0 then
         if buf:len() > 0 then
            buf = buf.."\n"..y
         else
            buf = y
         end
      end
      return buf
   end

   local tmp_fields = concat(proto_values.fields, self.raw_values.fields)
   assert(tmp_fields)
   local fields, err = saci.sandbox.new{}:do_lua(tmp_fields)
   assert(fields, err)

   for field_name, field in pairs(fields) do
      field.name = field_name
      if field.proto then
         if field.proto == "concat" then
            self.inherited_values[field.name] =
               concat(proto_values[field.name], self.raw_values[field.name])    
         elseif field.proto == "fallback" then
            self.inherited_values[field.name] = 
               self.raw_values[field.name] or proto_values[field.name]
         end
      end
   end

end


---------------------------------------------------------------------------------------------------
-- Turns string parameters into Lua functions and tables, making them callable.
---------------------------------------------------------------------------------------------------
function Node:activate()
   self.active_values = {}
   local fields, err = saci.sandbox.new{}:do_lua(self.inherited_values.fields)
   if not fields then
      error(err)
   end

   for field, fieldinfo in pairs(fields) do
      if fieldinfo.activate then
         local activator_fn = Activators[fieldinfo.activate]
         local value = self[field] or ""
         self.active_values[field] = activator_fn(value, self.repository)
      end
   end
   return self
end

---------------------------------------------------------------------------------------------------
-- Updates the node with values.
--
-- @param new_values     a table of new values (keyed by field name).
-- @param fields         a table keyed by field name to allow us to filter the new values.
-- @return               nothing.
---------------------------------------------------------------------------------------------------
function Node:update(new_values, fields)
   assert(new_values)
   assert(fields)
   -- First, update the raw values the new values (only those that are listed in fields!)
   for key, value in pairs(new_values) do
      if fields[key] and not fields[key].virtual then
         self.raw_values[key] = value
      end
   end
   self:apply_inheritance()
   self:activate()

   -- Now make a new node, being careful to not get into recursive metatables
   --local vnode = self._vnode
   --setmetatable(self._inactive, {}) -- to avoid recursive metatables
   --local new_smart_node = new(vnode, self.repository, self.repository.config.ROOT_PROTOTYPE)
   -- Now make the current node a copy of the new one (copy the fields and the metatable
   --for k,v in pairs(new_smart_node) do
   --   self[k] = v
   --end
   --setmetatable(self, getmetatable(new_smart_node))
end

---------------------------------------------------------------------------------------------------
-- Returns a diff between this version of the node and some other one.
--
-- @param another_node   some other node
-- @return               diff as a table of tokens.
---------------------------------------------------------------------------------------------------
function Node:diff(another_node)
   local difftab  = {}
   for i, field in ipairs(self:get_ordered_field_names()) do
      if (self.raw_values[field] or "") ~= (another_node.raw_values[field] or "") then
         difftab[field] = versium.util.diff(tostring(self.raw_values[field]), 
                                       tostring(another_node.raw_values[field]))
      end
   end
   return difftab
end

-----------------------------------------------------------------------------
-- Returns the list of fields for this node, ordered according to their
-- weights.
-- 
-- @return               A table of fields.
-----------------------------------------------------------------------------
function Node:get_ordered_field_names()
   local ordered_fields = {}
   for k,v in pairs(self.fields) do
      table.insert(ordered_fields, k)
   end
   table.sort(ordered_fields, function(a,b) return (self.fields[a][1] or 0) < (self.fields[b][1] or 0) end)
   return ordered_fields
end


-----------------------------------------------------------------------------
-- Saves the node (using the data that's already in the node).
-- 
-- @param author         the author associated with the edit.
-- @param comment        a comment for the edit (optional).
-- @param extra          extra params (optional).
-- @return               nothing.
-----------------------------------------------------------------------------
function Node:save(author, comment, extra)
   assert(author)
   self.repository:save_node(self, author, comment, extra)
end

-----------------------------------------------------------------------------
-- Tells us whether this is ann outdated version of the node.
-- 
-- @return               true if the node is outdated, false if it's the most
--                       recent version _or_ the node has no history.
-----------------------------------------------------------------------------
function Node:is_old()
   assert(self.id)
   local history = self:get_history()
   if #history == 0 then 
      return false 
   else
      return history[1].version~=self.metadata.version
   end
end


-----------------------------------------------------------------------------
-- Returns a child node, if they are defined.
-- 
-- @param id             child's id.
-- @return               an instance of Node or nil.
-----------------------------------------------------------------------------
function Node:get_child(id)
   if self.child_defaults and self.child_defaults[id] then
      return self.repository:make_node(self.child_defaults[id], {}, self.id.."/"..id)
   end
end
