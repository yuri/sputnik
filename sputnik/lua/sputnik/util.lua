-----------------------------------------------------------------------------
-- Defines utility functions for Sputnik.
--
-- (c) 2007, 2008  Yuri Takhteyev (yuri@freewisdom.org)
-- License: MIT/X, see http://sputnik.freewisdom.org/en/License
-----------------------------------------------------------------------------

module(..., package.seeall)

-----------------------------------------------------------------------------
-- Splits a string on a delimiter. 
-- Adapted from http://lua-users.org/wiki/SplitJoin.
-- 
-- @param text           the text to be split.
-- @param delimiter      the delimiter.
-- @return               unpacked values.
-----------------------------------------------------------------------------
function split(text, delimiter)
   local list = {}
   local pos = 1
   if string.find("", delimiter, 1) then 
      error("delimiter matches empty string!")
   end
   while 1 do
      local first, last = string.find(text, delimiter, pos)
      if first then -- found?
	 table.insert(list, string.sub(text, pos, first-1))
	 pos = last+1
      else
	 table.insert(list, string.sub(text, pos))
	 break
      end
   end
   return unpack(list)
end

-----------------------------------------------------------------------------
-- Escapes a text for using in a text area.
-- 			
-- @param text           the text to be escaped.
-- @return               the escaped text.
-----------------------------------------------------------------------------
function escape(text) 
   text = text or ""
   text = text:gsub("&", "&amp;"):gsub(">","&gt;"):gsub("<","&lt;")
   return text:gsub("\"", "&quot;")
end

-----------------------------------------------------------------------------
-- Escapes a URL.
-- 
-- @param text           the URL to be escaped.
-- @return               the escaped URL.
-----------------------------------------------------------------------------

function escape_url(text)
   return text:gsub("[^a-zA-Z0-9]",
                    function(character) 
                       return string.format("%%%x", string.byte(character))
                    end)
end

-----------------------------------------------------------------------------
-- A template for cosmo error messages.
-----------------------------------------------------------------------------
COSMO_ERROR_TEMPLATE = [[
<span style="color:red; size=200%%; font-weight: bold">
  Error in Cosmo Template:
</span><br/><br/>
<sp style="color:#660000; size=150%%; font-weight: bold">Template</p>
<pre><code>%s</code></pre>
<p style="color:#660000; size=150%%; font-weight: bold">Values</p>
<pre><code>%s</code></pre>
<p style="color:#660000; size=150%%; font-weight: bold">Message</p>
<pre><code>%s</code></pre>
]]

-----------------------------------------------------------------------------
-- Like cosmo.f() but returns an HTMLized message in case of error.
--
-- @param template       a cosmo template.
-----------------------------------------------------------------------------
function f(template)
   local fn = cosmo.f(template)
   return function(values)
      local function error_handler (err)
               local values_as_str = ""
               for k,v in pairs(values) do
                  values_as_str = values_as_str..k..": <"..type(v)..">\n"
               end
               return string.format(COSMO_ERROR_TEMPLATE, escape(template),
                                    escape(values_as_str),
                                    escape(err:gsub("\nstack traceback:.*$", "")))
      end
      local ok, result_or_error = xpcall(function() return fn(values) end,
                                         error_handler)
      return result_or_error, ok
   end
end

-----------------------------------------------------------------------------
-- Turns a string into something that can be used as a page name, converting
-- - ? + = % ' " / \ and spaces to '_'.  Note this isn't enought to ensure
-- legal win2k names, since we _are_ allowing [ ] + < > : ; *, but we'll rely
-- on versium to escape those later.
-- 
-- @param text           the string to be dirified.
-- @return               the dirified string.
-----------------------------------------------------------------------------
function dirify(text)
   local pattern = [[[%?%+%=%%%s%'%"%\]+]]
   return (text or ""):gsub(pattern, "_")
end

-----------------------------------------------------------------------------
-- Returns value1 if condition is true and value2 otherwise.  Note that if 
-- expressions are passed for value1 and value2, then they will be evaluated
-- _before_ the choice is made.
--
-- @param condition      a boolean value
-- @param value1         the value that gets returned in case of true
-- @param value2         the value that gets returned in case of false
-- @return               either value1 or value2
-----------------------------------------------------------------------------
function choose(condition, value1, value2)
   if condition then
      return value1
   else
      return value2
   end
end

-----------------------------------------------------------------------------
-- Sends email on Sputnik's behalf.
--
-- @param args           a table of parameters
-- @param sputnik        an instance of Sputnik
-- @return               status (boolean) and possibly an error message
-----------------------------------------------------------------------------
function sendmail(args, sputnik)
   assert(args.to, "No recepient specified")
   assert(args.subject, "No subject specified")
   assert(args.from, "No source specified")

   local smtp = require("socket.smtp")
   local status, err = smtp.send{
            from = args.from,
            rcpt = "<"..args.to..">",
            source = smtp.message{
               headers = {
                  from = args.from,
                  to = args.to,
                  subject = args.subject
               },
               body = args.body or "",
            },
            server = sputnik.config.SMTP_SERVER or "localhost",
            port   = sputnik.config.SMTP_SERVER_PORT or 25,
            user   = sputnik.config.SMTP_USER,
            password   = sputnik.config.SMTP_PASSWORD,
         }
   return status, err
end

-----------------------------------------------------------------------------
-- Creates a logger instance.
-----------------------------------------------------------------------------
function make_logger(module_name, params, level)
   if module_name then
      require("logging."..module_name)
      local logger, err = logging[module_name](unpack(params))
      assert(logger, "Could not initialize logger: "..(err or ""))
      if level then 
         require("logging")
         logger:setLevel(logging[level])
      end
      return logger
   else
      return {
         debug = function(...) end, -- do nothing
         info  = function(...) end,
         error = function(...) end,
         warn  = function(...) end,
      }
   end
end

-----------------------------------------------------------------------------
-- A cycle class.
----------------------------------------------------------------------------- 
local Cycle = {}
local Cycle_mt = {__metatable = {}, __index = Cycle}
function new_cycle(values)
   return setmetatable({values=values, i=1}, Cycle_mt)
end
function Cycle:next()
   self.i = (self.i % #(self.values)) + 1
end
function Cycle:get()
   return self.values[self.i]
end

