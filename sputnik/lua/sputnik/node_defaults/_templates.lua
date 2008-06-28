module(..., package.seeall)

NODE = {
   title="Templates",
   category="_special_pages",
   prototype="@Lua_Config",
}
NODE.content=[=====[--- this is the template that generates the outer tags of the page ---

TRANSLATIONS = "Translations:Main"

--------------------------------------------------------------------------------
------- BASIC TEMPLATES --------------------------------------------------------
--------------------------------------------------------------------------------

MAIN = [===[<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" 
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

 <head>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
  $if_no_index[[<meta name="ROBOTS" content="NOINDEX, NOFOLLOW"/>]]
  <title>$site_title: $title</title>
  $do_stylesheets[[

  <link type="text/css" rel="stylesheet" href="$href" media="$media"/>]]
  $do_stylesheets_src[[

  <style type="text/css" media="$media">$src</style>]]
  $do_javascript_link[[

  <script type="text/javascript" src="$href"></script>]]
  $do_javascript_src[[

  <script type="text/javascript">$src
  </script>]] 

  <link rel="shortcut icon" href="$favicon_url"/>
  <link rel="alternate" type="application/rss+xml" title="_(RECENT_EDITS_TO_SITE)" $site_rss_link/>
  <link rel="alternate" type="application/rss+xml" title="_(RECENT_EDITS_TO_NODE)" $node_rss_link/>
 </head>

 <body>
  <div id='doc3'>
  
   <div id="login"> <!--login and search (in the upper right corner) -->
    $if_search[[    <form action="$base_url" style="margin-right: 0px; padding-right: 0px;">
     <input class="hidden" type="hidden" name="p" value="_search"/>
     <input class="search_box" type="text" name="q" size="16" value="$search_box_content"/>
     <input class="small_submit" type="submit" name="Search" value="_(SEARCH)" 
            title="_(TOOLTIP_FOR_SEARCH)"/></form><br/>]]    
    $if_logged_in[[ _(HI_USER) (<a $logout_link>_(LOGOUT)</a>) ]]
    $if_not_logged_in[[_(LOGIN_OR_REGISTER)]]
    <a $site_rss_link><img src="$rss_medium_url" id="rss_icon" title="_(RSS_FOR_EDITS_TO_THIS_WIKI)" alt="_(LARGE_RSS_ICON)" /></a>
   </div>
   
   <div id="logo">
    <a class="logo" href="$home_page_url">
     <img src="$logo_url" alt="_(LOGO)" /> 
    </a>
   </div>
   
   <div id='hd'><!--navigation bar -->    $nav_bar   </div>
 
   <div id='bd'><!--the body, consisting of the page and the sidebar--> 

    <div id="yui-main" $if_old_version[[style='background-color:#ddd;']]><!--this just marks the page as "main" -->
     <div class="yui-b" id='page'>

      <span class="toolbar">
       <a $edit_link title="_(EDIT)"> 
        <img src="$edit_icon" alt="_(EDIT_ICON)"/>
       </a>
       <a $history_link title="_(HISTORY)">
        <img src="$history_icon" alt="_(HISTORY_ICON)"/>
       </a>
       <a $node_rss_link title="_(RSS_FOR_EDITS_TO_THIS_NODE)">
        <img src="$rss_icon" alt="_(SMALL_RSS_ICON)" />
       </a>
      </span>

      <h1 class="title">
        $if_title_icon[[<img src="$title_icon" class="title_icon" alt="type icon ($title_icon)"/> ]]
        <a $show_link >$title</a> $if_old_version[[<span class="from_version">($version)</span>]]
      </h1>

      $do_messages[[<p class="error $class">$message</p>]]

      <div class='content'>$content</div>
      
     </div>  <!-- end of div .yui-b#page -->     
    </div>  <!-- end of div #yui-main (end of body)-->

    <!--div class="yui-b" id="sidebar">$sidebar</div-->
    
   </div>  <!-- end of div #bd -->
   _(POWERED_BY_SPUTNIK)
  </div> <!-- end of div.yui-t4#doc2 -->
  <br/>
 </body>
</html>
]===]

NAV_BAR = [===[
    <ul id='menu'>   $do_sections[[
     <li class='$class' id='$id'><a $link>$label</a></li>]]
    </ul>
    <ul id='submenu'>   $do_subsections[[
     <li class='$class'><a $link>$label</a></li>]]
    </ul>
]===]


LOGGED_OUT = [===[_(YOU_ARE_NOW_LOGGED_OUT)]===]

--------------------------------------------------------------------------------
------- HISTORY, ETC -----------------------------------------------------------
--------------------------------------------------------------------------------

DATE_SELECTOR = [===[
      <div id="date_selector" style="border:1px solid #bbb; background: #eee8aa; padding: 5 5 5 5">
       _(CHANGES_BY_DATE) ($current_month):
       <span class="history_dates">
        $do_dates[=[$if_current_date[[$date]]|[[<a $date_link>$date</a>]]
        ]=]
       </span>
       <br/>
       _(CHOOSE_ANOTHER_MONTH) ($current_year) :
       <span class="history_months">
        $do_months[=[$if_current_month[[$month]]$if_other_month[[<a $month_link>$month</a>]]
        ]=]
       </span>
       <br/>
      </div> <!-- end of "date_selector" div-->
      <br/>
]===]

HISTORY = [===[
      <form action="$base_url">
       <input type="hidden" class="hidden" name="p" value="$node_name.diff"/>
       <input type="submit" value="_(DIFF_SELECTED_VERSIONS)"/>
       <table width="100%">
        <tbody>
         $do_revisions[==[
          <tr> 
            $if_new_date[=[
              <tr><td style="border-right: 0; border-left: 0" colspan="3"><h2>$date</h2></td></tr>
            ]=]
            $if_edit[=[
            <td width="5px" $if_minor[[bgcolor="#f0f0f0"]]>
             <input class="diff_radio" type="radio" value="$version" name="other"/>
            </td>
            <td width="5px" $if_minor[[bgcolor="#f0f0f0"]]>
             <input class="diff_radio" type="radio" value="$version" name="version"/>
            </td>
            <td width="400px" $if_minor[[bgcolor="#f0f0f0"]]>
             _(AUTHOR_SAVED_VERSION) $if_summary[[<ul><li>$summary</li></ul>]]
            </td>
            ]=]
          </tr>
         ]==]
        </tbody>
       </table>
      </form>
]===]


COMPLETE_HISTORY = [===[
      <table width="100%">
        <tbody>
         $do_revisions[==[
            $if_new_date[=[
              <tr><td style="border-right: 0; border-left: 0" colspan="3"><h2>$date</h2></td></tr>
            ]=]
            $if_edit[=[
              <tr>
                <td width="50px" $if_stale[[style="display:none"]] rowspan="$row_span">
                 &nbsp;<a $latest_link>$title</a>
                </td>
                <td width="300px" $if_minor[[bgcolor="#f0f0f0"]] style="border-right: 0px">
                 _(AUTHOR_SAVED_VERSION)
                 $if_summary[[<p>$summary</p>]]
                </td>
                <td width="10%" $if_minor[[bgcolor="#f0f0f0"]] style="border-left: 0px" align="right">
                 <a class="help"  $diff_link title="_(DIFF)"><img alt="_(DIFF)" src="$diff_icon"/></a>
                 <a class="help" $history_link title="_(HISTORY)"><img alt="_(HISTORY)" src="$history_icon"/></a>
                </td>
              </tr>
            ]=]
         ]==]
        </tbody>
       </table>
]===]

DIFF = [===[
        <ul> 
         <li><a $link1><ins class='diffmod'>$version1</ins></a> _(BY_AUTHOR1)</li>
         <li><a $link2><del class='diffmod'>$version2</del></a> _(BY_AUTHOR2)</li>
        </ul>
        $diff
]===]

RSS = [===[<rss version="2.0">
 <channel>
  <title>$title</title>
  <description/>
   <link>$baseurl</link>
     $items[[
   <item>
    <link>$link</link>
    <title>$title</title>
    <guid isPermalink="$ispermalink">$guid</guid>
    <description>$summary</description>
   </item>]]
 </channel>
</rss>
]===]

LIST_OF_ALL_PAGES = [===[
       <H2>Regular Nodes</H2>
       $do_regular_nodes[[<a href="$url">$name</a><br/>]]

       <H2>Special Nodes</H2>
       $do_special_nodes[[<a href="$url">$name</a><br/>]]
]===]


SITEMAP_XML = [===[<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd" 
xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
   $do_urls[[<url>
      <loc>$url</loc>
      <lastmod>$lastmod</lastmod>
      <changefreq>$changefreq</changefreq>
      <priority>$priority</priority>
   </url>]]
</urlset> 
]===]

--------------------------------------------------------------------------------
------- MISCELLANEOUS ----------------------------------------------------------
--------------------------------------------------------------------------------

EDIT = [===[
   
      <form method="post" enctype="multipart/form-data" action="$action_url">
       $captcha
       <script type="text/javascript">
         function toggleElements(class_name) {
            var re = new RegExp('\\b' + "advanced_field" + '\\b');
            var els = document.getElementsByTagName("div");
            for(var i=0,j=els.length; i<j; i++) {
               var elem = els[i];
               if(re.test(elem.className)) {
                  if (elem.style.display=="block") {
                     elem.style.display = "none";
                     document.getElementById("toggle_advanced_fields").innerHTML="_(SHOW_ADVANCED_OPTIONS)"
                  } else {
                     elem.style.display = "block";
                     document.getElementById("toggle_advanced_fields").innerHTML="_(HIDE_ADVANCED_OPTIONS)"
                  }
               }
            }
         }
         function expandTextArea() {
            var elem = document.getElementById("main_text_area");
            elem.style.width="1200px";
            elem.style.height="800px";
            elem.style.margin="10px 10px 10px -100px";
         }
       </script>
       <input class="hidden" type="hidden" name="p" value="$node_name.post"/>
       <input class="hidden" type="hidden" name="post_token" value="$post_token"/>
       <input class="hidden" type="hidden" name="post_timestamp" value="$post_timestamp"/>
       <input class="hidden" type="hidden" name="post_fields" value="$post_fields"/>
       $if_preview[[
        <h2>_(PREVIEWING_UNSAVED_CHANGES)</h2>
        <div class="preview">$preview</div>
        <a href="#new_page_content_header" class="button">_(CHANGE)</a>
        <input class="submit" type="submit" accesskey="s" name="action_save"    value="_(SAVE)"/>
        <input class="submit" type="submit" accesskey="c" name="action_show"    value="_(CANCEL)"/>
        <br/>
       ]]
       $html_for_fields
       <input class="submit" type="submit" accesskey="s" name="action_save"    value="_(SAVE)"/>
       <input class="submit" type="submit" accesskey="p" name="action_preview" value="_(PREVIEW)"/>
       <input class="submit" type="submit" accesskey="c" name="action_show"    value="_(CANCEL)"/>
      </form> 
]===]

EDIT_FORM_HEADER        = [[<a name="$anchor"></a><h2>$label</h2>]]
EDIT_FORM_NOTE          = [[<h3>$label</h3>]]
EDIT_FORM_LABEL         = [[<label>$label</label>]]
EDIT_FORM_FILE          = [[<input type="file" value="$value" name="$name"/>]]
EDIT_FORM_HONEYPOT      = [[<input type="text" value="$value" name="$name"/>]]
EDIT_FORM_TEXT_FIELD    = [[<input type="text" value="$value" name="$name"/>]]
EDIT_FORM_HIDDEN        = [[<input type="hidden" class="hidden" value="$value" name="$name"/>]]
EDIT_FORM_READONLY_TEXT = [[<input type="text" value="$value" name="$name" class="readonly" readonly="readonly" />]]
EDIT_FORM_PASSWORD      = [[<input type="password" value="$value" name="$name" size="20"></input>]]
EDIT_FORM_TEXTAREA      = [[<textarea class="small" name="$name" rows="$rows">$value</textarea>]]
EDIT_FORM_EDITOR        = [[<textarea class="editor resizeable" name="$name" rows="$rows">$value</textarea>]]
EDIT_FORM_BIG_TEXTAREA  = [[<textarea class="editor resizeable" name="$name" id="main_text_area" rows="$rows">$value</textarea><br/>
                            <a href="#" onclick="expandTextArea(); return false;">expand</a>]]
EDIT_FORM_CHECKBOX      = [[<input class="checkbox" style="border:1px solid black" 
                                   type="checkbox" name="$name" value="yes"
                                   $if_checked[=[checked="checked"]=] /><br/>]]

EDIT_FORM_SELECT        = [[<select name="$name">
                               $do_options[===[<option $if_selected[=[selected="yes"]=]>$option</option>]===]
                            </select>]]
EDIT_FORM_SHOW_ADVANCED = [[<a id="more_fields" href="#" class="local" onclick="toggleElements('advanced_field')">
                             <div id="toggle_advanced_fields">_(SHOW_ADVANCED_OPTIONS)</div></a>]]
EDIT_FORM_DIV_START = [=[$do_collapse[[<span id="trigger_$id" class="ctrigger $state">$label</span>]]<div id="$id" class="$class">]=]
EDIT_FORM_DIV_END = [[</div>]] 

LOGIN_FORM              = [===[
   
      <form method="post" action="$action_url">
       <input class="hidden" type="hidden" name="p" value="$node_name.post"/>
       <input class="hidden" type="hidden" name="post_token" value="$post_token"/>
       <input class="hidden" type="hidden" name="post_timestamp" value="$post_timestamp"/>
       <input class="hidden" type="hidden" name="post_fields" value="$post_fields"/>
       $html_for_fields
       <input class="submit" type="submit" accesskey="c" name="action_login" value="_(LOGIN)"/>
      </form> 

]===]
--------------------------------------------------------------------------------
------- DEALING WITH LUA CODE --------------------------------------------------
--------------------------------------------------------------------------------

LUA_CODE = [===[
       $if_ok[[<font color="green">_(THIS_LUA_CODE_PARSES_CORRECTLY)</font>]]
       $if_errors[[
	 <font color='red'>
            <p><b>_(THIS_LUA_CODE_HAS_PROBLEMS)</b></p>
	    <code> $errors </code>
         </font>]]

       <div width="100%">
        <style>
         table.code {
           width: 100%;
           border-collapse: collapse
           background: red;
           border-style: none;
         }
	 table.body {
           background: yellow;
	 }
	 table.code tbody th {
           font-size: 90%;
	 }
	 table.code tbody th a{
	    text-decoration: none;
	    color: white;
	 }
         table.code th.lineno { 
           width: 4em;
         }
         table.code th.bad {
	   background: red;
	 }
         table.code tbody td {
           //font: normal 120% monospace;
           border: none;
	   //color: black;
	 }
	 table.code tbody td code {
	   background: white;
         }
	 table.code tbody td code.bad{
	   background: yellow;
	 }
        </style>
        <table class="code">
         <tbody>
         $do_lines[[
             <tr>
              <th id="L$i" class="$class"><a href="#L$i">$i</a></th>
              <td><code class="$class">$line</code></td>
             </tr>
         ]]
        </tbody>
       </table>
      </div>
]===]

ACTION_NOT_FOUND = [===[
<div class="error_message">
  <p>_(PAGE_DOES_NOT_SUPPORT_ACTION)</p>
  $if_custom_actions[[
     <p>_(THIS_PAGE_DEFINED_THE_FOLLOWING_ACTIONS)</p>
     <pre><code>$actions</code></pre>
  ]]
</div>
]===]

REGISTRATION = [===[
<h3>Create new account</h3>
<form class="register" method="post" enctype="multipart/form-data" action="$action_url">
 <input class="hidden" type="hidden" name="p" value="$node_name.$action"/>
 <input class="hidden" type="hidden" name="post_token" value="$post_token"/>
 <input class="hidden" type="hidden" name="post_timestamp" value="$post_timestamp"/>
 <input class="hidden" type="hidden" name="post_fields" value="$post_fields"/>
 $html_for_fields
 $captcha
 <div class="submit">
 <button class="submit positive" type="submit" accesskey="s" name="action_submit">Register</button>
 </div>
</form> 
]===]

CONSENT_TO_TERMS_OF_SERVICE = [[
   <input style="margin: 0 10px 0 20px; width: auto; display: inline;" target="_blank" type="checkbox" name="r_read_tos" />
   _(I_AGREE_TO_TERMS_OF_SERVICE)
]]

]=====]

