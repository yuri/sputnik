module(..., package.seeall)

NOCREATE = true

NODE = {
   title = [=[A prototype for binary files]=],
   content = [=[This content is never displayed]=],
   actions = [=[
show = "binaryfile.show"
save = "binaryfile.save"
]=],

   fields = [=[
file_name = {2.9}
file_type = {2.91}
file_size = {2.92}
file_upload = {virtual=true}
]=],
   edit_ui = [=[
content_hdr = nil
content = nil
file_upload = {1.30, "file"}
file_name = {2.9, "text_field", advanced = true}
file_type = {2.91, "text_field", advanced = true}
file_size = {2.92, "text_field", advanced = true}
]=],
}
