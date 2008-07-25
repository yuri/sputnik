module(..., package.seeall)

NODE = {
fields = [[
-- Think twice before editing this ------------------------
fields          = {0.0, proto="concat", activate="lua"}
title           = {0.1  }
category        = {0.2  }
actions         = {0.3, proto="concat", activate="lua"}
action_hooks    = {0.31, proto="concat", activate="lua"}
config          = {0.4, proto="concat", activate="lua"}
templates       = {0.5, proto="concat", activate="list"}
translations    = {0.51, proto="concat", activate="list"}
prototype       = {0.6  }
permissions     = {0.7, proto="concat"}
content         = {0.8  }
edit_ui         = {0.9, proto="concat"}
admin_edit_ui   = {0.91, proto="concat"}
child_defaults  = {0.92, proto="concat", activate="lua"}
icon            = {0.93, proto="fallback"}
-- "virtual" fields (never saved) ------------------------
version         = {virtual=true}
prev_version    = {virtual=true}
raw             = {virtual=true}
history         = {virtual=true}
name            = {virtual=true}
]],
title="@Root (Root Prototype)",
category="_prototypes",
actions=[[
show            = "wiki.show"
show_content    = "wiki.show_content"
history         = "wiki.history"
edit            = "wiki.edit"
post            = "wiki.post"
rss             = "wiki.rss"
diff            = "wiki.diff"
code            = "wiki.code"
raw             = "wiki.raw"
raw_content     = "wiki.raw_content"
login           = "wiki.show_login_form"
sputnik_version = "wiki.sputnik_version"
save            = "wiki.save"
preview         = "wiki.preview"
preview_content = "wiki.preview_content"
reload          = "wiki.reload"
]],
templates    = "sputnik/templates",
translations = "sputnik/translations",
config       = [[
   
]],
edit_ui = [[
-------------------------- basic fields ----------------
page_params_hdr = {1.0, "header"}
page_name       = {1.1, "readonly_text"}
title           = {1.2, "text_field"}
-------------------------- advanced fields -------------
show_advanced   = {2.0, "show_advanced", no_label=true}
category        = {2.1, "text_field", advanced=true}
prototype       = {2.2, "text_field", advanced=true}
--- the content of the page ----------------------------
content_hdr     = {3.0, "header"}
content         = {3.1, "editor", rows=15, 
                                        no_label=true}
--- info about the edit --------------------------------
edit_info_hdr   = {4.0, "header"} 
minor           = {4.1, "checkbox", value=false}
summary         = {4.2, "textarea", rows=3}

]],
admin_edit_ui = [[
-------------------------- basic fields ----------------
page_params_hdr = {1.0, "header"}
page_name       = {1.1, "readonly_text"}
title           = {1.2, "text_field"}
-------------------------- advanced fields -------------
show_advanced   = {2.0, "show_advanced", no_label=true}
category        = {2.1, "text_field", advanced=true}
prototype       = {2.2, "text_field", advanced=true}
templates       = {2.3, "text_field", advanced=true}
translations    = {2.31, "text_field", advanced=true}
permissions     = {2.4, "textarea", advanced=true, rows=3}
actions         = {2.5, "textarea", div_class="editlua", advanced=true, rows=3}
config          = {2.6, "textarea", div_class="editlua", advanced=true, rows=3}
fields          = {2.7, "textarea", div_class="editlua", advanced=true, rows=3}
edit_ui         = {2.8, "textarea", div_class="editlua", advanced=true, rows=3}
admin_edit_ui   = {2.9, "textarea", div_class="editlua", advanced=true, rows=3}
--- the content of the page ----------------------------
content_hdr     = {3.0, "header"}
content         = {3.1, "editor", rows=27, 
                                        no_label=true}
--- info about the edit --------------------------------
edit_info_hdr   = {4.0, "header"} 
minor           = {4.1, "checkbox", value=false}
summary         = {4.2, "textarea", rows=3}
]],
content=[===[

This is the root proto-page.  The content of this form is ignored, but
it's fields are inherited by all other pages.  E.g., if you were to set

    actions = [[show_content = "wiki.show_content_as_lua_code"]]

on this page, _all_ pages would default to displaying their content as
if it was Lua code.  (Note that any page that sets `show_content` to
its own value, and any pages that inherit from it, will continue to
work as they did before.)  I.e., this page only affects the default
values.  Handle with care.

]===],
permissions=[[
   deny(all_users, all_actions)
   allow(all_users, "show")
   allow(all_users, "edit")
   allow(all_users, "save")
   allow(all_users, "preview")
   allow(all_users, "cancel")
   allow(all_users, "post")  --needed for login
   allow(all_users, "login")
   allow(all_users, "history")
   allow(all_users, "rss")
   allow(all_users, "diff")
   allow(all_users, "xml")
   allow(all_users, "show_content")
   --deny(Anonymous, "edit")
   --deny(Anonymous, "save")
   allow(Admin, "reload")
]]
}

