module(..., package.seeall)

NOCREATE = true

NODE = {
	title = [=[Upload form for files]=],
	fields = [=[
file_name = {1.0}
file_type = {1.1}
file_payload = {1.2}
file_size = {1.3}
file_info = {virtual=true}
node_name = {1.5}
]=],
	edit_ui = [=[
file_info = {1.0, "file"}
node_name = {1.1, "text_field"}
]=],
	actions = [=[
show = "wiki.edit"
save = "files.save"
]=], 
	content = [=[This is dummy content that is never shown]=],
}
