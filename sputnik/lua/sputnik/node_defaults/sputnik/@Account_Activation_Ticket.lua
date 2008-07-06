module(..., package.seeall)
NODE = {
   title = "New Account Activation",
}
NODE.permissions= [[
   --deny(all_users, "edit")
   allow(all_users, "activate")
]]
NODE.actions= [[
  show = "register.confirm"
  activate = "register.activate"
  submit = "register.submit"
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

