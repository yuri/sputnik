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
$markup{$content}

<p><a href="$new_url">_(ADD_NEW_DISCUSSION_TOPIC)</a></p>

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
   <div class="disc_info"><a href="$url">$title</a> posted by $author</div>
   <div class="disc_snippet">$markup{$content}</div>
  </td>
  <td><a href="$make_url{$activity_node}">$format_time{$activity_time, "%a, %d %b %Y %H:%M:%S"}</a></td> 
 </tr>
]]
</table>
]=]
