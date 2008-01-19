
module(..., package.seeall)

NODE = {
   title="World Clock",
   actions=[[show="worldclock.full_html"; show_content="worldclock.show_content"]],
   templates="_templates_for_world_clock",
}
NODE.content = [=============[cities = {
 {"Vladivostok",     10},
 {"Rio de Janeiro", -3},
 {"San Francisco",  -7},
 {"Novosibirsk",     6},
 {"New York",       -4},
 {"Madison",        -5}, 

}
start = -8
timeout = 5
local_tz = -3
]=============]

