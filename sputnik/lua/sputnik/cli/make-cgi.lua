module(..., package.seeall)

local installer = require("sputnik.installer")

USAGE = [[
NAME:
        sputnik make-cgi

SYNOPSIS:

        sputnik make-cgi [<data_directory>] [<destination_directory>]

DESCRIPTION:

        Creates launcher scripts for Sputnik. Specifically, this command will
        create two files: sputnik.ws and sputnik.cgi, containing specifications
        for a Sputnik instance. sputnik.cgi can be used with any web server
        supporting CGI and can be adapeted to be used for FCGI. sputnik.ws can
        be used with Xavante, a web server distributed together with Sputnik.
        
OPTIONS:

        <data_directory>
            The directory where Sputnik will store node data. Must be writable
            by the server. The default is "wiki-data" inside the current working
            directory.
            
        <destination_directory>
            The directory where sputnik.ws and sputnik.cgi files will be written.
            The default is the current working directory.

]]

function execute(args, sputnik)

   local without_luarocks = WITHOUT_LUAROCKS or args['without-luarocks']
   installer.reset_salts()
   data_directory = args[2]
   working_directory = args[3]
   installer.make_wsapi_script(data_directory, working_directory, "sputnik.ws", {without_luarocks=without_luarocks})
   installer.make_cgi_file(data_directory, working_directory, "sputnik.cgi",  {without_luarocks=without_luarocks})
end
