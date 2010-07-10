module(..., package.seeall)

NODE = {
 actions = [[
  show = "register.show_registration_form"
  submit = "register.submit_new_account_form"
 ]],
 --translations = [[_translations_register]],
 title = "New Account",
 permissions = [[
allow(all_users, "submit")
]]
}
