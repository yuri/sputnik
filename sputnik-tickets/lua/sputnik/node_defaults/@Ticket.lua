module(..., package.seeall)
NODE = {
   actions= [[show = "tickets.show"]],
   fields= [[reported_by = {1.1}
severity    = {1.2}
priority    = {1.3}
status      = {1.4} 
milestone   = {1.5}
prod_version = {1.6}
component   = {1.7}
keywords    = {1.8}
assigned_to = {1.9}
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
