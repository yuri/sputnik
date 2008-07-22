module(..., package.seeall)
NODE = {
   title="2007",
   templates = "sfoto/templates",
}
NODE.fields = [[
content.activate = "lua"
]]
NODE.actions = [[
show="sfoto.show"
]]

NODE.content = [===[

data = {
   {id="2007-12-31-a-times-square", title="Times Square Before New Year", thumb="20071231_019_2248"},
   {id="2007-12-31-b-new-years-eve", title="New Year's Eve", thumb="20071231_053_9414", private="1"},
   {id="2007-12-30-dinner", title="Salmon with Ginger-Lime Sauce", thumb="20071230_004_5427", private="1"},
   {id="2007-12-29-b-brighton", title="A Trip to Brighton Beach", thumb="20071229_010_3199"},
   {id="2007-12-29-a-robes", title="Andrei and Luisa", thumb="20071229_001_9499", private="1"},
   {id="2007/12/27/bangalore_city_market", type="blog", title="Bangalore City Market"},
}

]===]
