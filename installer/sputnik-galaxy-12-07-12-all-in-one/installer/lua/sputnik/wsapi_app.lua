-----------------------------------------------------------------------------
-- Wraps Sputnik into a WSAPI app with error handling.
--
-- (c) 2007, 2008  Yuri Takhteyev (yuri@freewisdom.org)
-- License: MIT/X, see http://sputnik.freewisdom.org/en/License
-----------------------------------------------------------------------------
module(..., package.seeall)

require("sputnik")
local util = require("sputnik.util")
require("coxpcall")
require("wsapi.request")
require("wsapi.response")


-----------------------------------------------------------------------------
-- Template for an error messages with a stack trace.
-----------------------------------------------------------------------------
local HTML_MESSAGE_WITH_STACK_TRACE = [[
<br/>
<span style="color:red; font-size: 19pt;">%s</span></br><br/><br/>
Error details: <pre><b><code>%s</code></b></pre><br/>
]]

-----------------------------------------------------------------------------
-- Template for an error messages without a stack trace.
-----------------------------------------------------------------------------
local HTML_MESSAGE_WITHOUT_STACK_TRACE = [[
<br/>
<span style="color:red; font-size: 19pt;">%s</span></br><br/><br/>
(If you are the admin for this site, you can turn on stack trace display
 by setting SHOW_STACK_TRACE parameter to true.)
]]

-----------------------------------------------------------------------------
-- Template for the error messages when error handling failed...
-----------------------------------------------------------------------------
ULTIMATE_OOPS_MESSAGE = [[
 <br/><br/><br/><br/>
 <center><b>Something went terribly wrong...</b></center>
]]


-----------------------------------------------------------------------------
-- Given two apps, creates a new one that uses the second app as a backup for
-- the first. So, the first app gets called first. If it runs successfully,
-- it's output is returned. If it fails, the second app is called for error
-- handling.
-----------------------------------------------------------------------------
local function make_safer_app(app_function, error_app_function)
   return function(wsapi_env, err)
      local ok, status, headers, fn = coxpcall(
               function() return app_function(wsapi_env, err) end,
               function(e) return error_app_function(wsapi_env, e) end
            )
      return status, headers, fn
   end
end


-----------------------------------------------------------------------------
-- Creates an optimistic WSAPI app function for Sputnik. This function
-- assumes that everything will work out right. We'll have to wrap this with
-- make_safer_app() to make sure the errors get reported properly.
-----------------------------------------------------------------------------
local function make_basic_sputnik_app(config)
   local my_sputnik = sputnik.new(config)
   if config.INIT_FUNCTION then
      config.INIT_FUNCTION(my_sputnik)
   end
   return function (wsapi_env)      
      local request = wsapi.request.new(wsapi_env)
      request.ip = wsapi_env.REMOTE_ADDR

      local response = wsapi.response.new()
      my_sputnik:handle_request(request, response)

      if response.headers["Location"] then
         if response.status < 300 then
            response.status = 302
         end
      end

      return response:finish()
   end
end


-----------------------------------------------------------------------------
-- An auxiliary functions to catch common errors and provide a better message
-- for them.
-----------------------------------------------------------------------------
local detect_common_errors = function(error_message, config)
   local pattern = "Versium storage error: (.*) Can't open file: (.*) in mode w"
   local dummy, path = string.match(error_message, pattern)
   local dir = config.VERSIUM_PARAMS
   if path and path:sub(1, dir:len()) == dir then
      return string.format([[Versium's data directory (%s) is not writable.<br/>
                             Please fix directory permissions.]], dir)
   end
end


-----------------------------------------------------------------------------
-- Creates a WSAPI app for handling errors. This function tried to log the
-- error to the logger supplied in configuration. It then checks if it should
-- be displaying the stack trace to the user or not, and displays it if
-- appropriate.
-----------------------------------------------------------------------------
local function make_error_handling_app(config)
   return function(wsapi_env, err)
      -- Try to log this error.
      local ok, logger = copcall(util.make_logger, config.LOGGER,
                                 config.LOGGER_PARAMS, config.LOGGER_LEVEL)
      if ok then
         logger:error(err)
      end

      -- Figure out what to tell the user.
      local summary = detect_common_errors(err, config)
                      or "Sputnik ran but failed due to an unexpected error."
      local message
      if config.SHOW_STACK_TRACE then
         message = string.format(HTML_MESSAGE_WITH_STACK_TRACE, summary, err)
      else
         message = string.format(HTML_MESSAGE_WITHOUT_STACK_TRACE, summary)
      end

      -- Return the message
      response = wsapi.response.new()
      response:write(message)
      response.status = 500
      return response:finish()
   end
end


-----------------------------------------------------------------------------
-- Creates a WSAPI app for handling he ultimate FAIL: error in error handling.
--
-- This app gets called when the normal Sputnik run failed, and then error
-- handling failed as well (presumably because the configuration is really
-- wrong). So, at this point it's just a matter of telling the user that
-- something went terribly wrong.
-----------------------------------------------------------------------------
local function make_oops_app()
   return function(wsapi_env)
      response = wsapi.response.new()
      response:write(ULTIMATE_OOPS_MESSAGE)
      response.status = 500
      return response:finish()
   end
end

-----------------------------------------------------------------------------
-- Creates a WSAPI app function to handle requests based on a configuration
-- table. This is the only function exported by the module. The app returned
-- by this function is _safe_ in the sense that Sputnik errors do not get
-- reported to WSAPI but are instead handled by a cascade of error-handling
-- apps.
--
-- @param config         a bootstrap configuration for Sputnik.
-----------------------------------------------------------------------------
function new(config)
   -- create three WSAPI app functions: one that we _want_ to run, another as
   -- a back up for the first (to report errors), and the third as a backup
   -- for the second (to deal with errors in error handling).
   local main_app = make_basic_sputnik_app(config)
   local error_app = make_error_handling_app(config)
   local total_fail_app = make_oops_app()
   return make_safer_app(main_app, error_app) --make_safer_app(error_app, total_fail_app))
end


--[[      -- Change the HTTP status code to 302 is a location header is set
      if response.headers["Location"] then
         if response.status < 300 then
            response.status = 302
         end
      end
]]

