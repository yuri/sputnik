module(..., package.seeall)

NODE = {
   actions="show='mbox.show_list_history'",
   title = "Mailing List History",
   content = "   "
}

NODE.permissions = [[
deny(all_users, edit_and_save)
allow(Admin, edit_and_save)
]]


