module(..., package.seeall)

function save_discussion(node, request, sputnik)
   request = request or {}
   local params = {}

   -- If the node is being saved, set initial params
   if not node.creation_time then
       params.author = request.user or "Anonymous user"
       params.creation_time = tostring(os.time())
       params.activity_time = tostring(os.time())
       params.activity_node = node.id
       params.activity_author = request.user or "Anonymous User"
   end

   local title = request.params.title or node.title
   if #node.title > 25 then
      params.breadcrumb = title:sub(1, 25) .. "..."
   else
      params.breadcrumb = title
   end

   -- Generate a snippet for the content by stripping markup and trimming
   local snippet = node.content:gsub("%b<>", ""):gsub("%b[]", "")
   if #snippet > 250 then
      params.snippet = snippet:sub(1, 250) .. "..."
   else
      params.snippet = snippet
   end

   node = sputnik:update_node_with_params(node, params)
   return node
end

local PARENT_PATTERN = "(.+)%/[^%/]+$" -- everything up to the last slash

function save_comment(node, request, sputnik)
   request = request or {}

   -- Only update the timestamp/author when saving, not when editing
   if not node.comment_timestamp then
       -- Update the parameters of the node being saved
       node = sputnik:update_node_with_params(node, {
           comment_timestamp = tostring(os.time()),
           comment_author = request.user or "Anonymous User",
       })
   
       -- Update the parent node before returning from the hook
       local parent_id = node.id:match(PARENT_PATTERN)
       local parent = sputnik:get_node(parent_id)
       parent = sputnik:update_node_with_params(parent, {
           activity_time = tostring(os.time()),
           activity_node = node.id,
           activity_author = request.user or "Anonymous User",
       })
       parent = sputnik:activate_node(parent)
       parent:save("Sputnik", "Updating activity time and node", {})
   end
   return node
end
