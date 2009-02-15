module(..., package.seeall)

NODE = {
 actions = [[
  show = "wiki.show_login_form"
  --submit = "register.submit"
 ]],
 --translations = [[_translations_register]],
 title = "New Account",
 permissions = [[
allow(all_users, "submit")
]]
}
