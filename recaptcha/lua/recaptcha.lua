module(..., package.seeall)

-----------------------------------------------------------------------------
-- ReCaptcha (http://recaptcha.net/) is a free captcha web service that
-- shows the visitors words from old books helping digitize them. This, 
-- module provides a Lua interface to recaptcha.  You will need to get your
-- own API key from recaptcha.net to use it.
--
-- See http://sputnik.freewisdom.org/lib/recaptcha
-- License: MIT/X
-- (c) 2008 Yuri Takhteyev
-----------------------------------------------------------------------------

local ReCaptcha = {}
local ReCaptcha_mt = {__metatable = {}, __index = ReCaptcha}

-----------------------------------------------------------------------------
-- Creates a new ReCaptcha  object.
--
-- @param args           a single argument with two fields: the private API
--                       key and the public API key.
-- @return               an instance of ReCaptcha.
----------------------------------------------------------------------------- 
function new(args)
   local obj = setmetatable({}, ReCaptcha_mt)
   obj.private = args[2]
   obj.public = args[1]
   return obj
end

-----------------------------------------------------------------------------
-- Returns a table of names of fields posted by the captcha widget.
--
-- @return               a table of field names.
-----------------------------------------------------------------------------
function ReCaptcha:get_fields()
   return {"recaptcha_challenge_field", "recaptcha_response_field"}
end

-----------------------------------------------------------------------------
-- Returns the html block that creates the ReCaptcha widget.
-- 
-- @param options        a table of options.
-- @return               a string containing JavaScript and HTML for
--                       inclusion in an HTML document.
-----------------------------------------------------------------------------
function ReCaptcha:get_html(options)
   options = options or {}
   return string.format([[
      <script type="text/javascript">
       var RecaptchaOptions = {
          theme : '%s',
          lang  : '%s',
       };
      </script>
      <script type="text/javascript" src="http://api.recaptcha.net/challenge?k=%s">
      </script>
      <noscript>
       <iframe src="http://api.recaptcha.net/noscript?k=%s"
               height="300" width="500" frameborder="0"></iframe><br/>
       <textarea name="recaptcha_challenge_field" rows="3" cols="40">
       </textarea>
       <input type="hidden" name="recaptcha_response_field" value="manual_challenge"/>
      </noscript>
   ]], options.theme or "white", options.lang or "en", self.public, self.public)
end

-----------------------------------------------------------------------------
-- Verifies the captcha.
-- 
-- @param params         the table of POST parameters submitted by the client.
-- @param remote_ip      user's IP address.
-- @return               true if the verification is successful and false
--                       otherwise.
-----------------------------------------------------------------------------
function ReCaptcha:verify(params, remote_ip)
   require("socket.http")
   if not params.recaptcha_challenge_field then
      return false, "recaptcha_challenge_field not submitted"
   elseif not params.recaptcha_response_field then
      return false, "recaptcha_response_field not submitted"
   end

   local result, err = socket.http.request(
                          "http://api-verify.recaptcha.net/verify",
                          "privatekey="..self.private
                              .."&remoteip="..remote_ip
                              .."&challenge="..params.recaptcha_challenge_field
                              .."&response="..(params.recaptcha_response_field or "")
                        )
   if not result then
      return false, err
   else
      if result=="true" then
         return true
      else
         result, err = string.match(result, "(%w+)\n(.*)")
         return (result and result=="true"), err
      end
   end
end

