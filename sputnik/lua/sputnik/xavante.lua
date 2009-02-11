module(..., package.seeall)

-------------------------------------------------------------------------------
-- Starts the Xavante Web server for running just Sputnik.
-------------------------------------------------------------------------------

pcall(require, "luarocks.require")
require "xavante.redirecthandler"
require "wsapi.xavante"
require "xavante"
require "lfs"

function xavante_start_message(ports)
      local date = os.date("[%Y-%m-%d %H:%M:%S]")
      print(string.format("%s Xavante+Sputnik started on port(s) %s",
                          date, table.concat(ports, ", ")))
end

xavante_is_finished = function() return false end

function start(web_dir)

   web_dir = web_dir:gsub("^%.", lfs.currentdir())

   xavante.start_message(xavante_start_message)
   xavante.HTTP{
	   server = {host = "*", port = 8080},
	   defaultHost = {
		  rules = {
		     { -- URI remapping example
		       match = "^/$",
		       with = xavante.redirecthandler, params = {"sputnik.ws"}
		     },
		     { -- wsapihandler example
		        match = {"sputnik.ws$"},
		        with = wsapi.xavante.makeGenericHandler(web_dir)
		     },
		  }
	   },
   }
   xavante.start(xavante_is_finished, XAVANTE_TIMEOUT)
end

