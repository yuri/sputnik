---------------------------------------------------------------------------------------------------
-- <b>A fancy version of a Versium node that supports inheritance and field activation.</b>
---------------------------------------------------------------------------------------------------

module(..., package.seeall)
require("versium.luaenv")

local Activators = {}
Activators.lua = function(value, repo)
   local mt = setmetatable({__index=repo.config}, repo.config)   
   local config = setmetatable({}, mt)
   
   return versium.luaenv.make_sandbox(config).do_lua(value)
end
Activators.node_list = function(value, repo)
   local nodes = {}
   for line in (value or ""):gmatch("[^%s]+") do
      table.insert(nodes, line)
   end
   return nodes
end

local SmartNode = {}
local SmartNode_mt = { __index = SmartNode}

-----------------------------------------------------------------------------
-- Creates a new instance of SmartNode.  This is the only function this
-- module exposes and the only one you should be using directly.  Returns an
-- instance which has methods to do more fun stuff.
-- 
-- @param versium_node   an inflated versium node.
-- @repository           the repository to which this SmartNode belongs.
-- @return               an instance of "SputnikRepository".
-----------------------------------------------------------------------------
function new(versium_node, repository, root_prototype_id, mode)
   assert(versium_node)
   assert(versium_node._version)
   assert(repository)
   -- We start with a versium node, which already has a metatable that we want to keep.
   -- But we also want the new node to have SmartNode as its metatable. So, we set 
   -- SmartNode as the metatable of versium_node's metatable.
   setmetatable(getmetatable(versium_node), SmartNode_mt)

   -- Then we make a new node with versium_node as it's metatable.  We can do this using
   -- SmartNode's "wrap" method.  After that we can access the original node as node._vnode.
   local node = versium_node:wrap("_vnode")
   assert(node._vnode)

   -- Now set the repository and the root prototype
   node.repository = repository
   node.root_prototype_id = root_prototype_id
   assert(node.root_prototype_id)

   -- Now apply inheritance unless a flag on the repository tells us not to.
   -- Either way, we push the node down another level on our metatable chain.
   -- Then we do the same for activation 
   if not (repository.suppress_inheritance or mode=="basic") then 
      node:apply_inheritance()
   end
   node = node:wrap("_inactive")
   if not (repository.suppress_inheritance or repository.suppress_activation or mode=="basic") then
      node:activate()
   end

   assert(node._vnode)   
   return node
end

---------------------------------------------------------------------------------------------------
-- Returns the edits to the node.
--
-- @param prefix         an optional date prefix (e.g., "2007-12").
-- @return               edits as a table.
---------------------------------------------------------------------------------------------------
function SmartNode:get_history(prefix)
   return self.repository:get_node_history(self._id, prefix)
end

---------------------------------------------------------------------------------------------------
-- Makes a new table with this node as its metatable.
--
-- @param field_name_for_old_table  the name of a field through which the original node would be
--                       accessible (optional).
---------------------------------------------------------------------------------------------------
function SmartNode:wrap(field_name_for_old_table) 
   self.__index = self
   local new_table = {}
   if field_name_for_old_table then
      new_table[field_name_for_old_table] = self
   end
   setmetatable(new_table, self)
   return new_table
end
  
---------------------------------------------------------------------------------------------------
-- Returns the node as a string (used for debugging).
---------------------------------------------------------------------------------------------------
function SmartNode:tostring()
   local buf = "================= "..self._id.." ========\n"
   for field, fieldinfo in pairs(self.fields) do
      buf = buf.."~~~~~~~ "..field.." ("..(fieldinfo.proto or "")..") ~~~~\n"
      buf = buf..(self._inactive[field] or "")
      buf = buf.."\n"
   end
   buf = buf.."~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n"
   return buf
end

---------------------------------------------------------------------------------------------------
-- Applies inheritance form page's prototype.  Note that this method gets called on essentially a 
-- blank table where the original values have been metatabled into node._vnode.
--
-- @return               self.
---------------------------------------------------------------------------------------------------
function SmartNode:apply_inheritance()
   -- If this is the ultimate prototype, then there is no further
   -- prototype.
   assert(self.root_prototype_id)
   assert(self._id)
   if self._id == self.root_prototype_id then
      return
   end
   if (self._vnode.prototype or ""):len() == 0 then
      self._vnode.prototype = nil
   end
   local prototype = self.repository:get_node(self._vnode.prototype or self.root_prototype_id)._inactive
 
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

   local tmp_fields = concat(prototype.fields, self.fields)
   local fields, err = versium.luaenv.make_sandbox{}.do_lua(tmp_fields)

   for field_name, field in pairs(fields) do
      field.name = field_name
      if field.proto then
         if field.proto == "concat" then
            self[field.name] = concat(prototype[field.name], self[field.name])    
         elseif field.proto == "fallback" then
            self[field.name] = self[field.name] or prototype[field.name]
         end
      end
   end

   -- We now have the "inherited" versions of all the values in the fields of self.  (Note that the
   -- can access the original values via self._vnode.)  Now we'll push self into the _inherited 
   -- field of a new table.

   return self
end


---------------------------------------------------------------------------------------------------
-- Turns string parameters into Lua functions and tables, making them callable.
---------------------------------------------------------------------------------------------------
function SmartNode:activate() 
   local fields, err = versium.luaenv.make_sandbox{}.do_lua(self.fields)
   if not fields then
      error(err)
   end

   for field, fieldinfo in pairs(fields) do
      if fieldinfo.activate then
         self[field] = Activators[fieldinfo.activate](self[field], self.repository)
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
function SmartNode:update(new_values, fields)
   assert(new_values)
   assert(fields)
   -- First, update the versium node with the new values (only those that are listed in fields!)
   for key, value in pairs(new_values) do
      if fields[key] and not fields[key].virtual then
         self._vnode[key] = value
      end
   end
   -- Now make a new node, being careful to not get into recursive metatables
   local vnode = self._vnode
   setmetatable(self._inactive, {}) -- to avoid recursive metatables
   local new_smart_node = new(vnode, self.repository, self.repository.config.ROOT_PROTOTYPE)
   -- Now make the current node a copy of the new one (copy the fields and the metatable
   for k,v in pairs(new_smart_node) do
      self[k] = v
   end
   setmetatable(self, getmetatable(new_smart_node))
end

---------------------------------------------------------------------------------------------------
-- Returns a diff between this version of the node and some other one.
--
-- @param other          the other version id.
-- @return               diff as a table of tokens.
---------------------------------------------------------------------------------------------------
function SmartNode:diff(other)
   return self.repository.versium:smart_diff(self._vnode._id, self._vnode._version.id, other)
end

---------------------------------------------------------------------------------------------------
-- Saves the node (using the data that's already in the node).
-- 
-- @param author         the author associated with the edit.
-- @param comment        a comment for the edit (optional).
-- @param extra          extra params (optional).
-- @return               nothing.
---------------------------------------------------------------------------------------------------
function SmartNode:save(author, comment, extra)
   assert(author)
   self.repository:save_node(self, author, comment, extra)
end

-----------------------------------------------------------------------------
-- Tells us whether this is ann outdated version of the node.
-- 
-- @return               true if the node is outdated, false if it's the most
--                       recent version _or_ the node has no history.
-----------------------------------------------------------------------------
function SmartNode:is_old()
   assert(self._vnode)
   local history = self:get_history()
   if #history == 0 then 
      return false 
   else
      return history[1].version~=self._version.id
   end
end

