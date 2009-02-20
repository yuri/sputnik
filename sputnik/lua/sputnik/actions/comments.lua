
module(..., package.seeall)

local wiki = require("sputnik.actions.wiki")
local util = require("sputnik.util")

actions = {}

local PARENT_PATTERN = "(.+)%/[^%/]+$" -- everything up to the last slash

actions.save_new = function(node, request, sputnik)
   local parent_id = node.id:match(PARENT_PATTERN)
   local parent = sputnik:get_node(parent_id)
   local new_id = string.format("%s/%06d", parent_id, sputnik:get_uid(parent_id))
   local new_node = sputnik:get_node(new_id)
   sputnik:update_node_with_params(new_node, {prototype = "@Comment"})
   sputnik:update_node_with_params(new_node, {comment_date = os.date("%Y/%M/%d %H:%m")})
   request.params.actions = ""
   new_node = sputnik:activate_node(new_node)

   node:redirect(sputnik:make_url(parent_id))
   return wiki.actions.save(new_node, request, sputnik)
end
