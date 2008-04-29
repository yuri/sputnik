module(..., package.seeall)

NODE = {
   title = [=[A prototype for binary files]=],
   content = [=[This content is never displayed]=],
   icon = "icons/picture",
   actions = [=[
show = "binaryfile.show"
save = "binaryfile.save"
download = "binaryfile.download"
]=],
permissions = [=[
allow(all_users, "jpg")
allow(all_users, "gif")
allow(all_users, "png")
allow(all_users, "zip")
allow(Admin, all_actions)
]=],
   fields = [=[
file_description = {1.31}
file_copyright = {1.32}
file_name = {2.9}
file_type = {2.91}
file_size = {2.92}
file_upload = {2.93, virtual = true}
]=],
   edit_ui = [=[
content_hdr = nil
content = nil
file_upload = {1.30, "file"}
file_description = {1.31, "text_field"}
file_copyright = {1.32, "text_field"}
]=],
   admin_edit_ui = [=[
content_hdr = nil
content = nil
file_upload = {1.30, "file"}
file_description = {1.31, "text_field"}
file_copyright = {1.32, "text_field"}
file_name = {1.33, "text_field", advanced = true}
file_type = {1.34, "text_field", advanced = true}
file_size = {1.35, "text_field", advanced = true}
]=],
}
