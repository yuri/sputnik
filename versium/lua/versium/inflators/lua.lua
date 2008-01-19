
module(..., package.seeall)

luaenv = require("versium.luaenv")

function make_inflator(params, versium)
   return {
      inflate = function(self, node_string)
                   return luaenv.make_sandbox().do_lua(node_string)
                end,
      deflate = function(self, inflated_node)
                   local buffer = ""
                   for k,v in pairs(inflated_node) do
                      if k~="__index" then
                         buffer = buffer.."\n "..k.."= "..versium:longquote(tostring(v))
                      end
                   end
                   return buffer
                end,
   }
end

