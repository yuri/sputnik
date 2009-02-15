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
markup_module   = {0.41, proto="fallback"}
templates       = {0.5, proto="concat", activate="list"}
translations    = {0.51, proto="concat", activate="list"}
prototype       = {0.6  }
permissions     = {0.7,   proto="concat"}
html_main       = {0.701, proto="fallback"}
html_head       = {0.702, proto="fallback"}
html_menu       = {0.703, proto="fallback"}
html_logo       = {0.704, proto="fallback"}
html_search     = {0.705, proto="fallback"}
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
page_name       = {1.1, "readonly_text"}
title           = {1.2, "text_field"}

-------------------------- advanced fields -------------
advanced_section = {2.0, "div_start", id="foo"}
 category        = {2.1, "text_field"}
 prototype       = {2.2, "text_field"}
 html_meta_keywords = {2.051, "text_field"}
 html_meta_description = {2.052, "text_field"}
advanced_section_end = {2.3, "div_end"}

--- the content of the page ----------------------------
content_section  = {3.00, "div_start", id="content_section", open="true"}
 content         = {3.01, "editor", rows=15, no_label=true}
content_section_end = {3.02, "div_end"}
--- info about the edit --------------------------------
edit_info_section  = {4.00, "div_start", id="edit_info_section", open="true"} 
 minor            = {4.1, "checkbox", value=false}
 summary         = {4.2, "textarea", rows=3}
edit_info_section_end = {4.3, "div_end"}
]],
admin_edit_ui = [[
-------------------------- basic fields ----------------
--page_params_hdr = {1.0, "header"}
page_name       = {1.1, "readonly_text"}
title           = {1.2, "text_field"}
-------------------------- advanced fields -------------
advanced_section = {2.0, "div_start", id="advanced_section"}
 category        = {2.01, "text_field"}
 prototype       = {2.02, "text_field"}
 redirect_destination = {2.021, "text_field"}
 permissions     = {2.03, "textarea", rows=3}
 actions         = {2.04, "textarea", div_class="editlua", rows=3}
 config          = {2.05, "textarea", div_class="editlua", rows=3}
 markup_module   = {2.0501, "text_field"}
 html_meta_keywords = {2.051, "text_field"}
 html_meta_description = {2.052, "text_field"}
advanced_section_end = {2.06, "div_end"}

html_section     = {2.100, "div_start", id="html_section", state="open"}
 html_main       = {2.101, "textarea", rows=3 }
 html_head       = {2.102, "textarea", rows=3 }
 html_body       = {2.103, "textarea", rows=3 }
 html_header     = {2.104, "textarea", rows=3 }
 html_menu       = {2.105, "textarea", rows=3 }
 html_logo       = {2.106, "textarea", rows=3 }
 html_search     = {2.107, "textarea", rows=3 }
 html_page       = {2.108, "textarea", rows=3 }
 html_content    = {2.108, "textarea", rows=3 }
 html_sidebar    = {2.109, "textarea", rows=3 }
 html_footer     = {2.110, "textarea", rows=3 }
 xssfilter_allowed_tags = {2.111, "textarea", rows=3 }
html_section_end = {2.112, "div_end"}

http_section     = {2.201, "div_start", id="http_section", state="open"}
 http_cache_control = {2.202, "textarea", rows=3 }
 http_expires    = {2.203, "textarea", rows=3 }
http_section_end = {2.209, "div_end"}

guru_section     = {2.30, "div_start", id="guru_section"}
 templates       = {2.31, "text_field"}
 translations    = {2.32, "text_field"}
 fields          = {2.33, "textarea", div_class="editlua", rows=3}
 edit_ui         = {2.34, "textarea", div_class="editlua", rows=3}
 admin_edit_ui   = {2.35, "textarea", div_class="editlua", rows=3}
guru_section_end = {2.36, "div_end"}

--- the content of the page ----------------------------
content_section  = {3.00, "div_start", id="content_section", open="true"}
 content         = {3.01, "editor", rows=15, no_label=true}
content_section_end = {3.02, "div_end"}

--- info about the edit --------------------------------
edit_info_section  = {4.00, "div_start", id="edit_info_section", open="true"} 
 minor            = {4.1, "checkbox", value=false}
 summary         = {4.2, "textarea", rows=3}
edit_info_section_end = {4.3, "div_end"}
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
   allow(all_users, "post")  --needed for login
   allow(all_users, "login")
   allow(all_users, history_and_diff)
   allow(all_users, "rss")
   allow(all_users, "xml")
   --deny(Anonymous, edit_and_save)
   allow(Admin, "reload")
]]
}

NODE.html_main = [==[
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" 
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
 <head>
$head
 </head>
 <body>
$body

  <script type="text/javascript" src="$js_base_url{}sputnik/scripts.js"></script>
   $do_javascript_links[[<script type="text/javascript" src="$href"></script>
  ]]
  $do_javascript_snippets[=[
   <script type="text/javascript">/* <![CDATA[ */ $snippet /* ]]> */</script>
  ]=]
 </body>
</html>
]==]

NODE.html_head = [==[
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
  <meta name="keywords" content="$html_meta_keywords"/>
  <meta name="description" content="$html_meta_description"/>
  <title>$site_title: $title</title>
  <link type="text/css" rel="stylesheet" href="$css_base_url{}sputnik/style.css" media="all"/>
  $do_css_links[[<link type="text/css" rel="stylesheet" href="$href" media="$media"/>
]]$do_css_snippets[[
   <style type="text/css" media="$media">$snippet</style>
]]
<link rel="shortcut icon" href="$favicon_url"/>
  <link rel="alternate" type="application/rss+xml" title="_(RECENT_EDITS_TO_SITE)" $site_rss_link/>
  <link rel="alternate" type="application/rss+xml" title="_(RECENT_EDITS_TO_NODE)" $node_rss_link/>
  $if_no_index[[<meta name="ROBOTS" content="NOINDEX, NOFOLLOW"/>
]]]==]

NODE.html_menu = [==[
    <ul id='menu' class="level1">$do_nav_sections[=[
     <li class='$class level1' id='$id'>
      <a title="$accessibility_title" $link>$title</a>
      <ul class='$class level2'>$subsections[[
       <li class='$class level2'><a title="$accessibility_title" $link>$title</a></li>]]
       <li style="display:none">&nbsp;</li>
      </ul>
     </li>]=]
    </ul>
]==]

NODE.html_search = [==[
     <form action="$base_url" class="search">
      <input class="hidden" type="hidden" name="p" value="sputnik/search"/>
      <input class="search_box" type="text" name="q" size="16"
             title="_(TOOLTIP_FOR_SEARCH_BOX)" value="$search_box_content"/>
      <input class="small_submit" type="submit" name="Search" value="_(SEARCH)" 
             title="_(TOOLTIP_FOR_SEARCH)"/>
     </form>
]==]

NODE.html_page = [==[
      <div id="breadcrumbs">
       $if_multipart_id[=[
       <ul>
        $do_breadcrumb[[<li class="$class"><a $link>$title</a></li>]],[[<li class="$class">▹ <a $link>$title</a></li>]]
        <li style="display:none">&nbsp;</li>
       </ul>
       ]=]<span class="toolbar">
        $do_buttons[[<a $link title="$title"><img src="$icon_base_url{}icons/$command.png" alt="_(BUTTON)"/></a>
       ]]
        <a title="Bookmark"
           href="javascript:addBookmark('$site_title: $title','http://www.astroman.com')"><img
           alt="_(BUTTON)" src="$icon_base_url{}icons/star.png"/></a>
       </span>
      </div>
      <h1 class="title">$if_title_icon[[
       <img src="$title_icon" class="title_icon" alt="type icon ($title_icon)"/>]]
       <a name="title" title="_(CURRENT_PAGE)" $show_link >$title</a> $if_old_version[[<span class="from_version">($version)</span>]]
      </h1>
      $do_messages[[<p class="$class">$message</p>]]<div class='content'>

$content
      </div>
]==]

NODE.html_content = [==[
Not used by default.
]==]

NODE.html_logo = [==[
    <a class="logo" href="$home_page_url">
     <img src="$logo_url" alt="_(LOGO)" /> 
    </a>
]==]

NODE.html_header = [===[
    <div id="login"> <!--login and search (in the upper right corner) -->
$if_search[[$search]]
     <br/>
     $if_logged_in[[_(HI_USER) (<a $logout_link>_(LOGOUT)</a>)
     ]]$if_not_logged_in[[<a class="login_link" $login_link>_(LOGIN)</a> _(OR) <a $register_link>_(REGISTER)</a>]]
     <!--a $site_rss_link><img src="$icon_base_url{}icons/feed_medium.png" id="rss_icon" title="_(RSS_FOR_EDITS_TO_THIS_WIKI)"
        alt="_(RSS_FOR_EDITS_TO_THIS_WIKI)" /></a-->
   </div>   
   <div id="logo">
$logo
   </div>
   <div id="menu_bar">
$menu<!--br/><br/-->
   </div>
]===]

NODE.html_body = [===[
  <div id='doc3' class='yui-t0'>

   <div id="login_form" class="popup_form" style="display: none"></div>
   <div id='hd'>
$header
   </div>
   <div id='bd'>
    <div id="yui-main" $if_old_version[[style='background-color:#ddd;']]>
     <div class="yui-b" id='page'>
$page
     </div>
    </div>
    <div class="yui-b" id="sidebar">
$sidebar
    </div>    
   </div>  <!--#bd-->
   <div id='ft'>
$footer   </div>
  </div> <!--#docN-->
  <br/>
]===]

NODE.html_sidebar = [==[
]==]

NODE.html_footer = [===[
    _(POWERED_BY_SPUTNIK) | <a style="font-size: .7em" href="http://validator.w3.org/check?uri=referer">XHTML 1.1</a>
]===]

NODE.html_meta_keywords = " "
NODE.html_meta_description = " "

NODE.child_defaults = [[

--talk = [==[
--title = "Discussion of $id"
--prototype ="@Discussion"
--]==]

]]
