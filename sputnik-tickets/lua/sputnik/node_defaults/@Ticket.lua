module(..., package.seeall)
NODE = {
   actions= [[show = "tickets.show"]],
   icon = "icons/bug",
   translations = "tickets/translations",
   templates    = "tickets/templates"
}

NODE.fields= [[
reported_by = {.11}
severity    = {.12}
priority    = {.13}
status      = {.14} 
milestone   = {.15}
prod_version = {.16}
component   = {.17}
keywords    = {.18}
assigned_to = {.19}
]]

NODE.edit_ui= [[
reported_by = {1.31, "text_field"}
severity    = {1.32, "select"}
priority    = {1.33, "select"}
status      = {1.34, "select"}
milestone   = {1.35, "text_field"}
prod_version = {1.36, "text_field"}
component   = {1.37, "text_field"}
keywords    = {1.38, "text_field"}
assigned_to = {1.39, "text_field"}

severity.options={"unassigned", "show stopper", "annoying", "cosmetic"}
priority.options={"unassigned", "highest", "high", "medium", "low", "lowest"}
status.options  ={"new", "confirmed", "assigned", "fixed", 
                  "tested", "wontfix", "closed"} 

page_name   = null
]]

