module(..., package.seeall)
NODE = {}

NODE.fields = [[
comment_parent = {}
comment_author = {}
comment_timestamp = {}
]]

NODE.actions = [[
  show = "comments.show_comment"
  edit = "comments.edit_comment"
]]

NODE.save_hook = "forums.save_comment"

NODE.edit_ui = [[
reset()
comment_parent = {3.00, "hidden", div_class="hidden", no_label=true}
--comment_author = {3.001, "text_field"}
--title          = {3.002, "text_field"}
content        = {3.01, "textarea", rows=15, no_label=true, editor_modules = {"resizeable"}}
]]
NODE.admin_edit_ui = [[
comment_section  = {1.401, "div_start", id="comment_section", closed="true"}
 comment_parent = {1.402, "text_field"}
 comment_author = {1.403, "text_field"}
comment_section_end = {1.404, "div_end"}
]]
