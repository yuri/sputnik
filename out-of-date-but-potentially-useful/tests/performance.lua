

require("luarocks.require")
require("sputnik")

local my_sputnik = sputnik.new{
                         VERSIUM_PARAMS = { "/home/yuri/sputnik/wiki-data/" },
                         BASE_URL = "",
                         TOKEN_SALT = ""
                      }

local i = 0
local n, request, response
while i < 1000 do
   my_sputnik.saci:reset_cache()
   --n = my_sputnik:get_node("index")

   n = my_sputnik:handle_request(request, response)

   i = i + 1
end
print (n.content)
