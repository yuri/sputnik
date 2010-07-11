module(..., package.seeall)

NODE = {
 actions = [[
  show = "register.show_registration_form"
  submit = "register.submit_registration_form"
 ]],
 --translations = [[_translations_register]],
 title = "New Account",
 permissions = [[
allow(all_users, "submit")
]]
}
