module(..., package.seeall)

NODE = {
   title="Sputnik Version",
   actions = [[show="wiki.sputnik_version"]],
   category="_special_pages",
   content="",
   permissions = [[
deny(all_users, "show")
deny(all_users, "edit")
deny(all_users, "history")
allow(Admin, "show")
]]
}
