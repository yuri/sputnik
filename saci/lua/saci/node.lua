-----------------------------------------------------------------------------
-- Creates a representation of a single data "node" with support for
-- inheritance and field activation.
--
-- (c) 2007, 2008  Yuri Takhteyev (yuri@freewisdom.org)
-- License: MIT/X, see http://sputnik.freewisdom.org/en/License
-----------------------------------------------------------------------------

module(..., package.seeall)
require("saci.sandbox")
require("diff")

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
   local sandbox = saci.sandbox.new(repo.sandbox_values)
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
--                       args.id (the id of the node, required),
--                       args.repository (the saci instance, required)
--
-- @repository           the repository to which this Node belongs.
-- @return               an instance of "SputnikRepository".
-----------------------------------------------------------------------------
function new(args)
   local node = setmetatable({raw_values={}, inherited_values={}, active_values={}}, Node_mt)

   assert(args.data)
   assert(args.id)
   node.data = args.data
   node.id = args.id
   assert(args.repository)
   node.repository = args.repository

   node.raw_values = saci.sandbox.new():do_lua(args.data)
   assert(rawget(node, "raw_values"), "the sandbox should give us a table")

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
-- Inheritance rules: functions that determine what the node's value should
-- be based on it's prototype's value and it's own "raw" value.
-----------------------------------------------------------------------------

local inheritance_rules = {}

-- Concatenates the inherited value and own value, inserting an "\n" between
-- them.  Basically, this is what we need to be able to concatenate two
-- chunks of Lua code.
function inheritance_rules.concat(proto_value, own_value)
   local buf = ""
   if proto_value and proto_value:len() > 0 then
      buf = proto_value
   end
   if own_value and own_value:len() > 0 then
      if buf:len() > 0 then
         buf = buf.."\n"..own_value
      else
         buf = own_value
      end
   end
   return buf
end

-- A simpler inheritance rule that only uses the prototype's value if own
-- value is not defined.
function inheritance_rules.fallback(proto_value, own_value)
   return own_value or proto_value
end

inheritance_rules.default = inheritance_rules.fallback -- set a default

-----------------------------------------------------------------------------
-- Applies inheritance form page's prototype.  The inherited values are
-- stored in self.inherited_values.
-----------------------------------------------------------------------------
function Node:apply_inheritance()

   assert(self.id)
   -- If this node is itself the root prototype, then there is nothing else
   -- to do.
   if self.id == self.repository.root_prototype_id then
      self.inherited_values = self.raw_values
      return
   end
   if self.raw_values.prototype == "" then
      self.raw_values.prototype = nil  -- to make it easier to test for it
   end
   local prototype_id = self.raw_values.prototype or self.repository.root_prototype_id

   -- Get the values for the prototype.
   local proto_values = self.repository:get_node(prototype_id).inherited_values
   assert(proto_values.fields, "The prototype node must define fields")
 
   -- Apply inheritance from the prototype, using the information in the
   -- 'fields' field to decide how to handle each field.  

   -- First, we need to figure out what those fields are.  We use
   -- this node's own "fields" table rather than the fields table from the
   -- prototype and the value for fields must _always_ be inherited as a 
   -- matter of bootstrapping.
   
   local tmp_fields = inheritance_rules.concat(proto_values.fields,
                                               self.raw_values.fields)
   assert(tmp_fields)
   local fields, err = saci.sandbox.new{}:do_lua(tmp_fields)
   assert(fields, err)

   -- Now do the actual inheritance.  This means going through all fields
   -- and applying each of them the "inheritance rule" specified by the
   -- "proto" attribute.
   for field_name, field in pairs(fields) do
      field.name = field_name
      if field.proto then
         local inheritance_fn = inheritance_rules[field.proto]
                                or inheritance_rules.default
         self.inherited_values[field.name] = inheritance_fn(
                                                proto_values[field.name], 
                                                self.raw_values[field.name])   
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
   --assert(fields)
   -- First, update the raw values the new values (only those that are listed in fields!)
   for key, value in pairs(new_values) do
      if (not fields) or (fields[key] and not fields[key].virtual) then
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
         difftab[field] = diff.diff(tostring(another_node.raw_values[field]),
                                    tostring(self.raw_values[field]))
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
   author = author or ""
   self.repository:save_node(self, author, comment, extra)
end

-----------------------------------------------------------------------------
-- Returns a child node, if they are defined.
-- 
-- @param id             child's id.
-- @return               an instance of Node or nil.
-----------------------------------------------------------------------------
function Node:get_child(id)
   if self.child_defaults and self.child_defaults[id] then
      return self.repository:make_node(self.child_defaults[id], self.id.."/"..id)
   end
end
