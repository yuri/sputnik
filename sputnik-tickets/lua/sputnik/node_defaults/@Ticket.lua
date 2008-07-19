module(..., package.seeall)
NODE = {
   actions= [[show = "tickets.show"]],
   icon = "icons/bug.png",
   translations = "tickets/translations",
   templates    = "tickets/templates",
}

NODE.permissions = [[
   allow(all_users, "raw")
]]

NODE.fields= [[
reported_by = {.11}
priority    = {.13}
status      = {.14} 
resolution  = {.151}
milestone   = {.15}
prod_version = {.16}
component   = {.17}
assigned_to = {.19}
resolution_details = {.20}
]]

NODE.edit_ui= [[
reported_by = {1.31, "text_field"}
assigned_to = {1.331, "text_field"}
status      = {1.34, "select"}
status.options  ={"open", "someday", "resolved", "closed"}
resolution  = {1.35, "select"}
resolution.options = {"n.a.", "fixed", "wontfix"} 
show_advanced   = {2.0, "show_advanced", no_label=true}
priority    = {2.1, "select", advanced=true}
priority.options={"unassigned", "high", "medium", "low"}
resolution_details = {2.3, "textarea", advanced=true, rows=3}
component   = {2.37, "text_field", advanced=true}
page_name   = null
]]


