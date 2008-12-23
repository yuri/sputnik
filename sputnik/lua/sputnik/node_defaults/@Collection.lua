module(..., package.seeall)
NODE = {
   title      = "@Collection",
   actions    = [[show = "collections.list_children"]],
}

NODE.fields = [=[
child_proto = {1.1, ""}
]=]

NODE.child_defaults = [=[
new = [[ 
prototype = "$id"
title     = "New Item"; 
actions   = 'save="tickets.save_new"';
]]
]=]

NODE.permissions = [=[
--deny(all_users, "edit")
--deny(all_users, "save")
--deny(all_users, "history")
--deny(all_users, "rss")
--allow(Admin, "edit")
--allow(Admin, "save")
--allow(Admin, "history")
]=]


