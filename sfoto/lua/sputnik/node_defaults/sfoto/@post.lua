module(..., package.seeall)
NODE = {
   title="sfoto/@post",
   templates="sfoto/templates",
}
NODE.actions = [[
show="sfoto.show_entry"
show_content='sfoto.show_entry_content'
]]
NODE.permissions = [[
deny(all_users, "edit")
deny(all_users, "save")
]]

