-----------------------------------------------------------------------------
-- Defines Sputnik's interface to WSAPI.
--
-- (c) 2007, 2008  Yuri Takhteyev (yuri@freewisdom.org)
-- License: MIT/X, see http://sputnik.freewisdom.org/en/License
-----------------------------------------------------------------------------
module(..., package.seeall)

require("sputnik")
local util = require("sputnik.util")
require("coxpcall")

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
-- Templates for an error messages with a stack trace.
-----------------------------------------------------------------------------
local HTML_MESSAGE_WITH_STACK_TRACE = [[
<br/>
<span style="color:red; font-size: 19pt;">%s</span></br><br/><br/>
Error details: <pre><b><code>%s</code></b></pre><br/>
]]
-----------------------------------------------------------------------------
-- Templates for an error messages without a stack trace.
-----------------------------------------------------------------------------
local HTML_MESSAGE_WITHOUT_STACK_TRACE = [[
<br/>
<span style="color:red; font-size: 19pt;">%s</span></br><br/><br/>
(If you are the admin for this site, you can turn on stack trace display
 by setting SHOW_STACK_TRACE parameter to true.)
]]

-----------------------------------------------------------------------------
-- Calls a function safely, returning an error message formatted as HTML
-- if something goes wrong.
--
-- @param fn             the function to be called.
-- @param config         a config table.
-- @param logger         an optional lualogging logger.
-- @param request        the request (optional)
-- @param ...            parameters for fn()
-- @return               status
-- @return               the result of fn(...) or an error message.
-----------------------------------------------------------------------------
local function htmlized_pcall (fn, config, logger, request, ...)
   local success, result_or_error = coxpcall(fn, function(e) return e end, ...)
   if success then
      return true, result_or_error
   else
      local error_message = result_or_error
      local summary = detect_common_errors(error_message, config)
                      or "Sputnik ran but failed due to an unexpected error."
      if logger then
         logger:error(error_message)
      end
      return false, string.format(config.SHOW_STACK_TRACE 
                                  and HTML_MESSAGE_WITH_STACK_TRACE
                                  or HTML_MESSAGE_WITHOUT_STACK_TRACE,
                                  summary, util.escape(error_message))
   end
end

-----------------------------------------------------------------------------
-- Creates a WSAPI app that always returns an error message.
-- 
-- @param error_message  the error message to return for every request.
-- @param                a WSAPI app function.
-----------------------------------------------------------------------------
local function new_error_app_function(error_message)
   require("wsapi.response")
   return function(wsapi_env)
      response = wsapi.response.new()
      response:write(error_message)
      response.status = 500
      return response:finish()
   end
end
-----------------------------------------------------------------------------
-- Creates a WSAPI app function to handle requests based on a configuration
-- table.
--
-- @param config         a bootstrap configuration for Sputnik.
-----------------------------------------------------------------------------
function new(config)

   local ok, logger, my_sputnik, error_message
   ok, logger = htmlized_pcall(util.make_logger, config, nil, nil,
                               config.LOGGER,
                               config.LOGGER_PARAMS, config.LOGGER_LEVEL)
   if not ok then
      error_message = logger
      return new_error_app_function(error_message)
   end

   ok, my_sputnik = htmlized_pcall(sputnik.new, config, logger, nil,
                                   config, logger)
   if not ok then
      error_message = my_sputnik
      return new_error_app_function(error_message)
   end

   if ok and config.INIT_FUNCTION then
      ok, error_message = htmlized_pcall(config.INIT_FUNCTION, config, logger, nil,
                          my_sputnik, config)
   end

   if not ok then
      return new_error_app_function(error_message)
   end

   return  function (wsapi_env)
      _G.format = string.format -- to work around a bug in wsapi.response

      require("wsapi.request")
      local request = wsapi.request.new(wsapi_env)
      request.wsapi_env = wsapi_env

      require("wsapi.response")
      local response = wsapi.response.new()

      local ok, error_as_html = htmlized_pcall(my_sputnik.handle_request,
                                               config, my_sputnik.logger,
                                               request,
                                               -- actual function params
                                               my_sputnik, request, response)
      if not ok then
         response = wsapi.response.new()
         response:write(error_as_html)
         response.status = 500
      end
      -- Change the HTTP status code to 302 is a location header is set
      if response.headers["Location"] then
         if response.status < 300 then
            response.status = 302
         end
      end

      return response:finish()
   end
end
