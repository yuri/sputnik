module(..., package.seeall)

actions = {}

local types = {
   ["image/png"] = "png",
   ["application/pdf"] = "pdf",
   ["image/jpeg"] = "jpg",
   ["image/gif"] = "gif",
   ["text/plain"] = "txt",
}

for mime,extension in pairs(types) do
   actions[extension] = function(node, request, sputnik)
      if node.file_type == mime then
	 local func = loadstring("return " .. node.content)
	 local succ,err = pcall(func)
	 if succ then
	    return err, mime
	 else
	    node:post_error("There was an error expanding the stored file: " .. tostring(err))
	 end
      else
	 node:post_error("Requested action does not match file content: " .. tostring(node.type))
      end

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
   local ext = types[node.file_type or ""]

   node.inner_html = cosmo.f(TPL_FILE_INFO){
      filename = node.file_name,
      size = node.file_size,
      type = node.file_type,
      link = sputnik:make_link(node.name, "download"),
      img = function()
	 if node.file_type:match("image") then
	    return string.format([[<img style="float: right" src="%s" width="350"]], sputnik:make_url(node.name, ext))
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

   local func = loadstring("return " .. node.content)
   local succ,err = pcall(func)
   if succ then
      -- Set the Content-disposition header, and suggest a filename
      node:add_header("Content-Disposition", "attachment; filename=\""..node.file_name.."\"")
      return err, mime
   else
      node:post_error("There was an error expanding the stored file: " .. tostring(err))
   end
end

function actions.save(node, request, sputnik)
   local info = request.params.file_upload
   local type = info["content-type"]
   local name = info.filename
   local size = info.filesize
   local file = info.file

   -- Clear out the file_upload parameter
   request.params.file_update = nil

   -- Check to see if we're editing fields, rather than uploading
   -- a new file by checking filename and filesize.

   if name:match("%S") and size > 0 then
      -- A file was uploaded 

      file:seek("set");
      local data = file:read("*all")

      request.params.content = string.format("%q", data)
      request.params.file_type = type
      request.params.file_name = tostring(name)
      request.params.file_size = tostring(size)

      -- Set the correct action
      local ext = types[type]

      if not ext then
	 node:post_error("The file you uploaded did not match a known file type: " .. tostring(type))
	 return node.actions.edit(node, request, sputnik)
      end

      request.params.actions = string.format([[%s = "binaryfile.%s"]], ext, ext)
   end

   -- Was something incomplete?
   if request.try_again then
      return node.actions.edit(node, request, sputnik)
   else
      -- Actually try to store the node
      local new_node = sputnik:update_node_with_params(node, request.params)
      new_node = sputnik:activate_node(new_node)
      new_node:save(request.user, request.params.summary or "", {minor=request.params.minor})

      return new_node.actions.show(new_node, request, sputnik)
   end
end
