module(..., package.seeall)

NODE = {
 prototype = "@Lua_Config",
 title = "Templates for LuaUsers"
}

NODE.content= [====[TRANSLATIONS = "Translations:Main"

MAIN = [===[
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML><HEAD><TITLE>lua-users wiki: $title</TITLE>
<LINK TYPE="text/css" REL="stylesheet" HREF="http://lua-users.org/styles/main.css">
<STYLE TYPE="text/css" REL="stylesheet">
    input.hidden, div.honey {
        display: none;
    }
    div.advanced_field {
        display: none;
    }
    div.advanced_field input, div.advanced_field textarea {
        display: block;
    }
    div.advanced_field {
        margin-top: .5em;
    }
    div#toggle_advanced_fields {
        display: inline;
        font-size: smaller;
    }
</STYLE>
</HEAD>
<BODY ><table width="100%" border="0"> <tr><td align=left width="100%"><h1><a href="]===]..NICE_URL..[===[_search&amp;q=$title&amp;Search=Search" title="List pages referring to $title">$title</a></h1></td><td align=right>
    <table cellpadding="0" cellspacing="0" border="0" width="1%">
      <tbody>
        <tr>
            <td><a href="/">
            <img src="http://lua-users.org/images/nav-logo.png" alt="lua-users home" width="177" height="40" border="0"></a></td>

        </tr>
        <tr>
            <td>
            <table cellpadding="0" cellspacing="0" border="0" width="100%">
                <tbody>
                <tr>
                    <td><img src="http://lua-users.org/images/nav-elbow.png" alt="" width="48" height="40"></td>
                    <td nowrap valign="middle" width="100%">
                        <a href="$nice_url" class="nav">wiki</a></td>

                </tr>
                </tbody>
            </table>
            </td>
        </tr>
      </tbody>
    </table>
</td></tr> </table>

$content

<hr>
<a href="$nice_url/FindPage" >FindPage</a> &middot; <a href="$nice_url/RecentChanges">RecentChanges</a>
<a $edit_link>edit</a> &middot; <a $history_link>history</a> &middot;
$if_logged_in[[ logged as $user (<a $logout_link>logout</a>)]]
$if_not_logged_in[[<a $login_link>login</a>]]

</body>
</html>
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
<br>
<form action="$base_url">
<input type="hidden" class="hidden" name="p" value="$node_name.diff"/>
<input type="submit" value="_(DIFF_SELECTED_VERSIONS)"/>
<br>
<br>
$do_revisions[==[
Revision $version: <a $version_link>View</a> 
<input class="diff_radio" type="radio" value="$version" name="other"/>
<input class="diff_radio" type="radio" value="$version" name="version"/>
 . . $timestamp $if_minor[[<i>(minor edit)</i>]] by <a $author_link>$author</a>$if_summary[[ <b>[$summary]</b>]]<br>
]==]
</form>
]===]

COMPLETE_HISTORY = [===[
$do_revisions[==[
Revision $version: <a $version_link>View</a> <a $diff_link>Diff</a> . .$if_minor[[<i>(minor edit)</i>]] by <a $author_link>$author</a>$if_summary[[ <b>[$summary]</b>]]</a> in <a $latest_link>$title</a><br>
]==]
]===]

DIFF = [===[
<ul> 
    <li><a $link1><ins class='diffmod'>$version1</ins></a> by $author1</li>
    <li><a $link2><del class='diffmod'>$version2</del></a> by $author2</li>
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
$if_try_again[[
<br/><font color='red'><b>$alert</b></font><br/><br/>
]]

<form method="post" action="$action_url">
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
        elem.style.width="915px";
        elem.style.height="800px";
        elem.style.margin="10px 10px 10px -205px";
    }
</script>
<input class="hidden" type="hidden" name="p" value="$node_name.post"/>
<input class="hidden" type="hidden" name="post_token" value="$post_token"/>
<input class="hidden" type="hidden" name="post_timestamp" value="$post_timestamp"/>
<input class="hidden" type="hidden" name="post_fields" value="$post_fields"/>

$if_preview[[
<h2>_(PREVIEWING_UNSAVED_CHANGES)</h2>
$preview
<input class="submit" type="submit" accesskey="s" name="action_save"    value="_(SAVE)"/>
<input class="submit" type="submit" accesskey="c" name="action_show"    value="_(CANCEL)"/>
<br>
]]

$html_for_fields

<p style='font-size:80%'>
ATTENTION if your purpose is SEO / search engine optimization / pageranking:
</p>
<ul style='font-size:80%;margin-bottom:0em'>
<li style='margin-top:0em'> any sites you link to will be added to a blacklist used by a network of wiki's
<li> inappropriate links will be promptly removed
<li> this wiki's page history and diffs are not crawled by search engines
</ul>
<br>

<input class="submit" type="submit" accesskey="p" name="action_preview" value="_(PREVIEW)"/>
<input class="submit" type="submit" accesskey="s" name="action_save"    value="_(SAVE)"/>
<input class="submit" type="submit" accesskey="c" name="action_show"    value="_(CANCEL)"/>
 <div><input type="hidden" name=".cgifields" value="recent_edit"  /></div></form>
]===]

EDIT_FORM_HEADER        = [[<a name="$anchor"></a><h2>$label</h2>]]
EDIT_FORM_NOTE          = [[<h3>$label</h3>]]
EDIT_FORM_LABEL         = [[<label>$label</label> ]]
EDIT_FORM_HONEYPOT      = [[<input type="text" value="$value" name="$name"/>]]
EDIT_FORM_TEXT_FIELD    = [[<input type="text" value="$value" name="$name" size="60" maxlength="200" />]]
EDIT_FORM_READONLY_TEXT = [[<input type="text" value="$value" name="$name" class="readonly" readonly="readonly" />]]
EDIT_FORM_PASSWORD      = [[<input type="password" value="$value" name="$name" size="20"></input>]]
EDIT_FORM_TEXTAREA      = [[<textarea class="small" name="$name" rows="$rows" cols="65" wrap="virtual" style="width:100%">$value</textarea>]]
EDIT_FORM_BIG_TEXTAREA  = [[<textarea name="$name" rows="20" cols="65" wrap="virtual" style="width:100%">$value</textarea><p>]]
EDIT_FORM_CHECKBOX      = [[<label><input type="checkbox" name="$name" value="yes" $if_checked[=[checked="checked"]=] />$label</label><br/>]]
EDIT_FORM_SELECT        = [[<select name="$name">$do_options[=[<option $if_selected[==[selected="yes"]==]>$option</option>]=]</select>]]
EDIT_FORM_SHOW_ADVANCED = [[<a id="more_fields" href="#" class="local" onclick="toggleElements('advanced_field')"><div id="toggle_advanced_fields">_(SHOW_ADVANCED_OPTIONS)</div></a>]]

LOGIN_FORM              = [===[
$if_try_again[[
    <br/><font color='red'><b>$alert</b></font><br/><br/>
]]
    <form method="post" action="$action_url">
        <input class="hidden" type="hidden" name="p" value="$node_name.post"/>
        <input class="hidden" type="hidden" name="post_token" value="$post_token"/>
        <input class="hidden" type="hidden" name="post_timestamp" value="$post_timestamp"/>
        <input class="hidden" type="hidden" name="post_fields" value="$post_fields"/>
        $html_for_fields
        <input class="submit" type="submit" accesskey="c" name="action_show_login_form"    value="_(LOGIN)"/>
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
]====]

