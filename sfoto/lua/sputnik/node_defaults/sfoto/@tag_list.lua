module(..., package.seeall)
NODE = {
   title="sfoto/@tag",
   templates="sfoto/templates",
}
NODE.fields = [[
  content.activate="lua"
]]
NODE.actions = [[
show = "sfoto.show_tag_list"
]]
NODE.permissions = [[
deny(all_users, "edit")
deny(all_users, "save")
allow(Admin, "edit")
allow(Admin, "save")
]]

NODE.admin_edit_ui  = [[
content[2] = "textarea"
]]
NODE.child_defaults = [[
  any = [=[
    prototype="sfoto/@index"
  ]=]
]]



