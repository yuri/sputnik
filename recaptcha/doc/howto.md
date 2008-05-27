
## Creating the catpcha object

You will need to get your PRIVATE and PUBLIC API keys from <a href="https://admin.recaptcha.net/recaptcha/createsite/">recaptcha.net</a>.
Once you have them, create an instance or ReCaptcha like this:

    captcha = recaptcha.new{PRIVATE, PUBLIC}

## Generating the Widget

Include the output of captcha:get_html() into your form.  For instance:

    my_html = "<form action='...' method='post'...>"
              .. "..." -- add your fields
              .. captcha:get_html()
              .. "<input type='submit'/>"
              .. "</form>"

## Verifying User's Input

Send your POST fields and the user's IP address to captcha:verify().  For instance, for WSAPI:

    local request = wsapi.request.new(wsapi_env)
    local ok, err = captcha:verify(request.POST, wsapi_env.REMOTE_ADDR)

    if ok then
       ...
    else
       print ("Error: "..err)
    end
