module(..., package.seeall)
NODE = {
prototype="@Collection"
}

NODE.child_uid_format = "%d"

NODE.save_hook = "forums.save_discussion"
NODE.fields = [[
 subject = {1.1}
 content = {1.2}
 author = {1.3}
 creation_time = {1.4}
 activity_time = {1.5}
 activity_node = {1.6}
]]
NODE.edit_ui = [[
 local origContent = content
 reset()
 prototype = {1.0, "hidden", div_class="hidden"}
 subject = {1.1, "text_field"}
 content = origContent
 content[1] = 1.2
]]
NODE.admin_edit_ui = [[
disc_section  = {1.410, "div_start", id="disc_section", closed="true"}
 author = {1.412, "text_field"}
 creation_time = {1.413, "text_field"}
 activity_time = {1.414, "text_field"}
 activity_node = {1.415, "text_field"}
disc_section_end = {1.416, "div_end"}
]]
NODE.child_proto = "@Comment"

NODE.child_defaults = [=[
new = [[ 
prototype = "@Comment"
title     = "New Reply"
actions   = 'save="collections.save_new"'
]]
]=]

NODE.html_content = [=[
<ol class="discussion">
 <li class="origpost">
  <div class="header">
   Posted by $author on $format_time{$creation_time, "%a, %d %b %Y %H:%M:%S"}
  <ul class="toolbar">
   $if_user_can_edit[[<li><a href="$edit_link">_(EDIT)</a></li>]]
   $if_user_can_configure[[<li><a href="$configure_link">_(CONFIGURE)</a></li>]]
   <li><a href="$make_url{$new_id, "edit", comment_parent=$id}">_(REPLY)</a></li> 
   <li><a href="$make_url{$new_id, "edit", comment_parent=$id, quote="true"}">_(QUOTE)</a></li> 
  </ul>
  </div>
  <div class="content">
   $markup{$content}
  </div>
 </li>
 $do_nodes[====[
 <li class="reply">
  <div class="header">
   Posted by $author on $format_time{$creation_time, "%a, %d %b %Y %H:%M:%S"}
  <ul class="toolbar">
   $if_user_can_edit[[<li><a href="$edit_link">_(EDIT)</a></li>]]
   $if_user_can_configure[[<li><a href="$configure_link">_(CONFIGURE)</a></li>]]
   <li><a href="$make_url{$new_id, "edit", comment_parent=$id}">_(REPLY)</a></li> 
   <li><a href="$make_url{$new_id, "edit", comment_parent=$id, quote="true"}">_(QUOTE)</a></li> 
  </ul>
  </div>
  <div class="content">
   $markup{$content}
  </div>
 </li>
 ]====]
</ol>
]=]
