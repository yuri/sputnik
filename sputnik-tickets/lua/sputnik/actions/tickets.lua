
module(..., package.seeall)
local sorttable = require"sputnik.javascript.sorttable"
local wiki = require"sputnik.actions.wiki"

local TEMPLATE = [===[

<a $new_ticket_link>Create a New Ticket</a>
<br/><br/>

<script>
 $sorttable_script
</script>
<table class="sortable" width="100%">
 <thead>
  <tr>
   <th>ID</th>
   <th>priority</th>
   <th>milestone</th>
   <th>status</th>
   <th>title</th>
  </tr>
 </thead>
 $do_tickets[[
  <tr style="background:$color">
   <td width="20px"><a $ticket_link>$ticket_id</a></td>
   <td width="20px">$priority</td>
   <td width="20px">$milestone</td>
   <td sorttable_customkey="$num_status" width="20px">$status</td>
   <td>$title</td>
  </tr>
 ]]
</table>

(Click on the headers to sort.)
]===]

actions = {}

status_colors = {
   fixed = "#f0fff0",
   new = "#f0f0ff",
   assigned = "#fffff0",
   wontfix = "#f0f0f0",
   confirmed = "#fff0ff",
}

priority_to_number = {
   unassigned = "",
   highest = "*****",
   high = "****",
   medium = "***",
   low = "**",
   lowest = "*",
}

status_to_number = {
   new = "1",
   confirmed = "2",
   assigned = "3",
   wontfix = "4",
   fixed = "5",
   tested = "6",
}

actions.show = function(node, request, sputnik)
   local tickets = {}
   local ticket_counter = 0
   for i, node_id in ipairs(sputnik:get_node_names{prefix="Tickets/"}) do
      local ticket = sputnik:get_node(node_id)
      ticket.ticket_id = node_id:sub(9)
      table.insert(tickets, ticket)
      local ticket_number = tonumber(ticket.ticket_id) or 0
      if ticket_number > ticket_counter then ticket_counter = ticket_number; end 
   end
   table.sort(tickets, function(x,y) return x.ticket_id > y.ticket_id end)
   node.inner_html = cosmo.f(TEMPLATE){
                        sorttable_script = sorttable.script,
                        do_tickets = function()
                                        for i, ticket in ipairs(tickets) do
                                           
                                           cosmo.yield{
                                              ticket_link = sputnik:make_link(ticket.name),
                                              ticket_id   = ticket.ticket_id,
                                              status      = ticket.status,
                                              num_status  = status_to_number[ticket.status],
                                              priority    = priority_to_number[ticket.priority],
                                              milestone   = ticket.milestone or "undef",
                                              title       = ticket.title,
                                              color       = status_colors[ticket.status] or "white",
                                           }
                                        end
                                     end,
                        new_ticket_link = sputnik:make_link("Tickets/new", "edit", 
                                                            {reported_by = request.user})
                     }
   return node.wrappers.default(node, request, sputnik)
end

--local wiki = require("sputnik.actions.wiki")

actions.save_new = function(node, request, sputnik)
   local new_id = string.format("Tickets/%06d", sputnik:get_uid("Tickets"))
   local new_node = sputnik:get_node(new_id)
   sputnik:update_node_with_params(new_node, {prototype = "@Ticket"})
   new_node = sputnik:activate_node(new_node)
   new_node.inner_html = "Created a new ticket: <a "..sputnik:make_link(new_id)..">"
                         ..new_id.."</a><br/>"
                         .."List <a "..sputnik:make_link("Tickets")..">tickets</a>"
   return wiki.actions.save(new_node, request, sputnik)
end

