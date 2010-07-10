module(..., package.seeall)
NODE = {
   title = "Reset Password",
}
NODE.permissions= [[
   allow(all_users, "submit")
]]
NODE.actions= [[
  show = "register.show_password_reset_ticket"
  submit = "register.fulfill_password_reset_ticket"
]]
NODE.fields = [[
  hash = {100}
  username = {101}
  email = {102}
  numtries = {103}
  invalidated = {104}
  expiration_time = {105}
]]
NODE.edit_ui = [[
  reset()
  username = {1, "readonly_text"}
  email    = {2, "readonly_text"}
  hash     = {3, "readonly_text"}
  numtries = {4, "text_field"}
  invalidated = {5, "readonly_text"}
  expiration_time = {6, "readonly_text"}
]]

