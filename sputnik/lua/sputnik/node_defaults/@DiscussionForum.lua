module(..., package.seeall)
NODE = {
	prototype="@Collection"
}

NODE.child_proto = "@Discussion"
NODE.child_uid_format = "%d"

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

<table class="sorttable" width="100%">
 <thead>
  <tr>
   <th>Subject</th>
   <th>Last Post</th>
  </tr>
 </thead>
 $do_nodes[[
 <tr>
  <td>
   <div class="disc_info"><a href="$url">$subject</a> posted by $author</div>
   <div class="disc_snippet">$content</div>
  </td>
  <td><a href="$make_url{$activity_node}">$format_time{$activity_time, "%a, %d %b %Y %H:%M:%S"}</a></td> 
 </tr>
]]
</table>
]=]
