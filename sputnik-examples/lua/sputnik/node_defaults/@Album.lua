module(..., package.seeall)
NODE = {
   title="@Album (Prototype for Albums Demo)",
   category="_prototypes",
   templates="_templates_for_album",
   description="A prototype for a photo album",
   translations = "_translations_for_album"
}
NODE.fields = [[
content.activate = "lua"
album_config = {10, activate="lua"}
]]
NODE.content=[[
rows = {}
]]
NODE.edit_ui= [[
album_config = {1.31, "textarea", rows=2}
]]
NODE.actions=[[
show="album.mixed_album"
photo="album.show_photo"
]]

