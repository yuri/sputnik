module(..., package.seeall)

require"lfs"
require"cosmo"

REQUIRE_LUAROCKS = [[pcall(require, "luarocks.require")]]

WS_SCRIPT_TEMPLATE = [=[
require('sputnik.wsapi_app')
return sputnik.wsapi_app.new{
   VERSIUM_PARAMS = { [[$data_directory]] },
   BASE_URL       = '/',
   PASSWORD_SALT  = '$password_salt',
   TOKEN_SALT     = '$token_salt',
}
]=]

CGI_TEMPLATE = [=[#! $lua
$require_luarocks
require('sputnik.wsapi_app')
local my_app = sputnik.wsapi_app.new{
   VERSIUM_PARAMS = { [[$data_directory]] },
   BASE_URL       = '/cgi-bin/sputnik.cgi',
   PASSWORD_SALT  = '$password_salt',
   TOKEN_SALT     = '$token_salt',
}

require("wsapi.cgi")
wsapi.cgi.run(my_app)
]=]


CHARACTERS = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
local password_salt = ""
local token_salt = ""

function reset_salts()
   math.randomseed(os.time())
   password_salt = make_salt()
   token_salt = make_salt()
end

function make_salt(length)
   local buffer = ""
   local num_chars = CHARACTERS:len()
   local r
   for i=1, (length or 40) do
      r = math.random(num_chars)
      buffer = buffer..CHARACTERS:sub(r,r)
   end
   return buffer
end


function make_script(data_directory, working_directory, filename, template, options)

   options = options or {}
   
   working_directory = working_directory or lfs.currentdir()
   local file_path = working_directory.."/"..filename
   data_directory = data_directory or working_directory.."/wiki-data/"
   if (data_directory:sub(-1)~= "/") then
       data_directory = data_directory.."/"
   end

   if lfs.attributes(file_path) then
      print("Cannot create '"..file_path.."': file already exists.")
      print("Delete the file, then try again.")
      return
   end
   local out, err = io.open(file_path, "w")
   if err then
      print("Could not create file '"..path.."':")
      print(err)
      return
   end

   local require_luarocks = REQUIRE_LUAROCKS
   if options.without_luarocks then
      require_luarocks = "--"..require_luarocks
   end

   local lua = LUA or working_directory.."/bin/lua"

   local content = cosmo.f(template){
                      data_directory = data_directory, 
                      password_salt = password_salt,
                      token_salt    = token_salt,
                      require_luarocks = require_luarocks,
                      lua = lua
                   }
   out:write(content)
   out:close()
end

function make_wsapi_script(data_directory, working_directory, filename, options)
   make_script(data_directory, working_directory, filename, WS_SCRIPT_TEMPLATE, options)
end

function make_cgi_file(data_directory, working_directory, filename, options)
   make_script(data_directory, working_directory, filename, CGI_TEMPLATE, options)
end
