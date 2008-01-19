module(..., package.seeall)
require("versium.luaenv")

function lua(value, helpers) 
   return versium.luaenv.make_sandbox(helpers.config).do_lua(value)
end

function node_list (value, helpers)
   local nodes = {}
   for line in (value or ""):gmatch("[^%s]+") do
      table.insert(nodes, line)
   end
   return nodes
end


