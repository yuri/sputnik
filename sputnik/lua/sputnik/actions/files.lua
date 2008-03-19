module(..., package.seeall)

actions = {}

local types = {
	["image/png"] = "png"
}

function actions.png(node, request, sputnik)
	return node.file_payload, "image/png"
end

function actions.save(node, request, sputnik)
	-- Fetch the node name from the post
	local name = request.params.node_name
	local file = request.params.file_info

	request.params.file_name = file.filename
	request.params.file_type = file["content-type"]
	request.params.file_payload = file.file:read("*all")
	request.params.file_size = tostring(file.filesize)
	request.params.prototype = "@Upload"
	local ext = types[request.params.file_type]
	request.params.actions = ([[show = "files.%s" %s = "files.%s"]]):format(ext, ext, ext)

	local new_node = sputnik:get_node(name)
	new_node = sputnik:update_node_with_params(new_node, request.params)
	new_node = sputnik:activate_node(new_node)

	new_node:save(request.user, request.params.summary, {minor=request.params.minor})

	new_node:post_notice(string.format("Saved file %s with size %s and content %s", 
	request.params.file_name,
	request.params.file_size,
	request.params.file_type
	))
	new_node:post_notice(string.format("Payload was %d characters", #request.params.file_payload))
	
	new_node.inner_html = "<a " .. sputnik:make_link(name) .. ">" .. name .. "</a>"

	return new_node.wrappers.default(new_node, request, sputnik)
	--return new_node.actions.show(new_node, request, sputnik)
end

