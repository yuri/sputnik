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

function start(script_file)


   script_file = script_file:gsub("^%./", lfs.currentdir().."/")

   local handler_fn = loadfile(script_file)()

   xavante.start_message(xavante_start_message)
   xavante.HTTP{
	   server = {host = "*", port = 8080},
	   defaultHost = {
		  rules = {
		     { match = {"^/(.+)$"},
		       with  = xavante.redirecthandler, params = {"/?p=%1"}
		     },
		     { match = {"^/$"},
               with  = wsapi.xavante.makeHandler(handler_fn, "", "", ""),
		     },
		  }
	   },
   }
   xavante.start(xavante_is_finished, XAVANTE_TIMEOUT)
end




