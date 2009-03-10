module(..., package.seeall)

function save_discussion(node, request, sputnik)
   request = request or {}
   node = sputnik:update_node_with_params(node, {
      author = request.user or "Anonymous user",
      creation_time = os.time(),
      activity_time = os.time(),
      activity_node = node.id,
   })
   return node
end

local PARENT_PATTERN = "(.+)%/[^%/]+$" -- everything up to the last slash

function save_comment(node, request, sputnik)
   request = request or {}

   -- Update the parameters of the node being saved
   node = sputnik:update_node_with_params(node, {
      comment_date = os.date("%Y/%m/%d %H:%M"),
   })
   
   -- Update the parent node before returning from the hook
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
