module(..., package.seeall)

function init_discussion(node, request, sputnik)
   node = sputnik:update_node_with_params(node, {
      author = request.user or "Anonymous user",
      creation_time = os.time(),
      activity_time = os.time(),
      activity_node = node.id,
   })
   return node
end

local PARENT_PATTERN = "(.+)%/[^%/]+$" -- everything up to the last slash

function init_comment(node, request, sputnik)
   node = sputnik:update_node_with_params(node, {
      comment_date = os.date("%Y/%m/%d %H:%M"),
   })
   
   local parent_id = node.id:match(PARENT_PATTERN)
   local parent = sputnik:get_node(parent_id)
   parent = sputnik:update_node_with_params(parent, {
      activity_time = os.time(),
      activity_node = node.id,
   })
   parent = sputnik:activate_node(parent)
   parent:save("Sputnik", "Updating activity time and node", {})

   return node
end
