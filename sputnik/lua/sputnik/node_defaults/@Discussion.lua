module(..., package.seeall)
NODE = {
prototype="@Collection"
}

NODE.child_uid_format = "%d"
NODE.translations = "sputnik/translations/forums"
NODE.save_hook = "forums.save_discussion"
NODE.sort_params = [[
 sort_key = "creation_time"
 sort_type = "string"
]]
NODE.fields = [[
 activity_time = {1.5}
 activity_node = {1.6}
 activity_author = {1.7}
 snippet = {1.8}
]]
NODE.edit_ui = [[
 local origContent = content
 reset()
 prototype = {1.0, "hidden", div_class="hidden"}
 title = {1.1, "text_field"}
 content = origContent
 content[1] = 1.2
]]
NODE.admin_edit_ui = [[
disc_section  = {1.410, "div_start", id="disc_section", closed="true"}
 activity_time = {1.414, "text_field"}
 activity_node = {1.415, "text_field"}
 activity_author = {1.416, "text_field"}
 snippet = {1.417, "textarea", editor_modules = {"resizeable"}}
disc_section_end = {1.418, "div_end"}
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
  <div class="content">
   $markup{$content}
  </div>
  <span class="post-info">
   Posted 
   $if_creator[=====[by $if_creator_link[====[<a $creator_link>]====]$creator$if_creator_link[====[</a>]====] ]=====]
   on $format_time{$creation_time, "%a, %d %b %Y %H:%M:%S"}
  </span>

<h2 id="comments_heading">Comments</h2>

<div class="comments">
 $do_nodes[======[
 <article id="$short_id" class="comment reply">
  <header class="post-header">
      <span class="comment_id">$short_id</span>
      <span class="comment_info">
       Posted
       $if_creator[=====[by $if_creator_link[====[<a $creator_link>]====]$creator$if_creator_link[====[</a>]====] ]=====]
       on $format_time{$creation_time, "%a, %d %b %Y %H:%M:%S"}
      </span>
  </header>
  <div class="content">
   $markup{$content}
  </div>
  <ul class="post-toolbar">
   $if_user_can_edit[[<li><a href="$edit_link">_(EDIT)</a></li>]]
   $if_user_can_configure[[<li><a href="$configure_link">_(CONFIGURE)</a></li>]]
   <li><a href="$make_url{$new_id, "edit_new", comment_parent=$id}">_(REPLY)</a></li> 
   <li><a href="$make_url{$new_id, "edit_new", comment_parent=$id, quote="true"}">_(QUOTE)</a></li> 
  </ul>
 </article>
 ]======]
</div>

<ul class="post-toolbar">
   <li><a href="$make_url{$new_id, "edit_new", comment_parent=$id}">_(TOP_REPLY)</a></li> 
   <li><a href="$make_url{$new_id, "edit_new", comment_parent=$id, quote="true"}">_(TOP_QUOTE)</a></li> 
</ul>

]=]
