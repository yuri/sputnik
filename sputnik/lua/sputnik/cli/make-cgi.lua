module(..., package.seeall)

local installer = require("sputnik.installer")

function execute(args, sputnik)

   local without_luarocks = WITHOUT_LUAROCKS or args['without-luarocks']
   installer.reset_salts()
   installer.make_wsapi_script(dir, "sputnik.ws", {without_luarocks=without_luarocks})
   installer.make_cgi_file(dir, "sputnik.cgi",  {without_luarocks=without_luarocks})
end
