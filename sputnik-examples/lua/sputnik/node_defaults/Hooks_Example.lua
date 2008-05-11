-----------------------------------------------------------------------------
-- This is a sample node that shows / tests Sputnik's pre- and post- action
-- hooks.
-- For more information, see http://sputnik.freewisdom.org/en/Hooks
--
-- (c) 2008  Yuri Takhteyev (yuri@freewisdom.org)
-- License: MIT/X, see http://sputnik.freewisdom.org/en/License
-----------------------------------------------------------------------------

module(..., package.seeall)

NODE = {
   title="Hooks Example"
}

NODE.content=[===[

This node shows hooks in action.  If you are seeing this message then this example isn't working.

]===]

-- This is the interesting part
NODE.actions = [[
show_content = "hooks.show_content"
]]
NODE.action_hooks = [[
show = {
before = {
"hooks.before_show",
},
--after = {
--"hooks.after_show",
--},
}
]]
