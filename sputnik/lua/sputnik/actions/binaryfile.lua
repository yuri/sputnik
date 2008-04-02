module(..., package.seeall)

actions = {}

function actions.mimetype(node, request, sputnik)
	local type = node.file_type
	local ext = sputnik.config.MIME_TYPES[type]
	if ext == request.action then
		return node.content, type
	else
		node:post_error("Requested action does not match file content: " .. tostring(node.type))
		return node.wrappers.default(node, request, sputnik)
	end
end

local TPL_FILE_INFO = [=[
<h2>File information</h2>
$img
<table><tr>
<th>Filename:</th>
<td>$filename</td>
</tr><tr>
<th>Size:</th>
<td>$size</td>
</tr><tr>
<th>Content-type:</th>
<td>$type</td>
</tr></table>
<a $link>Download this file</a>
]=]

function actions.show(node, request, sputnik)
	local ext = sputnik.config.MIME_TYPES[node.file_type or ""]

	node.inner_html = cosmo.f(TPL_FILE_INFO){
		filename = node.file_name,
		size = node.file_size,
		type = node.file_type,
		link = sputnik:make_link(node.name, "download"),
		img = function()
			if node.file_type:match("image") then
				local image_url = sputnik:make_url(node.name, ext, {version=request.params.version})
				return '<img style="float: right" src="'..image_url..'" width="350"'
			else
				return ""
			end
		end,
	}

	return node.wrappers.default(node, request, sputnik)
end

function actions.download(node, request, sputnik)
	local filename = node.file_name
	local mime = node.file_type
	-- Set the Content-disposition header, and suggest a filename
	node:add_header("Content-Disposition", "attachment; filename=\""..node.file_name.."\"")
	return node.content, mime
end

function actions.save(node, request, sputnik)
	local info = request.params.file_upload
	local type = info["content-type"]
	local name = info.name
	local size = info.size
	local file = info.contents

	-- Clear out the file_upload parameter
	request.params.file_update = nil

	-- Check to see if we're editing fields, rather than uploading
	-- a new file by checking filename and filesize.

	if name and name:match("%S") and size > 0 then
		-- A file was uploaded 

		request.params.content = info.contents
		request.params.file_type = type
		request.params.file_name = tostring(name)
		request.params.file_size = tostring(size)

		-- Set the correct action
		local ext = sputnik.config.MIME_TYPES[type]

		if not ext then
			node:post_error("The file you uploaded did not match a known file type: " .. tostring(type))
			request.try_again = true
		else
			request.params.actions = string.format([[%s = "binaryfile.mimetype"]], ext, ext)
		end
	else
		request.try_again = true
	end

	-- Was something incomplete?
	if request.try_again then
		request.params.content = nil
		request.params.file_type = nil
		request.params.file_name = nil
		request.params.file_size = nil
		return node.actions.edit(node, request, sputnik)
	else
		-- Actually try to store the node
		local new_node = sputnik:update_node_with_params(node, request.params)
		new_node = sputnik:activate_node(new_node)
		new_node:save(request.user, request.params.summary or "", {minor=request.params.minor})

		return new_node.actions.show(new_node, request, sputnik)
	end
end
