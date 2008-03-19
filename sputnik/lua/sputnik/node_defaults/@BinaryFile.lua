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
file_name = {1.0}
file_type = {1.1}
file_size = {1.2}
file_info = {virtual=true}
]=],
   edit_ui = [=[
content_hdr = nil
content = nil
file_info = {1.0, "file"}
]=],
}
