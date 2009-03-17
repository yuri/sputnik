module(..., package.seeall)

function save_discussion(node, request, sputnik)
   request = request or {}
   local params = {
      author = request.user or "Anonymous user",
      creation_time = tostring(os.time()),
      activity_time = tostring(os.time()),
      activity_node = node.id,
   }
   local title = request.params.title or node.title
   if #node.title > 25 then
      params.breadcrumb = title:sub(1, 25) .. "..."
   else
      params.breadcrumb = title
   end

   node = sputnik:update_node_with_params(node, params)
   return node
end

local PARENT_PATTERN = "(.+)%/[^%/]+$" -- everything up to the last slash

function save_comment(node, request, sputnik)
   request = request or {}

   -- Update the parameters of the node being saved
   node = sputnik:update_node_with_params(node, {
      comment_timestamp = tostring(os.time()),
   })
   
   -- Update the parent node before returning from the hook
   local parent_id = node.id:match(PARENT_PATTERN)
   local parent = sputnik:get_node(parent_id)
   parent = sputnik:update_node_with_params(parent, {
      activity_time = tostring(os.time()),
      activity_node = node.id,
   })
   parent = sputnik:activate_node(parent)
   parent:save("Sputnik", "Updating activity time and node", {})

   return node
end
