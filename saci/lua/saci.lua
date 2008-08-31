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
   repo:reset_cache()
   return repo
end

function Saci:reset_cache()
   self.cache = {}
   self.cache_stub = {}
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

--[--------------------------------------------------------------------------
-- Prepares a Lua value for serialization into a stored saci node.  This
-- function will only output boolean, numeric, and number values.
--
-- @param data           The data to be serialized
-- @return               The string representation of the data
-----------------------------------------------------------------------------
local function serialize(data)
	local data_type = type(data)
	if data_type == "boolean" or data_type == "number" then
		return tostring(data)
	elseif data_type ~= "string" then
      return string.format("nil -- Could not serialize '%s'", tostring(data))
	end

	-- if the string contains any newlines, find a version of long quotes that will work
	if data:find("\n") then
		local count = 0
		local open = string.format("[%s[", string.rep("=", count))
		local close = string.format("]%s]", string.rep("=", count))

		while data:find(open, nil, true) or data:find(close, nil, true) do
			open = string.format("[%s[", string.rep("=", count))
			close = string.format("]%s]", string.rep("=", count))
			count = count + 1
		end

		return string.format("%s%s%s", open, data, close)
	else
		return string.format("%q", data)
	end
end

-----------------------------------------------------------------------------
-- Turns a node represented as a Lua table into a string representation which
-- could later be inflated again.
--
-- @param node           A versium node as a table.
-- @return               The string representation of the versium node.
-----------------------------------------------------------------------------
function Saci:deflate(node, fields)
   local buffer = ""
   local keysort = {}

   -- Sort the keys of the node so output is consistent
   for k,v in pairs(node) do
      if k ~= "__index" then
         table.insert(keysort, k)
      end
   end
   table.sort(keysort, function(x, y)
                          if fields and fields[x] and fields[y] then
                             return fields[x][1] < fields[y][1]
                          else
                             return x < y
                          end
                       end)

   for idx,key in ipairs(keysort) do
      local value = serialize(node[key])
      local padded_key = key
      if key:len() < 15 then
         padded_key = (key.."               "):sub(1,15)
      end
      buffer = string.format("%s\n%s= %s", buffer, padded_key, value)
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

   local cache_key = version and id.."."..version or id
   if self.cache[cache_key] then
      return self.cache[cache_key], self.cache_stub[cache_key]
   end

   -- first check if the id has a slash.  if so, identify the parent, and ask
   -- it about the child.
   local parent_id, rest = string.match(id, "^(.+)/(.-)$")
   if parent_id then
      local parent = self:get_node(parent_id)
      if parent then
         local node = parent:get_child(rest)
         if node then
            self.cache[cache_key] = node
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
      self.cache[cache_key] = node
      self.cache_stub[cache_key] = true
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
   self.versium:save_version(node.id, self:deflate(node.raw_values, node.fields),
                             author, comment, extra)
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
   local versium_history = self.versium:get_node_history(id, prefix, limit) or {}
   for i,v in ipairs(versium_history) do
      v.get_node = function() return self:get_node(id, v.version) end
   end
   return versium_history
end

-----------------------------------------------------------------------------
-- Retrieves multiple data nodes from Versium and returns Saci nodes created
-- from them.  If Versium returns an empty table, then Saci will also return
-- an empty table.  This function always returns the most recent version of 
-- each node
--
-- @param prefix         the desired node prefix
-- @return               a table containing the returned Saci nodes, indexed
--                       by node name.
-----------------------------------------------------------------------------
function Saci:get_nodes_by_prefix(prefix, limit)
   local versium_nodes = self:get_versium_nodes_by_prefix(prefix, limit)
   local nodes = {}
   for i, vnode in ipairs(versium_nodes) do
      nodes[id] = self:make_node(vnode.data, vnode.id)
   end
   return nodes
end

-----------------------------------------------------------------------------
-- Retrieves multiple data nodes from Versium, and returns them _without_
-- creating Saci nodes from them.
--
-- @param prefix         the desired node prefix
-- @return               a table containing the returned versium nodes,
--                       indexed by node name.
-----------------------------------------------------------------------------
function Saci:get_versium_nodes_by_prefix(prefix, limit)
   -- Get the nodes, either all at once, of one by one   
   if self.versium.get_nodes_by_prefix then
      return self.versium:get_nodes_by_prefix(prefix, limit)
   else
      local versium_nodes = {}
      for i, id in ipairs(self.versium:get_node_ids(prefix, limit)) do
         versium_nodes[id] = self.versium:get_node(id)
      end
      return versium_nodes
   end
end

-----------------------------------------------------------------------------
-- Returns a list of Saci nodes with fields matching the query.
--
-- @param query          a query as a string, with implicit "or" and with
--                       negatable terms, e.g., "lua git -storage"
-- @param fields         a list of fields to search.
-- @param prefix         a prefix within which to search.
-----------------------------------------------------------------------------
function Saci:find_nodes(query, fields, prefix)
   query = " "..query.." "
   fields = fields or {"content"}
   local QUERY_TERM = "%s([%w0-9_]+)"
   local NEGATED_TERM = "%s%-([%w0-9_]+)"
   local found = {}    -- hits for each query term
   local snippets = {} -- match snippets
   for term in query:gmatch(QUERY_TERM)   do found[term] = {} end
   for term in query:gmatch(NEGATED_TERM) do found[term] = nil end
   local node_map = {} -- maps node ids to actual nodes

   -- find nodes matching positive terms
   local i, matched, node, value
   for id, vnode in pairs(self:get_versium_nodes_by_prefix(prefix)) do
      -- first check if any of the terms is present anywhere in the node
      matched = false
      for term, _ in pairs(found) do
         if vnode:match(term) then
            matched = true
            break
         end
      end
      if matched then -- ok, one of the terms is somewhere there, let's look
         node = self:make_node(vnode, id)
         for _, field in ipairs(fields) do
            value = node[field]
            if value and type(value)=="string" then
               value = " "..value:lower().." "
               for term, hits_for_term in pairs(found) do
                  i = 0 
                  value:gsub("%W("..term..")%W", function(x) i = i + 1 end)
                  if i > 0 then
                     hits_for_term[id] = i
                     node_map[id] = node
                  end
               end
            end
         end
      end
   end

   -- check matched nodes for for negative terms
   for term in query:gmatch(NEGATED_TERM) do
      for id, node in pairs(node_map) do
         for _, field in ipairs(fields) do
            if (" "..(node[field] or " ").." "):match("%W("..term..")%W") then
               node_map[id] = nil
            end
         end
      end
   end

   -- return hits and nodes
   return found, node_map

   --

end


-- vim:ts=3 ss=3 sw=3 expandtab
