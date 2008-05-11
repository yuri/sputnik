-----------------------------------------------------------------------------
-- This is a sample action for the "hooks" example.
-- For more information, see http://sputnik.freewisdom.org/en/Hooks
--
-- (c) 2008  Yuri Takhteyev (yuri@freewisdom.org)
-- License: MIT/X, see http://sputnik.freewisdom.org/en/License
-----------------------------------------------------------------------------

module(..., package.seeall)

actions = {}

function actions.before_show(node, request, sputnik)
   node.foo = "This node shows hooks in action. If you are seeing this, then 'before_show' action is working."
end

function actions.show_content(node, request, sputnik)
   return node.foo or "Whoops, looks like this example isn't working."
end
