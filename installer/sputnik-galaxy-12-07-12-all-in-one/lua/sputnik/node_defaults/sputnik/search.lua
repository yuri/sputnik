module(..., package.seeall)

NODE = {
   title="Search",
   prototype="@Lua_Config",
   actions=[[show="search.show_results"]]
}
NODE.permissions = [[
   allow(all_users, "show")
]]

