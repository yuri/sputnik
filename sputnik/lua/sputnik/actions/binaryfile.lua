module(..., package.seeall)

require("mime")
require("ltn12")

local base64_wrap = ltn12.filter.chain(mime.encode("base64"), mime.wrap("base64"))

actions = {}

function actions.mimetype(node, request, sputnik)
	local type = node.file_type
	local ext = sputnik.config.MIME_TYPES[type]
	if ext == request.action then        
        return mime.unb64(node.content), type
	else
		node:post_error("Requested action does not match file content: " .. tostring(node.type))
		return node.wrappers.default(node, request, sputnik)
	end
end

local TPL_FILE_INFO = [=[
<h2>File information</h2>

$if_image[[<a href="$url"><img style="float: right; max-width:300px; margin: 2em;" src="$url"/></a>]]

<table>
<tr><th>Filename</th><td>$filename</td></tr>
<tr><th>Size</th><td>$size</td></tr>
<tr><th>Content-type</th><td>$type</td></tr>
</table>

<p><a class="button" $link>Download this file</a></p>

]=]

function actions.show(node, request, sputnik)
	local ext = sputnik.config.MIME_TYPES[node.file_type or ""]

	node.inner_html = cosmo.f(TPL_FILE_INFO){
		filename = node.file_name,
		size = node.file_size,
		type = node.file_type,
		link = sputnik:make_link(node.name, "download"),
        if_image = cosmo.c(node.file_type:match("image")){
                      url = sputnik:make_url(node.name, ext, {version=request.params.version})
        }
	}

	return node.wrappers.default(node, request, sputnik)
end

function actions.download(node, request, sputnik)
	local filename = node.file_name
	local mime_type = node.file_type
	-- Set the Content-disposition header, and suggest a filename
	node:add_header("Content-Disposition", "attachment; filename=\""..node.file_name.."\"")
	return mime.unb64(node.content), mime_type
end

function actions.save(node, request, sputnik)
   local info = request.params.file_upload

   if info then
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

         request.params.content = base64_wrap(info.contents)
         request.params.file_type = type
         request.params.file_name = tostring(name)
         request.params.file_size = tostring(size)

         -- Set the correct action
         local ext = sputnik.config.MIME_TYPES[type]

         if not ext and sputnik.auth:get_metadata(request.user, "is_admin") ~= "true" then
            node:post_error("The file you uploaded did not match a known file type: " .. tostring(type))
            request.try_again = true
         elseif ext then
            request.params.actions = string.format([[%s = "binaryfile.mimetype"]], ext, ext)
         end
      elseif node.content:match("%S") then
         -- Do nothing
      else
         request.try_again = true
      end
   else
      node:post_error("Did not receive a file in the request")
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
      new_node = sputnik:save_node(new_node, request, request.user, 
      request.params.summary or "", {minor=request.params.minor}) 
      request.redirect = sputnik:make_url(new_node.name)	
      return
   end
end
