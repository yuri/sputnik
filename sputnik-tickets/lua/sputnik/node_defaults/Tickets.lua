module(..., package.seeall)
NODE = {
   title      = "Tickets",
   --actions    = [[show = "tickets.list"]],
   templates  = "tickets/templates",
   prototype  = "@Collection",
}

NODE.config = [[
status_colors = {
   resolved   = "#f0fff0",
   someday        = "#f0f0ff",
   open   = "#fffff0",
   closed     = "#c0c0c0",
}

priority_to_number = {
   unassigned = "",
   highest    = "★★★★",
   high       = "★★★ ",
   medium     = "★★",
   low        = "★",
   lowest     = ".",
}

priority_colors = {
   unassigned = "",
   highest    = "orange",
   high       = "#ffff30",
   medium     = "white",
   low        = "#f8f8f8",
   lowest     = "#f5f5f5",
}

status_to_number = {
   new        = "1",
   confirmed  = "2",
   assigned   = "3",
   wontfix    = "4",
   fixed      = "5",
   tested     = "6",
}
]]

NODE.child_defaults = [=[
new = [[ 
prototype = "@Ticket"
title     = "New Ticket"; 
actions   = 'save="collections.save_new"'
]]
]=]

NODE.permissions = [=[
deny(all_users, "edit")
deny(all_users, "save")
deny(all_users, "history")
deny(all_users, "rss")
allow(Admin, "edit")
allow(Admin, "save")
allow(Admin, "history")
]=]

NODE.template_helpers = [=[
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

]=]

NODE.html_content = [======[

<a href="$new_url">new ticket</a>

<br/><br/>

<table class="sortable" width="100%">
 <thead>
  <tr>
   <th>&nbsp;</th>
   <th>id</th>
   <th>priority</th>
   <th>issue</th>
   <th>assigned to</th>
  </tr>
 </thead>
 $do_nodes[[
  <tr>
   <td><a href="$url{}.edit"><img src="$make_url{"icons/edit"}.png"/></a></td>
   <td><a href="$url">$short_id</a></td>
   <td>$priority_to_stars{$priority}</td>
   <td>$title</td>
   <td>$assigned_to</td>
  </tr>
 ]]
 </table>
]======]
