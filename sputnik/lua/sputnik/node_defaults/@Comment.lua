module(..., package.seeall)
NODE = {
}

NODE.fields = [[
comment_parent = {}
comment_author = {}
comment_date = {}
]]

NODE.edit_ui = [[
reset()
comment_parent = {3.00, "hidden", no_label=true}
comment_author = {3.001, "text_field"}
title          = {3.002, "text_field"}
content        = {3.01, "textarea", rows=15, no_label=true, editor_modules = {"resizeable"}}
]]
