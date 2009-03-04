module(..., package.seeall)

NODE = {
   prototype = "@Text_Config",
   title="@Lua_Config (Prototype for Lua Config Files)",
   fields = [[content.activate = "lua"]],
   permissions = [[
deny(all_users, all_actions)
allow(Admin, all_actions)
allow(all_users, "login")
allow(all_users, "logout")
--allow(all_users, "show")
allow(all_users, "history")
]],
   category="_prototypes",
   actions=[[show_content="wiki.show_content_as_lua_code"]],
   icon = "icons/lua.png",
}
NODE.content=[===[
--The content of this page is ignored but it's fields are inherited by 
--some of the other pages of this wiki.
]===]
NODE.edit_ui=[[
content.editor_modules = {"validatelua", "resizeable"}
]]
NODE.admin_edit_ui=[[
content.editor_modules = {"validatelua", "resizeable"}
]]
