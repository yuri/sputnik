module(..., package.seeall)

NODE = {
   title="Passwords",
   category="_special_pages",
   prototype="@Lua_Config",
   permissions=[[
      deny(all, "raw")
      allow("Admin", "raw")
      deny(all, "raw_content")
      allow("Admin", "raw_content")
   ]],
   actions = [[
      show="wiki.show_users"
   ]]
}
NODE.content=[============[
USERS = {}
]============]
