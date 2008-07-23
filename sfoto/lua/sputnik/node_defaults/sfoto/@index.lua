module(..., package.seeall)
NODE = {
   templates = "sfoto/templates",
}
NODE.fields = [[
content.activate = "lua"
]]
NODE.actions = [[
show="sfoto.show"
]]

