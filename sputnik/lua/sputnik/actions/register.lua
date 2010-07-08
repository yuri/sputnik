-----------------------------------------------------------------------------
-- Implements actions for Sputnik's registration flow.
--
-- (c) 2008  James Whitehead II (jnwhiteh@gmail.com)
-- (c) 2008-2010  Yuri Takhteyev (yuri@freewisdom.org)
-- License: MIT/X, see http://spu.tnik.org/en/License
-----------------------------------------------------------------------------

module(..., package.seeall)


local html_forms = require("sputnik.util.html_forms")
local util = require("sputnik.util")
local wiki = require("sputnik.actions.wiki")

CONFIRMATION_FORM_SPEC = [[
   new_password = {1.31, "password"}
]]

NEW_PASSWORD_FORM_SPEC = [[
   new_password = {1.31, "password"}
   new_password_confirm = {1.32, "password"}
]]

actions = {}

function err_msg(node, err_code)
   node:post_error(node.translator.translate_key(err_code))
end

-----------------------------------------------------------------------------
-- Displays the registration form.
-----------------------------------------------------------------------------
function actions.show_form(node, request, sputnik)
   -- prepare the timestamp and token
   local post_timestamp = os.time()
   local post_token = sputnik.auth:timestamp_token(post_timestamp)

   local email_field = ""
   if sputnik.config.REQUIRE_EMAIL_ACTIVATION then
      email_field = [[new_email = {1.33, "text_field"} ]]
   end

   -- add the terms of service acceptance checkbox if configured
   local tos_field = ""
   if sputnik.config.TERMS_OF_SERVICE_NODE then
      local tos_template = node.translator.translate_key("I_AGREE_TO_TERMS_OF_SERVICE")
      local text = cosmo.fill(tos_template, {
         url = sputnik:make_url(sputnik.config.TERMS_OF_SERVICE_NODE),
      })
      tos_field = [[agree_tos = {1.34, "checkbox_text", text="]] .. text .. [["}]]
   end

   -- prepare the edit form
   local html_for_fields, field_list = html_forms.make_html_form{
      field_spec = [[
                      new_username = {1.30, "text_field", div_class="autofocus"}
                      new_password = {1.31, "password"}
                      new_password_confirm = {1.32, "password"}
                   ]] .. email_field .. tos_field,
      values     = {
                      new_username = request.params.new_username or "",
                      new_password = request.params.new_password or "",
                      new_password_confirm = request.params.new_password_confirm or "",
                      new_email = request.params.new_email or "",
                   },
      templates  = node.templates, 
      translator = node.translator,
      hash_fn    = function(field_name)
                      return sputnik:hash_field_name(field_name, post_token)
                   end
   }

   
   local captcha_html = ""
   if sputnik.captcha then
      for _, field in ipairs(sputnik.captcha:get_fields()) do
         table.insert(field_list, field)
      end
      captcha_html = sputnik.captcha:get_html()
   end

   node.inner_html = cosmo.f(node.templates.REGISTRATION){
      html_for_fields = html_for_fields,
      node_name       = node.name,
      post_fields     = table.concat(field_list,","),
      post_token      = post_token,
      post_timestamp  = post_timestamp,
      action_url      = sputnik:make_url(node.name),
      action          = "submit",
      submit_label    = node.translator.translate_key("SUBMIT"),
      captcha         = captcha_html,
   }

   return node.wrappers.default(node, request, sputnik)
end


-----------------------------------------------------------------------------
-- Displays the form for requesting a password reset.
-----------------------------------------------------------------------------

function actions.show_password_reset_form(node, request, sputnik)
   -- prepare the timestamp and token
   local post_timestamp = os.time()
   local post_token = sputnik.auth:timestamp_token(post_timestamp)

   -- prepare the edit form
   local html_for_fields, field_list = html_forms.make_html_form{
      field_spec = [[
                      username = {1.30, "text_field", div_class="autofocus"}
                      email = {1.33, "text_field"}
                   ]],
      values     = {
                      username = request.params.username or "",
                      email = request.params.email or "",
                   },
      templates  = node.templates, 
      translator = node.translator,
      hash_fn    = function(field_name)
                      return sputnik:hash_field_name(field_name, post_token)
                   end
   }
   
   local captcha_html = ""
   if sputnik.captcha then
      for _, field in ipairs(sputnik.captcha:get_fields()) do
         table.insert(field_list, field)
      end
      captcha_html = sputnik.captcha:get_html()
   end

   node.inner_html = cosmo.f(node.templates.PASSWORD_RESET_REQUEST){
      html_for_fields = html_for_fields,
      node_name       = node.name,
      post_fields     = table.concat(field_list,","),
      post_token      = post_token,
      post_timestamp  = post_timestamp,
      action_url      = sputnik:make_url(node.name),
      action          = "submit",
      submit_label     = node.translator.translate_key("SUBMIT"),
      captcha         = captcha_html,
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
   local uid = md5.sumhexa(args.username .. sputnik:get_uid(args.uid_node_suffix) .. os.time())
   
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
   local link = "http://" .. sputnik.config.DOMAIN .. sputnik:make_url(ticket_id)
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
-- Handles the submission of the registration form.
-----------------------------------------------------------------------------
function actions.submit(node, request, sputnik)
   function err_msg(err_code)
      request.try_again = true
      node:post_error(node.translator.translate_key(err_code))
   end

   --local wiki = require("sputnik.actions.wiki")
   local post_ok, err = wiki.check_post_parameters(node, request, sputnik)
   if not post_ok then
      err_msg(err)
   else 
      local p = request.params
      -- the form is legit, let's check that username and password are ok
      for message, test in pairs(sputnik.config.USERNAME_RULES or {}) do
         if not test(request.params.new_username) then 
            request.try_again = true
            node:post_error(message)
         end
      end
      for message, test in pairs(sputnik.config.PASSWORD_RULES or {}) do
         if not test(request.params.new_password) then 
            request.try_again = true
            node:post_error(message)
         end
      end

      -- check confirmation password
      if p.new_password ~= p.new_password_confirm then 
         err_msg("TWO_VERSIONS_OF_NEW_PASSWORD_DO_NOT_MATCH")
      end

      if sputnik.REQUIRE_EMAIL_CONFIRMATION 
         and not p.new_email:match("^%S+@%S+$") then 
            err_msg("NEW_EMAIL_NOT_VALID")
      end

      -- check that the user name is not taken
      if  sputnik.auth:user_exists(p.new_username) then
         err_msg("USERNAME_TAKEN")
      end

      -- optionally check for TOS acceptance
      if sputnik.config.TERMS_OF_SERVICE_NODE
              and not p.agree_tos then
         err_msg("MUST_CONFIRM_TOS")
      end

      -- test captcha, if configured
      if sputnik.captcha then
         local captcha_ok, err = sputnik.captcha:verify(request.POST, request.ip)
         if not captcha_ok then
            err_msg("COULD_NOT_VERIFY_CAPTCHA", err)
         end
      end
   end

   if request.try_again then
      return node.actions.show(node, request, sputnik)
   end

   if sputnik.config.REQUIRE_EMAIL_ACTIVATION then
      local ok, err = create_email_activation_ticket{
            username  = request.params.new_username,
            email     = request.params.new_email,
            hash      = md5.sumhexa(request.params.new_password),
            sputnik   = sputnik,      
            node      = node,
      }
      if ok then
         node:post_success(node.translator.translate_key("ACTIVATION_MESSAGE_SENT"))
      else
         node:post_error(node.translator.translate_key("ERROR_SENDING_ACTIVATION_EMAIL").." ("..err..")")
      end
   else
      sputnik.auth:add_user(request.params.new_username, request.params.new_password)
      request.user, request.auth_token = sputnik.auth:authenticate(request.params.new_username, request.params.new_password)   
      node:post_notice(node.translator.translate_key("SUCCESSFULLY_CREATED_ACCOUNT"))
   end

   node.inner_html = ""
   return node.wrappers.default(node, request, sputnik)
end

-----------------------------------------------------------------------------
-- Handle the submission of a request for a password reset.
-- (This is _before_ the confirmation email gets sent.)
-----------------------------------------------------------------------------

function actions.create_password_reset_ticket(node, request, sputnik)

   --function err_msg(err_code)
   --   request.try_again = true
   --   node:post_error(node.translator.translate_key(err_code))
   --end

   local post_ok, err = wiki.check_post_parameters(node, request, sputnik)

   local good_to_go = false -- let's be suspicious

   if not post_ok then
      err_msg(node, err)
   else
      local p = request.params -- the form is legit
      local captcha_ok, captcha_err
      if sputnik.captcha then
         captcha_ok, captcha_err = sputnik.captcha:verify(request.POST, request.ip)
      else
         captcha_ok = true
      end

      if not captcha_ok then
         err_msg(node, "COULD_NOT_VERIFY_CAPTCHA", err)
      elseif not sputnik.auth:user_exists(p.username) then
         err_msg(node, "INCORRECT_USERNAME")
      elseif p.email ~= sputnik.auth:get_metadata(p.username, "email") then
         err_msg(node, "EMAIL_DOES_NOT_MATCH_ACCOUNT")
      else
         good_to_go = true
      end
   end

   if good_to_go then
      local ok, err = create_password_reset_ticket{
            username  = request.params.username,
            email     = request.params.email,
            hash      = md5.sumhexa(request.params.username),
            sputnik   = sputnik,      
            node      = node,
            hours_before_expiration = sputnik.config.HOURS_BEFORE_PASSWORD_TICKET_EXPIRES or 2
      }
      if ok then
         node:post_notice(node.translator.translate_key("PASSWORD_RESET_MESSAGE_SENT"))
      else
         node:post_error(node.translator.translate_key("ERROR_SENDING_PASSWORD_RESET_EMAIL").." ("..err..")")
      end
      node.inner_html = ""
      return node.wrappers.default(node, request, sputnik)
   else
      -- try again!
      return actions.show_password_reset_form(node, request, sputnik)
   end
end

-----------------------------------------------------------------------------
-- Displays the activation form.
-----------------------------------------------------------------------------
function actions.show_account_activation_ticket(node, request, sputnik)
   local fields = {}
   fields.new_password = request.params.new_password or ""

   local post_timestamp = os.time()
   local post_token = sputnik.auth:timestamp_token(post_timestamp)

   local html_for_fields, field_list = html_forms.make_html_form{
      field_spec = CONFIRMATION_FORM_SPEC,
      templates  = node.templates, 
      translator = node.translator,
      values     = fields,
      hash_fn    = function(field_name)
         return sputnik:hash_field_name(field_name, post_token)
      end
   }

   table.insert(field_list, "recaptcha_challenge_field")
   table.insert(field_list, "recaptcha_response_field")

   node.inner_html = cosmo.f(node.templates.REGISTRATION){
      html_for_fields = html_for_fields,
      node_name       = node.name,
      post_fields     = table.concat(field_list,","),
      post_token      = post_token,
      post_timestamp  = post_timestamp,
      submit_label     = node.translator.translate_key("CONFIRM"),
      action_url      = sputnik:make_url(node.name),
      action          = "activate",
      captcha         = "",
   }

   node:post_notice(node.translator.translate_key("PLEASE_CONFIRM_PASSWORD"))
   return node.wrappers.default(node, request, sputnik)
end

-----------------------------------------------------------------------------
-- Handles the new password entry form
-----------------------------------------------------------------------------
function actions.show_password_reset_ticket(node, request, sputnik)
   local fields = {}
   fields.new_password = request.params.new_password or ""

   local post_timestamp = os.time()
   local post_token = sputnik.auth:timestamp_token(post_timestamp)

   local html_for_fields, field_list = html_forms.make_html_form{
      field_spec = NEW_PASSWORD_FORM_SPEC,
      templates  = node.templates, 
      translator = node.translator,
      values     = fields,
      hash_fn    = function(field_name)
         return sputnik:hash_field_name(field_name, post_token)
      end
   }

   table.insert(field_list, "recaptcha_challenge_field")
   table.insert(field_list, "recaptcha_response_field")

   node.inner_html = cosmo.f(node.templates.REGISTRATION){
      html_for_fields = html_for_fields,
      node_name       = node.name,
      post_fields     = table.concat(field_list,","),
      post_token      = post_token,
      post_timestamp  = post_timestamp,
      submit_label     = node.translator.translate_key("CONFIRM"),
      action_url      = sputnik:make_url(node.name),
      action          = "reset_password",
      captcha         = "",
   }

   node:post_notice(node.translator.translate_key("PLEASE_CONFIRM_PASSWORD"))
   return node.wrappers.default(node, request, sputnik)
end

-----------------------------------------------------------------------------
-- Handles submitted activation form.
-----------------------------------------------------------------------------
function actions.fulfill_account_activation_ticket(node, request, sputnik)
   function err_msg(err_code)
      request.try_again = true
      node:post_error(node.translator.translate_key(err_code))
   end

   local password = request.params.new_password or ""
   local hash = md5.sumhexa(password)
   --local confirm, numtries, email, username = util.split(node.content, "\n")

   if node.hash ~= hash then -- wrong password
      local numtries = tonumber(node.numtries or "0") or 0
      if numtries < 3 then
         numtries = numtries + 1

         sputnik:update_node_with_params(node, {numtries = numtries + 1})
         sputnik:activate_node(node)

         err_msg("COULD_NOT_CONFIRM_NEW_PASSWORD")
         node = sputnik:save_node(node, request, "Sputnik",
            "Invalid confirmation attempt")
         return actions.show_account_activation_ticket(node, request, sputnik)
      else
         err_msg("INVALID_ACTIVATION_TICKET")
         request.params.new_username = nil
         node.inner_html = nil
         return node.wrappers.default(node, request, sputnik)
      end
   else
      -- Verify first that the account still no longer exists
      if sputnik.auth:user_exists(node.username) then
         err_msg("USERNAME_TAKEN")
         return actions.show_form(node, request, sputnik)
      else
         sputnik.auth:add_user(node.username, password, {email = node.email})
         request.user, request.auth_token = sputnik.auth:authenticate(node.username, password)   
         node:post_notice(node.translator.translate_key("SUCCESSFULLY_CREATED_ACCOUNT"))
      end
   end

   node.inner_html = ""
   return node.wrappers.default(node, request, sputnik)
end

-----------------------------------------------------------------------------
-- Handles submition of new password from a password reset ticket.
-----------------------------------------------------------------------------
function actions.fulfill_password_reset_ticket(node, request, sputnik)
   function err_msg(err_code)
      request.try_again = true
      node:post_error(node.translator.translate_key(err_code))
   end

   --local wiki = require("sputnik.actions.wiki")
   local post_ok, err = wiki.check_post_parameters(node, request, sputnik)
   if not post_ok then
      err_msg(err)
   else
      local password = request.params.new_password or ""

      if password ~= request.params.new_password_confirm then
         err_msg("TWO_VERSIONS_OF_NEW_PASSWORD_DO_NOT_MATCH")
         return actions.show_password_reset_ticket(node, request, sputnik)
      elseif not sputnik.auth:user_exists(node.username) then
         err_msg("INVALID_PASSWORD_RESET_TICKET")
         return actions.show_password_reset_ticket(node, request, sputnik)
      else
         local status = sputnik.auth:set_password(node.username, password)
         assert(status)
         request.user, request.auth_token = sputnik.auth:authenticate(node.username, password)   
         node:post_notice(node.translator.translate_key("SUCCESSFULLY_CHANGED_PASSWORD"))
      end
   end
   node.inner_html = ""
   return node.wrappers.default(node, request, sputnik)
end



