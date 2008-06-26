
module(..., package.seeall)

NODE = {
   title="World Clock",
   templates="_templates_for_world_clock",
   prototype="@Lua_Config",
}
NODE.content = [=============[cities = {
 {"Vladivostok",     10},
 {"Rio de Janeiro", -2},
 {"San Francisco",  -8},
 {"Novosibirsk",     6},
 {"New York",       -5},
 {"Madison",        -6}, 

}
start = -8
timeout = 5
local_tz = -5
]=============]
NODE.actions=[[
show="worldclock.full_html"
show_content="worldclock.show_content"
]]
NODE.permissions=[[
allow(all_users, "show")
allow(all_users, "edit")
allow(all_users, "save")
allow(all_users, "show_content")
]]
