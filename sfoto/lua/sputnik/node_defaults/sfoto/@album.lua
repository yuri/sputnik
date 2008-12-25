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
sfoto_type = {2.1, proto="fallback"}
]]
NODE.sfoto_type = "album"

NODE.child_defaults = [=[
   any = [[
      prototype = "sfoto/@album"
      actions = "show='sfoto.show_photo'; show_content='sfoto.show_photo_content';"
   ]]
]=]
NODE.permissions = [[
deny(all_users, "edit")
deny(all_users, "save")
allow(is_admin, "edit")
allow(is_admin, "save")
]]
