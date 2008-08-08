module(..., package.seeall)

require"lfs"
require"cosmo"

WS_SCRIPT_TEMPLATE = [[
require('sputnik')
return sputnik.new_wsapi_run_fn{
   VERSIUM_PARAMS = { '$dir/wiki-data/' },
   BASE_URL       = '/sputnik.ws',
   PASSWORD_SALT  = '$password_salt',
   LOCAL_SALT     = '$local_salt',
}
]]

CGI_TEMPLATE = "#! /bin/bash $dir/bin/wsapi.cgi"..WS_SCRIPT_TEMPLATE

CHARACTERS = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

math.randomseed(os.time())

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


function make_script(dir, subpath, template)
   dir = dir or lfs.currentdir()
   local path = dir.."/"..subpath

   if lfs.attributes(path) then
      print("Cannot create '"..path.."': file already exists.")
      print("Delete the file, then try again.")
      return
   end
   local out, err = io.open(path, "w")
   if err then
      print("Could not create file '"..path.."':")
      print(err)
      return
   end
   local content = cosmo.f(template){
                      dir           = dir, 
                      password_salt = make_salt(), 
                      local_salt    = make_salt()
                   }
   out:write(content)
   out:close()
end

function make_wsapi_script(dir, subpath)
   make_script(dir, subpath, WS_SCRIPT_TEMPLATE)
end

function make_cgi_file(dir, subpath)
   make_script(dir, subpath, CGI_TEMPLATE)
end
