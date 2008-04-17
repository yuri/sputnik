module(..., package.seeall)
NODE = {
   title= "Tickets",
   actions= [[show = "tickets.show"]],
}

NODE.child_defaults = [=[
new = [[ prototype="@NewTicket"; title="New Ticket" ]]
]=]
