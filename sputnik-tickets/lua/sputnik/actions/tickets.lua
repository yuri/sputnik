module(..., package.seeall)
local sorttable = require"sputnik.javascript.sorttable"
local wiki = require"sputnik.actions.wiki"

actions = {}

actions.list = function(node, request, sputnik)
   local tickets = {}
   for id, ticket in pairs(sputnik.saci:get_nodes_by_prefix(node.id.."/")) do
      if ticket.status~="closed" or request.params.show_closed then
         table.insert(tickets, ticket)
      end
   end
   table.sort(tickets, function(x,y) return x.id > y.id end)

   local function decorate_ticket(ticket)
      local ticket_info = {
            ticket_link = sputnik:make_link(ticket.id),
            edit_link   = sputnik:make_link(ticket.id, "edit"),
            edit_icon   = sputnik:make_url("icons/edit-faded", "png"),
            ticket_id   = sputnik:escape(ticket.id:sub(node.id:len()+2)),
            status      = sputnik:escape(ticket.status),
            assigned_to = sputnik:escape(ticket.assigned_to),
            num_status  = node.config.status_to_number[ticket.status],
            priority    = node.config.priority_to_number[ticket.priority],
            milestone   = sputnik:escape(ticket.milestone or "undef"),
            title       = sputnik:escape(ticket.title),
            component   = sputnik:escape(ticket.component),
            color       = node.config.status_colors[ticket.status] or "white",
      }
      return ticket_info
   end

   local new_ticket_link = sputnik:make_link(node.id.."/new", "edit", 
                                             {reported_by = request.user}, nil, nil, 
                                             {mark_missing=false} )

   local user = (request.user or ""):lower()
   if user == "" then user = nil end

   for i, ticket in ipairs(tickets) do
      if (ticket.assigned_to or ""):lower()==user then
        user_has_tickets = true
      end
   end
   node:add_javascript_snippet(sorttable.script)
   node.inner_html = cosmo.f(node.templates.LIST){
                        if_showing_all  = cosmo.c(request.params.show_closed){
                                             link=sputnik:make_link(node.id),
                                          },
                        if_showing_open = cosmo.c(not request.params.show_closed){
                                             link=sputnik:make_link(node.id, "show", {show_closed="1"})
                                          },
                        do_tickets      = function()
                                             for i, ticket in ipairs(tickets) do
                                                if (ticket.assigned_to or ""):lower()~=user then
                                                   cosmo.yield(decorate_ticket(ticket))
                                                end
                                             end
                                          end,
                        do_my_tickets   = function()
                                             for i, ticket in ipairs(tickets) do
                                                if (ticket.assigned_to or ""):lower()==user then
                                                   cosmo.yield(decorate_ticket(ticket))
                                                end
                                             end
                                          end,
                        if_has_tickets  = cosmo.c(user_has_tickets==true){},
                        if_has_no_tickets  = cosmo.c(user_has_tickets==nil){},
                        new_ticket_link = new_ticket_link
                     }

   return node.wrappers.default(node, request, sputnik)
end

--local wiki = require("sputnik.actions.wiki")
