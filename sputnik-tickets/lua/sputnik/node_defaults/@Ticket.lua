module(..., package.seeall)
NODE = {
   icon = "icons/bug.png",
   translations = "tickets/translations",
   templates    = "tickets/templates",
   prototype = "@Discussion",
}

NODE.permissions = [[
   allow(all_users, "raw")
]]

NODE.fields= [[
reported_by = {.11}
priority    = {.13}
status      = {.14} 
resolution  = {.151}
milestone   = {.15}
prod_version = {.16}
component   = {.17}
assigned_to = {.19}
resolution_details = {.20}
]]

NODE.template_helpers = [[
function priority_to_stars(params)
   local config = {
     unassigned = "",
     highest    = "★★★★",
     high       = "★★★ ",
     medium     = "★★",
     low        = "★",
     lowest     = ".",
   }
   return config[params[1] ] or ""
end
]]

NODE.edit_ui= [[

title[1] = 1.1

reported_by = {1.31, "text_field"}
assigned_to = {1.331, "text_field"}
status      = {1.34, "select"}
status.options  ={"open", "someday", "resolved", "closed"}
resolution  = {1.35, "select"}
resolution.options = {"n.a.", "fixed", "wontfix"}

priority    = {2.21, "select" }
priority.options={"unassigned", "high", "medium", "low"}
resolution_details = {2.22, "textarea", rows=3}
component   = {2.23, "text_field"}
page_name   = null
category    = null
breadcrumb  = null

]]

NODE.html_content = [======[
<table width="100%">
 <tr style="background:$ticket_status_color">
  <td width="15%" style="text-align: right;">
	   <span style="font-size: 80%">ticket id</span><br/>
   <span style="font-size: 200%;">$id</span>
  </td>
  <td width="15%" style="text-align: right;">
   <span style="font-size: 80%">status</span><br/>
   <span style="font-size: 200%">$status</span>
  </td>
  <td width="15%" style="text-align: right;">
   <span style="font-size: 80%">priority $priority</span><br/>
   <span style="font-size: 200%">$priority_to_stars{$priority}</span>
  </td>
  <td width="15%" style="text-align: right;">
   <span style="font-size: 80%">assigned to</span><br/>
   <span style="font-size: 200%">$assigned_to</span>
  </td>
  <td width="40%" style="text-align: right;">
   Reported by: $reported_by<br/>
   Component: $component
  </td>
 </tr>
</table>
<br/>

$markup{$content}

<br/><br/><br/>
<a href="$make_url{$new_id, "edit", comment_parent=$id}">Post a comment</a>
<br/><br/><br/>

<ol class="discussion">
 $do_nodes[====[
 <a name="$short_id"></a><li class="reply">
  <div class="post-header">
  <span class="post-info">
   Posted by $comment_author on $format_time{$creation_time, "%a, %d %b %Y %H:%M:%S"}
  </span>
  <ul class="post-toolbar">
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

<br/>
]======]
