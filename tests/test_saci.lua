
require("luarocks.require")
require("saci")


local s = saci.new("versium.filedir", {"/home/yuri/sputnik/wiki-data/"}, "@Root")

local i = 0
local n
while i < 1000 do
   s:reset_cache()
   n = s:get_node("index")
   i = i + 1
end

print(n.content)
