module(..., package.seeall)
NODE = {
   title="Basic Script",
   prototype="@JavaScript",
   category="_prototypes",
}

NODE.actions = [[
   validate_lua = "wiki.validate_lua"
   js = "javascript.configured_js"
]]
NODE.permissions = [[
   allow(all_users, "validate_lua")
]]

NODE.content = [======[

$modernizr

]======]
