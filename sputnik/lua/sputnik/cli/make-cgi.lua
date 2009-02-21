module(..., package.seeall)

local installer = require("sputnik.installer")

function execute(args, sputnik)
   installer.reset_salts()
   installer.make_wsapi_script(dir, "sputnik.ws")
   installer.make_cgi_file(dir, "sputnik.cgi")
end
