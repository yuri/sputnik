module(..., package.seeall)
NODE = {
   actions= [[show = "tickets.show"]],
   fields= [[reported_by = {.11}
severity    = {.12}
priority    = {.13}
status      = {.14} 
milestone   = {.15}
prod_version = {.16}
component   = {.17}
keywords    = {.18}
assigned_to = {.19}
]],
   icon = "icons/bug",
   edit_ui= [[reported_by = {1.31, "text_field"}
severity    = {1.32, "select", options={"unassigned", "show stopper", "annoying", "cosmetic"}}
priority    = {1.33, "select", options={"unassigned", "highest", "high", "medium", "low", "lowest"}}
status      = {1.34, "select", options={"new", "confirmed", "assigned", "fixed", "tested", "wontfix"}} 
milestone   = {1.35, "text_field"}
prod_version = {1.36, "text_field"}
component   = {1.37, "text_field"}
keywords    = {1.38, "text_field"}
assigned_to = {1.39, "text_field"}
]],
   translations= [[_translations_for_ticket]],
}
