module(..., package.seeall)
NODE = {
   title="sfoto/@album",
   templates="sfoto/templates",
}
NODE.actions = [[
show="sfoto.show_album"
show_content='sfoto.show_album_content'
]]
NODE.fields = [[
content.activate = "lua"
]]

NODE.child_defaults = [=[
   any = [[
      prototype = "sfoto/@album"
      actions = "show='sfoto.show_photo'"
   ]]
]=]
NODE.permissions = [[
deny(all_users, "edit")
deny(all_users, "save")
]]
