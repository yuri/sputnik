#! /bin/bash /home/yuri/sputnik/bin/wsapi.cgi
require("recaptcha")

PRIVATE="<your private key here>"
PUBLIC="<your public key here>"
OWN_URL="/cgi-bin/recaptcha.cgi" -- you might need to change this

captcha = recaptcha.new{PRIVATE, PUBLIC}

return function(wsapi_env)
   require("wsapi.request")
   local request = wsapi.request.new(wsapi_env)
   local buffer = ""
   if request.POST.recaptcha_challenge_field then
      local status, err = captcha:verify(request.POST, wsapi_env.REMOTE_ADDR)
      buffer = "You typed in: '"..request.POST.recaptcha_response_field.."'.<br/>"
      if status then
         buffer = buffer.."<font color='green'><b>ok</b></font><br/>"
      else
         buffer = buffer.."<font color='red'><b>failed</b></font><br/>"
         buffer = buffer..err.."<br/>"
      end
      buffer = buffer.."<br/><br/>"
   end

   buffer = buffer..string.format([[
     The captcha widget should be shown between the two lines.
     <form action="%s" method="POST">
     <hr/>
      %s
     <hr/>
     <input type="submit"/>
     </form>

   ]], OWN_URL, captcha:get_html())

   require("wsapi.response")
   response = wsapi.response.new()
   response:write(buffer)
   return response:finish()
end
