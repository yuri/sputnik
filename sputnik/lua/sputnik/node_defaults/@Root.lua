module(..., package.seeall)

NODE = {
fields = [[
-- Think twice before editing this ------------------------
fields          = {0.0, proto="concat", activate="lua"}
title           = {0.1  }
is_deleted      = {0.11 }
category        = {0.2  }
actions         = {0.3, proto="concat", activate="lua"}
action_hooks    = {0.31, proto="concat", activate="lua"}
config          = {0.4, proto="concat", activate="lua"}
markup_module   = {0.41, proto="fallback"}
templates       = {0.5, proto="concat", activate="list"}
translations    = {0.51, proto="concat", activate="list"}
prototype       = {0.6  }
permissions     = {0.7,   proto="concat"}
creator         = {0.7001}
creation_time   = {0.7002}
owners          = {0.71}
html_main       = {0.701, proto="fallback"}
html_head       = {0.702, proto="fallback"}
html_menu       = {0.703, proto="fallback"}
html_logo       = {0.704, proto="fallback"}
html_page       = {0.706, proto="fallback"}
html_content    = {0.7061, proto="fallback"}
html_body       = {0.707, proto="fallback"}
html_header     = {0.708, proto="fallback"}
html_footer     = {0.708, proto="fallback"}
html_sidebar    = {0.709, proto="fallback"}
html_meta_keywords = {0.70901, proto="fallback"}
html_meta_description = {0.70902, proto="fallback"}
redirect_destination =  {0.70903}
xssfilter_allowed_tags = {0.7091, proto="concat", activate="lua"}
http_cache_control = {0.710, proto="fallback"}
http_expires    = {0.711, proto="fallback"}
content         = {0.81  }
edit_ui         = {0.9, proto="concat"}
admin_edit_ui   = {0.91, proto="concat"}
child_defaults  = {0.92, proto="concat", activate="lua"}
icon            = {0.93, proto="fallback"}
breadcrumb      = {0.94 }
save_hook       = {0.95, proto="fallback"}
raw_content_type = {0.96 }
template_helpers = {0.97, activate="lua", proto="concat"}
-- "virtual" fields (never saved) ------------------------
version         = {virtual=true}
prev_version    = {virtual=true}
raw             = {virtual=true}
history         = {virtual=true}
name            = {virtual=true}
]],
title="@Root (Root Prototype)",
category="Prototypes",
actions=[[
show            = "wiki.show"
show_content    = "wiki.show_content"
history         = "wiki.history"
edit            = "wiki.edit"
edit_new        = "wiki.edit_new"
configure       = "wiki.configure"
post            = "wiki.post"
rss             = "wiki.rss"
diff            = "wiki.diff"
code            = "wiki.code"
raw             = "wiki.raw"
raw_content     = "wiki.raw_content"
login           = "wiki.show_login_form"
sputnik_version = "wiki.sputnik_version"
save            = "wiki.save"
create          = "wiki.create"
preview         = "wiki.preview"
preview_content = "wiki.preview_content"
cancel          = "wiki.cancel"
reload          = "wiki.reload"
]],
markup_module = "markdown",
templates     = "sputnik/templates",
translations  = "sputnik/translations",
config        = [[
   
]],
edit_ui = [[
-------------------------- basic fields ----------------
content_section  = {1.0, "div_start", id="content_section", open="true"}
 content         = {1.3, "textarea", rows=15, no_label=true}
 content.editor_modules = {
                      "resizeable",
                      "markitup",
 }
content_section_end = {1.4, "div_end"}

-------------------------- advanced fields -------------
advanced_section = {2.0, "div_start", id="advanced"}
 page_name       = {2.21, "readonly_text"}
 is_deleted      = {2.211, "checkbox"} 
 title           = {2.22, "text_field"}
 owners          = {2.221, "text_field"}
 creator         = {2.222, "text_field"}
 creation_time   = {2.223, "text_field"}
 breadcrumb      = {2.23, "text_field"}
 category        = {2.24, "select", options = {}}
 prototype       = {2.25, "hidden", no_label=true, div_class="hidden"}
advanced_section_end = {2.3, "div_end"}

--- info about the edit --------------------------------
edit_info_section  = {3.00, "div_start", id="edit_info_section", open="true"} 
 summary         = {3.2, "textarea", no_label=true, rows=2, editor_modules = {"resizeable"}}
edit_info_section_end = {3.3, "div_end"}
]],
admin_edit_ui = [[
-------------------------- basic fields ----------------
--page_params_hdr = {1.0, "header"}
content_section  = {1.00, "div_start", id="content_section", open="true"}
 page_name       = {1.1, "readonly_text"}
 title           = {1.2, "text_field"}
 breadcrumb      = {1.3, "text_field"}
 content         = {1.4, "textarea", editor_modules = {"resizeable"}, rows=15, no_label=true}
content_section_end = {1.5, "div_end"}

-------------------------- advanced fields -------------
advanced_section = {2.0, "div_start", id="advanced_section"}
 category        = {2.01, "select", options = {"Foo", "Bar"}}
 prototype       = {2.02, "text_field"}
 redirect_destination = {2.022, "text_field"}
 permissions     = {2.03, "textarea", rows=3, editor_modules = {"resizeable", "validatelua"}}
 actions         = {2.04, "textarea", rows=3, editor_modules = {"resizeable", "validatelua"}}
 config          = {2.05, "textarea", rows=3, editor_modules = {"resizeable", "validatelua"}}
 markup_module   = {2.0501, "text_field"}
 html_meta_keywords = {2.051, "text_field"}
 html_meta_description = {2.052, "text_field"}
 save_hook       = {2.053, "text_field"}
advanced_section_end = {2.06, "div_end"}

html_section     = {2.100, "div_start", id="html_section", state="open"}
 html_main       = {2.101, "textarea", rows=3, editor_modules = {"resizeable"}}
 html_head       = {2.102, "textarea", rows=3, editor_modules = {"resizeable"}}
 html_body       = {2.103, "textarea", rows=3, editor_modules = {"resizeable"}}
 html_header     = {2.104, "textarea", rows=3, editor_modules = {"resizeable"}}
 html_menu       = {2.105, "textarea", rows=3, editor_modules = {"resizeable"}}
 html_logo       = {2.106, "textarea", rows=3, editor_modules = {"resizeable"}}
 html_page       = {2.108, "textarea", rows=3, editor_modules = {"resizeable"}}
 html_content    = {2.108, "textarea", rows=3, editor_modules = {"resizeable"}}
 html_sidebar    = {2.109, "textarea", rows=3, editor_modules = {"resizeable"}}
 html_footer     = {2.110, "textarea", rows=3, editor_modules = {"resizeable"}}
 xssfilter_allowed_tags = {2.111, "textarea", rows=3, editor_modules = {"resizeable"}}
html_section_end = {2.112, "div_end"}

http_section     = {2.201, "div_start", id="http_section", state="open"}
 http_cache_control = {2.202, "textarea", rows=3, editor_modules = {"resizeable"}}
 http_expires    = {2.203, "textarea", rows=3, editor_modules = {"resizeable"}}
http_section_end = {2.209, "div_end"}

guru_section     = {2.30, "div_start", id="guru_section"}
 templates       = {2.31, "text_field"}
 translations    = {2.32, "text_field"}
 fields          = {2.33, "textarea", rows=3, editor_modules = {"resizeable", "validatelua"}}
 edit_ui         = {2.34, "textarea", rows=3, editor_modules = {"resizeable", "validatelua"}}
 admin_edit_ui   = {2.35, "textarea", rows=3, editor_modules = {"resizeable", "validatelua"}}
guru_section_end = {2.36, "div_end"}

--- info about the edit --------------------------------
edit_info_section  = {3.00, "div_start", id="edit_info_section", open="true"} 
 summary         = {3.2, "textarea", rows=3, editor_modules = {"resizeable"}}
edit_info_section_end = {3.3, "div_end"}
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
   allow(all_users, show)  -- show, show_content, cancel
   allow(all_users, edit_and_save) -- edit, save, preview
   allow(all_users, "edit_new") -- edit, save, preview
   allow(all_users, "create") -- edit, save, preview
   allow(all_users, "post")  --needed for login
   allow(all_users, "login")
   allow(all_users, history_and_diff)
   allow(all_users, "rss")
   allow(all_users, "xml")
   --deny(Anonymous, edit_and_save)
   allow(Admin, "reload")
   allow(Admin, "configure")
   allow(Admin, "raw")
]]
}

NODE.html_main      = [==[<!doctype html>
<!--[if lt IE 7]> <html class="no-js lt-ie9 lt-ie8 lt-ie7" lang="en"> <![endif]-->
<!--[if IE 7]>    <html class="no-js lt-ie9 lt-ie8" lang="en"> <![endif]-->
<!--[if IE 8]>    <html class="no-js lt-ie9" lang="en"> <![endif]-->
<!--[if gt IE 8]><!--> <html class="no-js" lang="en"> <!--<![endif]-->
<head>
$head
</head>
<body>
$body

  <script src="$js_base_url{}sputnik/scripts.js"></script>
  <script>window.jQuery || document.write('<script src="$js_base_url{}sputnik/scripts.js"><\/script>')</script>
  $do_javascript_links[[<script src="$href"></script>
  ]]
  $do_javascript_snippets[=[
   <script>/* <![CDATA[ */ $snippet /* ]]> */</script>
  ]=]
</body>
</html>
]==]

NODE.html_head      = [=[
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
  <meta name="keywords" content="$html_meta_keywords"/>
  <meta name="description" content="$html_meta_description"/>
  <title>$site_title: $title</title>
  <meta name="viewport" content="width=device-width">
  <link rel="stylesheet" href="$css_base_url{}sputnik/style.css" media="all"/>
  $do_css_links[[<link type="text/css" rel="stylesheet" href="$href" media="$media"/>
]]$do_css_snippets[[
   <style media="$media">$snippet</style>
]]<link rel="shortcut icon" href="$favicon_url"/>
  <link rel="alternate" type="application/rss+xml" title="_(RECENT_EDITS_TO_SITE)" $site_rss_link/>
  <link rel="alternate" type="application/rss+xml" title="_(RECENT_EDITS_TO_NODE)" $node_rss_link/>
  $if_no_index[[<meta name="ROBOTS" content="NOINDEX, NOFOLLOW"/>]]
  
  <script src="$js_base_url{}sputnik/early_scripts.js"></script>
]=]
  

NODE.html_menu      = [==[<ul class="level1">$do_nav_sections[=[
     <li class='$current level1 $position' id='menu_item_$id'>
      <a title="$accessibility_title" $link>$title</a>
      <ul class='$current level2'>$subsections[[<li class='$current level2 $position'><a title="$accessibility_title" $link>$title</a></li>]]
       <li style="display:none">&nbsp;</li>
      </ul>
     </li>]=]
    </ul>
]==]

NODE.html_logo      = [[<a class="home_page" href="$home_page_url" title="Home page">
      <p class="site_title">$site_title</p>
      <p class="site_subtitle">$site_subtitle</p>
     </a>]]

NODE.html_page      = [=[<div id="breadcrumbs">
     <ul>
      $do_breadcrumb[[<li class="first"><a $link>$title</a></li>]],[[
      <li class="follow"><a $link>▹&nbsp; $title</a></li>]]
     </ul>
    </div>
    <div id="toolbar">
     $do_toolbar[[$if_icon[====[<a $link title="$title"><img src="$icon_base_url{}$icon" alt="_(BUTTON)"/></a>]====]
      $if_text[====[<a $link>$title</a>]====]
     ]]
    </div>
    <article id="node">
    <div id="node_title">$if_title_icon[[
     <img src="$title_icon" class="title_icon" alt="type icon ($title_icon)"/>]]
     <a title="_(CURRENT_PAGE)" $show_link >$title</a> $if_old_version[[<span class="from_version">($version)</span>]]
    </div>
    <div id="node_content" class="node_content">
     $do_messages[[<p class="$class">$message</p>]]

<!-- start node content -->$content<!-- end node content -->

    </div>
    </article>
]=]

NODE.html_content   = [[Not used by default.
]]

NODE.html_body      = [[
  <!--[if lt IE 7]><p class=chromeframe>Your browser is <em>ancient!</em> <a href="http://browsehappy.com/">Upgrade to a different browser</a> or <a href="http://www.google.com/chromeframe/?redirect=true">install Google Chrome Frame</a> to experience this site.</p><![endif]-->

  <div id="container">  
  <header id="header">
    $header
  </header>
  <div role="main">
   <div id="page">
    $page
   </div>
  </div>
  <nav id="menu">
    $menu
  </nav>
  <footer id="footer">
    $footer
  </footer>
  </div>
]]


NODE.html_header    = [=[<div id="logo">
     $logo
    </div>
    <div id="login_container">
    <div id="login">
     $if_logged_in[[ $if_user_link[====[<a $link>]====]$user$if_user_link[====[</a>]====]
       / <a class="logout" title="_(LOGOUT)" $logout_link>_(LOGOUT)</a>]]
     $if_not_logged_in[[<a class="login_link" $login_link>_(LOGIN)</a>
       $if_can_register[=========[ _(OR) <a $register_link>_(REGISTER)</a>]=========]
     ]]
    </div>
    </div>
    <div id="search">
     <form action="$base_url" class="search">
      <input class="hidden" type="hidden" name="p" value="sputnik/search"/>
      <input class="search_box" type="text" name="q" size="16"
             title="_(TOOLTIP_FOR_SEARCH_BOX)" value="$search_box_content"/>
      <input class="search_button" type="image" src="$icon_base_url{}icons/search.png" alt="_(BUTTON)"/>
     </form>
    </div>
]=]

NODE.html_sidebar = [==[
]==]

NODE.html_footer = [===[
<p>_(POWERED_BY_SPUTNIK) | <a class="etc" href="http://validator.w3.org/check?uri=referer">HTML5</a></p>
]===]

NODE.html_meta_keywords = " "
NODE.html_meta_description = " "

NODE.child_defaults = [[

--talk = [==[
--title = "Discussion of $id"
--prototype ="@Discussion"
--]==]

]]


