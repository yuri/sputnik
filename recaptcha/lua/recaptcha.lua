module(..., package.seeall)

local ReCaptcha = {}
local ReCaptcha_mt = {__metatable = {}, __index = ReCaptcha}

function new(args)
   local obj = setmetatable({}, ReCaptcha_mt)
   obj.private = args[2]
   obj.public = args[1]
   return obj
end

function ReCaptcha:get_fields()
   return {"recaptcha_challenge_field", "recaptcha_response_field"}
end


function ReCaptcha:get_javascript(options)
   options = options or {}
   return string.format([[
      <script>
       var RecaptchaOptions = {
          theme : '%s',
          lang  : '%s',
       };
      </script>
      <script type="text/javascript" src="http://api.recaptcha.net/challenge?k=%s">
      </script>
   ]], options.theme or "white", options.lang or "en", self.public)
end

function ReCaptcha:get_noscript()
   return string.format([[
      <noscript>
       <iframe src="http://api.recaptcha.net/noscript?k=%s"
               height="300" width="500" frameborder="0"></iframe><br/>
       <textarea name="recaptcha_challenge_field" rows="3" cols="40">
       </textarea>
       <input type="hidden" name="recaptcha_response_field" value="manual_challenge">
      </noscript>
   ]], self.public)
end

function ReCaptcha:get_html(options)
   return self:get_javascript(options).."\n"..self:get_noscript(options)
end

-----------------------------------------------------------------------------
-- Verifies the captcha.
-- 
-- @param remote_ip      user's IP address.
-- @param challenge      the challenge string.
-- @param response       user's response.
-- @return               true if the verification is successful and false
--                       otherwise.
-----------------------------------------------------------------------------

function ReCaptcha:verify(params, remote_ip)
   require("socket.http")
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
         return result and result=="true", err
      end
   end
end


