---------------------------------------------------------------------------------------------------
-- A versium "inflator" that assumes that the payload is Lua code which can be parsed by running
-- dostring() on it (with a few extra steps for security.)
---------------------------------------------------------------------------------------------------

module(..., package.seeall)
luaenv = require("versium.luaenv")

LuaInflator = {}

---------------------------------------------------------------------------------------------------
-- Creates a new instance of a LuaInflator
--
-- @param versium          a pointer to the Versium object.
-- @return                 the environment created when node_string is executed as Lua code.
---------------------------------------------------------------------------------------------------

function LuaInflator:new(versium)
   local inflator = {versium=versium}
   setmetatable(inflator, self)
   self.__index = self
   return inflator
end

---------------------------------------------------------------------------------------------------
-- Inflates a string into a table.
--
-- @param node_string      the payload of a versium node.
-- @return                 the environment created when node_string is executed as Lua code.
---------------------------------------------------------------------------------------------------

function LuaInflator:inflate(node_string)
   return luaenv.make_sandbox().do_lua(node_string)
end

---------------------------------------------------------------------------------------------------
-- Deflates a table into Lua code (only works if the string is an inflated versium node).
--
-- @param inflated_node    a table representing an inflated versium node.
-- @return                 a string with Lua code that could later be inflated back into the same
--                         table.
---------------------------------------------------------------------------------------------------

function LuaInflator:deflate(inflated_node)
   local buffer = ""
   for k,v in pairs(inflated_node) do
      if k~="__index" then
         buffer = buffer.."\n "..k.."= "..string.format("%q", tostring(v))
      end
   end
   return buffer
end

---------------------------------------------------------------------------------------------------
-- Creates an "inflator" - a table with two methods: :inflate() and :deflate().
-- 
-- @param params           A table of parameters for passed by versium (not used)
-- @param versium          A pointer to the Versium object.
---------------------------------------------------------------------------------------------------

function make_inflator(params, versium)
   return LuaInflator:new(versium)
end

