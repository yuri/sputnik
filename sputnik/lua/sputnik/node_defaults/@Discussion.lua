module(..., package.seeall)
NODE = {
prototype="@Collection"
}

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
  <div class="info">
   Posted by $author on $format_time{$creation_time, "%a, %d %b %Y %H:%M:%S"}
  </div>
  <ul class="toolbar">
   $if_user_can_edit[[<li><a href="$edit_link">_(EDIT)</a></li>]]
   $if_user_can_configure[[<li><a href="$configure_link">_(CONFIGURE)</a></li>]]
   <li><a href="$make_url{$new_id, "edit"}">_(REPLY)</a></li> 
   <li><a href="$make_url{$new_id, "edit"}">_(QUOTE)</a></li> 
  </ul>
  <div class="content">
   $markup{$content}
  </div>
 </li>
 $do_nodes[====[
 <li class="reply">
  <div class="info">
   <a name="$short_id"></a>
   Posted by $comment_author on $format_time{$comment_timestamp, "%a, %d %b %Y %H:%M:%S"}
  </div>
  <div class="toolbar">
   <ul>
    $if_user_can_edit[[<li><a href="$edit_link">_(EDIT)</a></li>]]
    $if_user_can_configure[[<li><a href="$configure_link">_(CONFIGURE)</a></li>]]
    <li><a href="$make_url{$new_id, "edit", parent_id=$short_id}">_(REPLY)</a></li> 
    <li><a href="$make_url{$new_id, "edit", parent_id=$short_id, quote="true"}">_(QUOTE)</a></li> 
   </ul>
  </div>
  <div class="content">
   $markup{$content}
  </div>
 </li>
 ]====]
</ol>
]=]
