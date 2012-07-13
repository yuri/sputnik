module(..., package.seeall)

NODE = {
 actions = [[
  show = "register.show_password_reset_form"
  submit = "register.create_password_reset_ticket"
 ]],
 --translations = [[_translations_register]],
 title = "Password Reset",
 permissions = [[
allow(all_users, "submit")
]]
}
