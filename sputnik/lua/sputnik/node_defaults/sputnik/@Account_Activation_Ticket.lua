module(..., package.seeall)
NODE = {
   title = "New Account Activation",
}
NODE.permissions= [[
   allow(all_users, "submit")
]]
NODE.actions= [[
  show = "register.show_account_activation_ticket"
  submit = "register.fulfill_account_activation_ticket"
]]
NODE.fields = [[
  hash = {100}
  username = {101}
  email = {102}
  numtries = {103}
]]
NODE.edit_ui = [[
  reset()
  username = {1, "readonly_text"}
  email    = {2, "readonly_text"}
  hash     = {3, "readonly_text"}
  numtries = {4, "text_field"}
  invalidated = {5, "readonly_text"}
]]

