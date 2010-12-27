-----------------------------------------------------------------------------
-- Implements actions for Sputnik's registration and password management
-- flow.
--
-- (c) 2008  James Whitehead II (jnwhiteh@gmail.com)
-- (c) 2008-2010  Yuri Takhteyev (yuri@freewisdom.org)
-- License: MIT/X, see http://spu.tnik.org/en/License
-----------------------------------------------------------------------------

module(..., package.seeall)

actions = {}

-----------------------------------------------------------------------------
-- Displays the registration form.
-----------------------------------------------------------------------------
function actions.show_registration_form(node, request, sputnik)

   -- Setup the fieldspec
   field_spec = [[
                   new_username = {1.30, "text_field", div_class="autofocus"}
                   new_password = {1.31, "password"}
                   new_password_confirm = {1.32, "password"}
                ]]
   -- Add the email address
   if sputnik.config.REQUIRE_EMAIL_ACTIVATION then
      field_spec = field_spec .. [[new_email = {1.33, "text_field"} ]]
   end
   -- Add the terms of service acceptance checkbox if configured
   if sputnik.config.TERMS_OF_SERVICE_NODE then
      local tos = node.translator.translate_key("I_AGREE_TO_TERMS_OF_SERVICE")
      local text = cosmo.f(tos){
         url = sputnik:make_url(sputnik.config.TERMS_OF_SERVICE_NODE),
      }
      field_spec = field_spec..[[agree_tos = {1.34, "checkbox_text", text="]]
                             ..text..[["}]]
   end

   -- Clear the password and confirm password fields
   request.params.new_password = nil
   request.params.new_password_confirm = nil

   -- Prepare the edit form
   local form = node:make_post_form{
      field_spec   = field_spec,
      values       = request.params,
      insert_hidden_fields = true,
      extra_fields = sputnik.captcha and sputnik.captcha:get_fields(),
   }

   -- Put it all together
   node.inner_html = cosmo.f(node.templates.REGISTRATION){
      html_for_fields = form.html_for_fields,
      node_name       = node.name,
      action_url      = sputnik:make_url(node.name),
      submit_label    = node.translator.translate_key("SUBMIT"),
      captcha         = sputnik.captcha and sputnik.captcha:get_html() or "",
   }

   return node.wrappers.default(node, request, sputnik)
end


-----------------------------------------------------------------------------
-- Displays the form for requesting a password reset.
-----------------------------------------------------------------------------
function actions.show_password_reset_form(node, request, sputnik)

   -- Prepare the edit form
   local form = node:make_post_form{
      field_spec = [[
                      username = {1.30, "text_field", div_class="autofocus"}
                      email = {1.33, "text_field"}
                   ]],
      values     = request.params,
      insert_hidden_fields = true,
      extra_fields = sputnik.captcha and sputnik.captcha:get_fields(),
   }

   -- Put it all together
   node.inner_html = cosmo.f(node.templates.PASSWORD_RESET_REQUEST){
      html_for_fields = form.html_for_fields,
      node_name       = node.name,
      action_url      = sputnik:make_url(node.name),
      submit_label    = node.translator.translate_key("SUBMIT"),
      captcha         = sputnik.captcha and sputnik.captcha:get_html() or "",
   }

   return node.wrappers.default(node, request, sputnik)
end

-----------------------------------------------------------------------------
-- Creates a ticket, either for account activation or for password reset.
-----------------------------------------------------------------------------
function create_generic_ticket(args)
   local sputnik = args.sputnik
   local node = args.node
   assert(node)

   -- Create the activation ticket
   local uid = args.username..sputnik:get_uid(args.uid_node_suffix)..os.time()
   uid = md5.sumhexa(uid)
      local ticket_id = (args.prefix.."/%s"):format(uid)
   local ticket = sputnik:get_node(ticket_id)

   local expiration_time = ""
   if args.hours_before_expiration then
      expiration_time = os.time()+3600*args.hours_before_expiration
   end

   ticket:update{
            prototype = args.ticket_node_prototype,
            username  = args.username,
            email     = args.email,
            hash      = args.hash,
            title     = node.translator.translate_key(args.title_key),
            numtries  = "0",
            expiration_time = expiration_time,
         }
   ticket = sputnik:save_node(ticket, request, "Sputnik",
      "Creation of ticket for account activation or password reset")

   -- Email the user
   local link = "http://"..sputnik.config.DOMAIN..sputnik:make_url(ticket_id)
   local status, err = sputnik:sendmail{
      from    = sputnik.config.CONFIRMATION_ADDRESS_FROM,
      to      = args.email,
      subject = node.translator.translate_key(args.subject_key),
      body    = cosmo.f(node.translator.translate_key(args.message_body_key)){
                   site_name       = sputnik.config.DOMAIN,
                   link = link,
                }
   }
   return status==1, err
end

-----------------------------------------------------------------------------
-- Creates a ticket for account activation by email.
-----------------------------------------------------------------------------
function create_email_activation_ticket(args)
   local new_args = {
      uid_node_suffix = "register",
      prefix = args.sputnik.config.ADMIN_NODE_PREFIX .."activate",
      ticket_node_prototype = "sputnik/@Account_Activation_Ticket",
      subject_key = "ACCOUNT_ACTIVATION",
      message_body_key = "ACTIVATION_MESSAGE_BODY",
      title_key = "ACCOUNT_ACTIVATION"
   }
   local mt = {__index=args}
   setmetatable(new_args, mt)
   return create_generic_ticket(new_args)
end

-----------------------------------------------------------------------------
-- Creates a ticket for password reset.
-----------------------------------------------------------------------------
function create_password_reset_ticket(args)
   local new_args = {
      uid_node_suffix = "register",
      prefix = args.sputnik.config.ADMIN_NODE_PREFIX .."password_reset",
      ticket_node_prototype = "sputnik/@Password_Reset_Ticket",
      subject_key = "PASSWORD_RESET_REQUEST",
      title_key = "PASSWORD_RESET",
      message_body_key = "PASSWORD_RESET_MESSAGE_BODY",
   }
   local mt = {__index=args}
   setmetatable(new_args, mt)
   return create_generic_ticket(new_args)
end

-----------------------------------------------------------------------------
-- Creates a new account and possible a node for user's profile
-----------------------------------------------------------------------------
function create_new_account(node, request, sputnik, username, password, metadata)
   lcased_username = username:lower()
   sputnik.auth:add_user(lcased_username, password, metadata)
   node:post_translated_success("SUCCESSFULLY_CREATED_ACCOUNT")
   -- If needed, create a user node
   if sputnik.config.USE_USER_NODES then
      local prefix = (sputnik.config.USER_NODE_PREFIX or "people/")
      local user_node = sputnik:get_node(prefix..lcased_username)
      user_node:update{
               prototype = sputnik.config.USER_NODE_PROTOTYPE or "@User_Profile",
               title     = username,
               creation_time = os.time(),
            }
      local ok, err = sputnik:save_node(user_node, request, "Sputnik")
      if ok then
         node:post_translated_success("SUCCESSFULLY_CREATED_USER_NODE")
      else
         node:post_translated_error("COULD_NOT_CREATE_USER_NODE", err)
      end
   end
end


-----------------------------------------------------------------------------
-- Handles the submission of the registration form.
-----------------------------------------------------------------------------
function actions.submit_registration_form(node, request, sputnik)

   assert(request.post_parameters_checked)
   local p = request.params

   -- Check that username is acceptable
   for message, test in pairs(sputnik.config.USERNAME_RULES or {}) do
      if not test(p.new_username) then
         node:post_error(message)
         request.try_again = true
      end
   end
   if sputnik.auth:user_exists(p.new_username) then
      node:post_translated_error("USERNAME_TAKEN")
   end

   -- Check that the password is acceptable
   for message, test in pairs(sputnik.config.PASSWORD_RULES or {}) do
      if not test(p.new_password) then
         node:post_error(message)
         request.try_again = true
      end
   end
   if p.new_password ~= p.new_password_confirm then
      node:post_translated_error("TWO_VERSIONS_OF_NEW_PASSWORD_DO_NOT_MATCH")
      request.try_again = true
   end

   -- If an email address is required, check that it looks acceptable
   if sputnik.REQUIRE_EMAIL_CONFIRMATION
              and not p.new_email:match("^%S+@%S+$") then
      node:post_translated_error("NEW_EMAIL_NOT_VALID")
      request.try_again = true
   end

   -- Check for TOS acceptance
   local agree_tos = p.agree_tos and p.agree_tos~=""
   if sputnik.config.TERMS_OF_SERVICE_NODE and not agree_tos then
      node:post_translated_error("MUST_CONFIRM_TOS")
      request.try_again = true
   end

   -- If there was an issue, send the user back to the registration form
   if request.try_again then
      return actions.show_registration_form(node, request, sputnik)
   end

   -- Now we can finally proceed
   if sputnik.config.REQUIRE_EMAIL_ACTIVATION then
      -- If activation is required, email a link to a ticket
      local ok, err = create_email_activation_ticket{
            username  = p.new_username,
            email     = p.new_email,
            hash      = md5.sumhexa(p.new_password),
            sputnik   = sputnik,
            node      = node,
      }
      if ok then
         node:post_translated_success("ACTIVATION_MESSAGE_SENT")
      else
         node:post_traslated_error("ERROR_SENDING_ACTIVATION_EMAIL", err)
      end
   else
      -- Otherwise create an account right away
      create_new_account(node, request, sputnik, p.new_username, p.new_password)
      request.user, request.auth_token = sputnik.auth:authenticate(
                                               p.new_username, p.new_password)
   end
   node.inner_html = ""
   return node.wrappers.default(node, request, sputnik)
end

-----------------------------------------------------------------------------
-- Creates a password reset ticket and emails it to the user.
-----------------------------------------------------------------------------
function actions.create_password_reset_ticket(node, request, sputnik)
   assert(request.post_parameters_checked)
   local p = request.params

   -- Check the username and email
   if not sputnik.auth:user_exists(p.username) then
      node:post_translated_error("INCORRECT_USERNAME")
      request.try_again = true
   elseif p.email ~= sputnik.auth:get_metadata(p.username, "email") then
      node:post_translated_error("EMAIL_DOES_NOT_MATCH_ACCOUNT")
      request.try_again = true
   end

   -- In case of any problems, send them back to the form
   if request.try_again then
      return actions.show_password_reset_form(node, request, sputnik)
   end

   -- Try to create the ticket
   local ok, err = create_password_reset_ticket{
         username  = p.username,
         email     = p.email,
         sputnik   = sputnik,
         node      = node,
         hours_before_expiration =
                     sputnik.config.HOURS_BEFORE_PASSWORD_TICKET_EXPIRES or 2
   }

   -- Report success or failure
   if ok then
      node:post_translated_notice("PASSWORD_RESET_MESSAGE_SENT")
   else
      node:post_translated_error("ERROR_SENDING_PASSWORD_RESET_EMAIL", err)
   end
   node.inner_html = ""
   return node.wrappers.default(node, request, sputnik)
end

-----------------------------------------------------------------------------
-- Displays the account activation ticket.
-----------------------------------------------------------------------------
function actions.show_account_activation_ticket(node, request, sputnik)

   local form = node:make_post_form{
      field_spec = [[  new_password = {1.31, "password"}  ]],
      values     = request.params,
      insert_hidden_fields = true,
      extra_fields = sputnik.captcha and sputnik.captcha:get_fields(),
   }

   node.inner_html = cosmo.f(node.templates.REGISTRATION){
      html_for_fields = form.html_for_fields,
      node_name       = node.name,
      submit_label    = node.translator.translate_key("CONFIRM"),
      action_url      = sputnik:make_url(node.name),
      captcha         = sputnik.captcha and sputnik.captcha:get_html() or "",
   }

   node:post_notice(node.translator.translate_key("PLEASE_CONFIRM_PASSWORD"))
   return node.wrappers.default(node, request, sputnik)
end

-----------------------------------------------------------------------------
-- Displays the password reset ticket.
-----------------------------------------------------------------------------
function actions.show_password_reset_ticket(node, request, sputnik)

   -- Check that the ticket has been invalidated or expired
   if node.invalidated or node.expiration_time < os.time() then
      node:post_translated_error("PASSWORD_RESET_TICKET_EXPIRED")
      node.inner_html = ""
      return node.wrappers.default(node, request, sputnik)
   end

   local form = node:make_post_form{
      field_spec = [[
                        new_password = {1.31, "password"}
                        new_password_confirm = {1.32, "password"}
                   ]],
      values = request.params,
      insert_hidden_fields = true,
      extra_fields = sputnik.captcha and sputnik.captcha:get_fields(),
   }

   node.inner_html = cosmo.f(node.templates.REGISTRATION){
      html_for_fields = form.html_for_fields,
      node_name       = node.name,
      action_url      = sputnik:make_url(node.name),
      submit_label    = node.translator.translate_key("SUBMIT"),
      captcha         = sputnik.captcha and sputnik.captcha:get_html() or "",
   }

   node:post_notice(node.translator.translate_key("PLEASE_CONFIRM_PASSWORD"))
   return node.wrappers.default(node, request, sputnik)
end

-----------------------------------------------------------------------------
-- Fulfills the activation ticket upon user's confirmation of the password.
-----------------------------------------------------------------------------
function actions.fulfill_account_activation_ticket(node, request, sputnik)

   assert(request.post_parameters_checked)
   local p = request.params
   -- In case of any prior problems, send them back to the form
   if request.try_again then
      return actions.show_account_activation_ticket(node, request, sputnik)
   end

   -- Check that the password matches the hash stored in the ticket
   local password = p.new_password or ""
   local hash = md5.sumhexa(password)
   if node.hash ~= hash then
      -- check how many attempts have been made
      local numtries = tonumber(node.numtries or "0") or 0
      if numtries < (sputnik.config.MAX_ACTIVATION_ATTEMPTS or 3) then
         -- increment the number of tries
         numtries = numtries + 1
         sputnik:update_node_with_params(node, {numtries = numtries + 1})
         sputnik:activate_node(node)
         node = sputnik:save_node(node, request, "Sputnik",
            "Invalid confirmation attempt")
         node:post_translated_error("COULD_NOT_CONFIRM_NEW_PASSWORD")
         return actions.show_account_activation_ticket(node, request, sputnik)
      else -- too many tries already
         node:post_translated_error("INVALID_ACTIVATION_TICKET")
         p.new_username = nil
         node.inner_html = ""
         return node.wrappers.default(node, request, sputnik)
      end
   end

   -- Check that the account still does not exist
   if sputnik.auth:user_exists(node.username) then
      node:post_translated_error("USERNAME_TAKEN")
      return actions.show_registration_form(node, request, sputnik)
   end

   -- All good, create the account
   create_new_account(node, request, sputnik, node.username, p.new_password,
                      {email = node.email})
   request.user, request.auth_token = sputnik.auth:authenticate(node.username,
                                                                password)
   node.inner_html = ""
   return node.wrappers.default(node, request, sputnik)
end

-----------------------------------------------------------------------------
-- Fulfils the password reset ticket once the user submits the new password.
-----------------------------------------------------------------------------
function actions.fulfill_password_reset_ticket(node, request, sputnik)

   assert(request.post_parameters_checked)
   local p = request.params

   -- Check that the ticket has been invalidated or expired
   if node.invalidated or node.expiration_time < os.time() then
      node:post_translated_error("PASSWORD_RESET_TICKET_EXPIRED")
      node.inner_html = ""
      return node.wrappers.default(node, request, sputnik)
   end

   -- Check that the new password is ok
   local password = p.new_password or ""
   if password ~= p.new_password_confirm then
      node:post_translated_error("TWO_VERSIONS_OF_NEW_PASSWORD_DO_NOT_MATCH")
      request.try_again = true
   end

   -- Check that the user exists
   if not sputnik.auth:user_exists(node.username) then
      node:post_translated_error("INVALID_PASSWORD_RESET_TICKET")
      request.try_again = true
   end

   -- In case of any problems so far, send them back to the form
   if request.try_again then
      return actions.show_password_reset_ticket(node, request, sputnik)
   end


   -- Go ahead and try changing the password
   local ok = sputnik.auth:set_password(node.username, password)

   -- Cancel the ticket
   sputnik:update_node_with_params(node, {invalidated = "true"})
   sputnik:activate_node(node)
   node = sputnik:save_node(node, request, "Sputnik", "Cancelled after used")

   -- Report success or failure
   if ok then
      request.user, request.auth_token = sputnik.auth:authenticate(node.username,
                                                                   password)
      node:post_translated_success("SUCCESSFULLY_CHANGED_PASSWORD")
   else
      node:post_error("The new password could not be set.") -- ::todo::
   end
   node.inner_html = ""
   return node.wrappers.default(node, request, sputnik)
end

