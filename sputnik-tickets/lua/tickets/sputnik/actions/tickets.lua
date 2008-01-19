
module(..., package.seeall)


local TEMPLATE = [===[

<a $new_ticket_link>Create New Ticket</a>

<ul>
 $do_tickets[[<li>$status: <a $ticket_link>$ticket_id</a> ($title)</li>]]
</ul>
]===]


actions = {}

actions.show = function(node, request, sputnik)
   local tickets = {}
   local ticket_counter = 0
   for i, node_id in ipairs(sputnik:get_node_names()) do
       if node_id:sub(0,7) == "Ticket:" then
          local ticket = sputnik:get_node(node_id)
          ticket.ticket_id = node_id:sub(8)
          table.insert(tickets, ticket)
          local ticket_number = tonumber(ticket.ticket_id) or 0
          if ticket_number > ticket_counter then ticket_counter = ticket_number; end 
       end
   end
   node.inner_html = cosmo.f(TEMPLATE){
                        do_tickets = function()
                                        for i, ticket in ipairs(tickets) do
                                           cosmo.yield{
                                              ticket_link = sputnik:make_link(ticket.name),
                                              ticket_id   = ticket.ticket_id,
                                              status      = ticket.status,
                                              title       = ticket.title,
                                           }
                                        end
                                     end,
                        new_ticket_link = sputnik:make_link(string.format("Ticket:%06d", ticket_counter + 1), "edit",
                                                            {prototype = "@Ticket", reported_by = request.user})
                     }
   return node.wrappers.default(node, request, sputnik)
end
