-- Submitted by Jérôme Vuarand

module(..., package.seeall)

NODE = {
 prototype    = "",
 category     = "_prototypes",
 title        = "@LuaUsers",
 templates    = "_templates_luausers",
 translations = "_translations_luausers"
}

NODE.fields= [=[-- Think twice before editing this ------------------------
fields          = {0.0, proto="concat", activate="lua"}
title           = {0.1  }
category        = {0.2  }
actions         = {0.3, proto="concat", activate="lua"}
config          = {0.4, proto="concat" }
templates       = {0.5, proto="concat", 
                        activate="node_list"}
translations    = {0.51, proto="concat", 
                        activate="node_list"}
prototype       = {0.6  }
permissions     = {0.7, proto="concat"}
content         = {0.8  }
edit_ui         = {0.9, proto="concat"}

-- "virtual" fields (never saved) ------------------------
version         = {virtual=true}
prev_version    = {virtual=true}
raw             = {virtual=true}
history         = {virtual=true}
name            = {virtual=true}
]=]

NODE.edit_ui= [=[
-------------------------- basic fields ----------------
page_params_hdr = nil--{1.0, "header"}
page_name       = {2.01, "readonly_text", advanced=true}
title           = {2.02, "text_field", advanced=true}
-------------------------- advanced fields -------------
show_advanced   = {2.0, "show_advanced", no_label=true}
category        = {2.1, "text_field", advanced=true}
prototype       = {2.2, "text_field", advanced=true}
templates       = {2.3, "text_field", advanced=true}
translations    = {2.31, "text_field", advanced=true}
permissions     = {2.4, "textarea", advanced=true, rows=3}
actions         = {2.5, "textarea", advanced=true, rows=3}
config          = {2.6, "textarea", advanced=true, rows=3}
fields          = {2.7, "textarea", advanced=true, rows=3}
edit_ui         = {2.8, "textarea", advanced=true, rows=3}
--- the content of the page ----------------------------
content_hdr     = nil--{3.0, "header"}
content         = {1.0, "big_textarea", rows=27, no_label=true}
--- info about the edit --------------------------------
edit_info_hdr   = nil--{4.0, "header"} 
minor           = {1.2, "checkbox", value=false, no_label=true}
summary         = {1.1, "text_field"}
]=]

NODE.actions= [=[
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
]=]
