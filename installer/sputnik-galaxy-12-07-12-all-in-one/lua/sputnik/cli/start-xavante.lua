module(..., package.seeall)

local xavante = require("sputnik.xavante")

USAGE = [[
NAME:
        sputnik start-xavante

SYNOPSIS:

        sputnik start-xavante [<wsapi_script>] [<port_number>]

DESCRIPTION:

        Launches Xavante, an embedded web server distributed with Sputnik.
        Requires a WSAPI script, which can be generated using "make-cgi" command
        (see "help make-cgi").
        
OPTIONS:

        <wsapi_script>
            The script defining a Sputnik instance. The default is
            "sputnik.ws" in the current working directory.
            
        <port_number>
            The port number on which Xavante will run. The default is 8080.

]]

function execute(args, sputnik)
   xavante.start(args[2] or "./sputnik.ws", args[3] or "8080")
end
