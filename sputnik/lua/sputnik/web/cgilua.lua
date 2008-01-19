
module(..., package.seeall)

--DEBUG = true  -- uncomment for "debug" mode
debug = function() 
   -- do nothing
end
if DEBUG then
   SAPI.Response.contenttype("text/plain")
   debug = print
end
debug(cgilua.path_info)

-------------------------------------------------------------------------
require("cgilua.cookies")
require("sputnik")
require("sputnik_config")

local request  = {}
local response = {}
request.get_cookie = cgilua.cookies.get
if cgilua.requestmethod=="POST" then
   request.params = cgilua.POST
else
   request.params = cgilua.QUERY
end

response.set_cookie = cgilua.cookies.set
response.set_content_type = SAPI.Response.contenttype
response.write = cgilua.put

mySputnik = sputnik.Sputnik:new(sputnik_config)
mySputnik:run(request, response)

