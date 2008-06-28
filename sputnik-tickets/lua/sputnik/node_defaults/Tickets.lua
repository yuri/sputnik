module(..., package.seeall)
NODE = {
   title= "Tickets",
   actions= [[show = "tickets.list"]],
}

NODE.child_defaults = [=[
new = [[ prototype="@NewTicket"; title="New Ticket" ]]
]=]
