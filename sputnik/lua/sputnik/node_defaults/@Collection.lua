module(..., package.seeall)
NODE = {
   title      = "@Collection",
   actions    = [[
      show = "collections.show"
      rss = "collections.rss"
      xml = "collections.list_children_as_xml"
      new_child = "collections.edit_new_child"
   ]],
}

NODE.fields = [=[
child_proto = {1.1, proto="fallback"}
--content_template = {1.2, proto="fallback"}
xml_template = {1.3, proto="fallback"}
child_uid_format = {1.4, proto="fallback"}
]=]

NODE.admin_edit_ui = [=[
collection_section = {1.401, "div_start", id="collection_section"}
 child_proto = {1.401, "text_field"}
 --content_template = {1.402, "textarea"}
 xml_template = {1.403, "textarea"}
 child_uid_format = {1.404, "text_field"}
collection_section_end = {1.405, "div_end"}
]=]

NODE.html_content = [=[
$content

<div><a href="$new_url">New item</a></div>

<table class="sorttable" width="100%">
 <thead>
  <tr>
   <th>id</th>
   <th>title</th>
  </tr>
 </thead>
 $do_nodes[[
  <tr>
   <td><a href="$url">$id</a></td>
   <td><a href="$url">$title</a></td>
  </tr>
 ]]
 </table>
]=]

NODE.xml_template = [=[<?xml version="1.0" encoding="UTF-8"?>
 <collection id="$id">
  $do_nodes[[
  <item id="$id" title="$title"/>
  ]]
 </collection>
]=]

NODE.child_defaults = [=[
new = [[ 
prototype = "$id/@Child"
title     = "New Item"
actions   = 'save="collections.save_new"'
]]
]=]

NODE.permissions = [=[
--deny(all_users, "edit")
--deny(all_users, "save")
--deny(all_users, "history")
--deny(all_users, "rss")
--allow(Admin, "edit")
--allow(Admin, "save")
--allow(Admin, "history")
  allow(all_users, "edit")
  allow(all_users, "new_child")
]=]


