
module(..., package.seeall)

NODE = {
   title="World Clock",
   actions=[[show="worldclock.full_html"; show_content="worldclock.show_content"]],
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

