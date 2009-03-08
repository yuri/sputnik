module(..., package.seeall)
NODE = {
	prototype="@Collection"
}

NODE.child_proto = "@Discussion"

NODE.child_defaults = [=[
new = [[ 
prototype = "@Discussion"
title     = "New discussion topic"
actions   = 'save="collections.save_new"'
]]
]=]

NODE.html_content = [=[
$content
Create <a href="$new_url">new discussion topic</a>.

<br/><br/>

<table class="sorttable" width="100%">
 <thead>
  <tr>
   <th>Subject</th>
   <th>Author</th>
   <th>Posted</th>
   <th>Last Activity</th>
  </tr>
 </thead>
 $do_nodes[[
 <tr>
  <td>
   <p class="forum_subject"><a href="$url">$subject</a></p>
   <p class="forum_content">$content</a></p>
  </td>
  <td>$author</td>
  <td>$format_time{$creation_time, "%a, %d %b %Y %H:%M:%S"}</td>
  <td><a $make_link{$activity_node}>$format_time{$activity_time, "%a, %d %b %Y %H:%M:%S"}</a></td> 
 </tr>
]]
</table>
]=]
