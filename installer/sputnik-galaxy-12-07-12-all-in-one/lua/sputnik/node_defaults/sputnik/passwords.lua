module(..., package.seeall)

NODE = {
   title="Passwords",
   category="_special_pages",
   prototype="@Lua_Config",
   permissions=[[
deny(all_users, all_actions)
allow(Admin, all_actions)
allow(all_users, "login")
]],
   actions = [[
      show="wiki.show_users"
      save="wiki.save_and_reload"
   ]]
}
NODE.content=[============[
USERS = {}
]============]

