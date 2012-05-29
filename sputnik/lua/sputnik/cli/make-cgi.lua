module(..., package.seeall)

local installer = require("sputnik.installer")

function execute(args, sputnik)

   local without_luarocks = WITHOUT_LUAROCKS or args['without-luarocks']
   installer.reset_salts()
   data_directory = args[2]
   working_directory = args[3]
   installer.make_wsapi_script(data_directory, working_directory, "sputnik.ws", {without_luarocks=without_luarocks})
   installer.make_cgi_file(data_directory, working_directory, "sputnik.cgi",  {without_luarocks=without_luarocks})
end
