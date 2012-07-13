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

function start(handler, port)

   local handler_fn
   if type(handler) == "string" then
       handler = handler:gsub("^%./", lfs.currentdir().."/")
       local loaded_handler = loadfile(handler)
       if not loaded_handler then
          error("The first parameter should be a handler file.")
       end
       handler_fn = loaded_handler()
   elseif type(handler) == "function" then
       handler_fn = handler
   else
       error("The first parameter to start() must be a script path or a handler function.")
   end

   xavante.start_message(xavante_start_message)
   xavante.HTTP{
      server = {host = "*", port = port or 8080},
      defaultHost = {
        rules = {
           { match = {"^/(.+)$"},
             with  = xavante.redirecthandler,
             params = {
                "/", 
                function(req,res,cap)
                   req.cmd_url = "/?p="..cap[1]
                   if req.parsed_url.query then
                      req.cmd_url = req.cmd_url.."&"..req.parsed_url.query
                   end 
                   return "reparse" 
                end
             }
           },
           { match = {"^/$"},
             with  = wsapi.xavante.makeHandler(handler_fn, "", "", ""),
           },
        }
      },
   }
   xavante.start(xavante_is_finished, XAVANTE_TIMEOUT)
end




