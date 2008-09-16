module(..., package.seeall)

NODE = {
   title="@Text_Config (Prototype for Text Config File)",
   category="_prototypes",
   actions=[[show = "wiki.code"]],
   permissions = [[
deny(all_users, all_actions)
allow(Admin, all_actions)
allow(all_users, "login")
allow(all_users, "logout")
--allow(all_users, "show")
allow(all_users, "history")
]],
   icon = "icons/system.png",
}

NODE.content=[===[
The content of this page is ignored but it's fields are inherited by 
some of the other pages of this wiki.
]===]
