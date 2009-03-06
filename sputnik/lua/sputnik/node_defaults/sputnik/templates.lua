module(..., package.seeall)

NODE = {
   title="Templates",
   category="_special_pages",
   prototype="@Lua_Config",
}

NODE.search_form = [===[


]===]





NODE.content=[=====[--- this is the template that generates the outer tags of the page ---

TRANSLATIONS = "Translations:Main"

--------------------------------------------------------------------------------
------- BASIC TEMPLATES --------------------------------------------------------
--------------------------------------------------------------------------------



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
                 <a $diff_link title="_(DIFF)"><img alt="_(DIFF)" src="$diff_icon"/></a>
                 <a $history_link title="_(HISTORY)"><img alt="_(HISTORY)" src="$history_icon"/></a>
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
         $if_version2_exists[[<li><a $link2><del class='diffmod'>$version2</del></a> _(BY_AUTHOR2)</li>]]
        </ul>
        $diff
]===]

RSS = [===[<rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/">
 <channel>
  <title>$title</title>
  <description/>
   <link>$channel_url</link>
     $items[==[
   <item>
    <link>$link</link>
    <title>$title</title>
    <guid isPermaLink="$ispermalink">$guid</guid>
	<pubDate>$pub_date</pubDate>
    <dc:creator>$author</dc:creator>
    <description>$summary</description>
   </item>]==]
 </channel>
</rss>
]===]

RSS_SUMMARY = [===[
$if_summary_exists[[$summary]]
$if_no_summary[[_(NO_EDIT_SUMMARY)]]
<hr/>
<a href="$history_url">_(HISTORY)</a>
<a href="$diff_url">_(SHOW_CHANGES_SINCE_PREVIOUS)</a>]===]

LIST_OF_ALL_PAGES = [===[
       $do_nodes[[<a href="$url">$name</a><br/>]]
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
   
      <form class="edit" method="post" enctype="multipart/form-data" action="$action_url">
       $captcha
       <input class="hidden" type="hidden" name="p" value="$node_name.post"/>
       <input class="hidden" type="hidden" name="post_token" value="$post_token"/>
       <input class="hidden" type="hidden" name="post_timestamp" value="$post_timestamp"/>
       <input class="hidden" type="hidden" name="post_fields" value="$post_fields"/>
       $if_preview[[
        <h2>_(PREVIEWING_UNSAVED_CHANGES)</h2>
        <div class="preview">$preview</div>
        <a href="#new_page_content_header" class="button">_(CHANGE)</a>
        <div class="submit">
         <button class="positive" type="submit" name="action_save" accesskey="s">_(SAVE)</button>
         <button class="negative" type="submit" name="action_show" accesskey="c">_(CANCEL)</button>
        </div>
       ]]
       $html_for_fields
       <div class="submit">
        <button class="positive" type="submit" accesskey="s" name="action_save">_(SAVE)</button>
        <button class="positive" type="submit" accesskey="s" name="action_preview">_(PREVIEW)</button>
        <button class="negative" type="submit" accesskey="s" name="action_cancel">_(CANCEL)</button>
      </div>
      </form>
]===]

EDIT_FORM_HEADER        = [[<a name="$anchor"></a><h2>$label</h2>]]
EDIT_FORM_NOTE          = [[<h3>$label</h3>]]
EDIT_FORM_LABEL         = [[<label>$label</label>]]
EDIT_FORM_INLINE_LABEL  = [[<label class="inline">$label</label>]]
EDIT_FORM_FILE          = [[<input type="file" value="$value" name="$name"/>]]
EDIT_FORM_HONEYPOT      = [[<input type="text" value="$value" name="$name"/>]]
EDIT_FORM_TEXT_FIELD    = [[<input type="text" value="$value" name="$name" class="textfield"/>]]
EDIT_FORM_HIDDEN        = [[<input type="hidden" class="hidden" value="$value" name="$name"/>]]
EDIT_FORM_READONLY_TEXT = [[<input type="text" value="$value" name="$name" class="readonly textfield" readonly="readonly" />]]
EDIT_FORM_PASSWORD      = [[<input type="password" value="$value" name="$name" size="20" class="textfield"></input>]]
EDIT_FORM_TEXTAREA      = [[<textarea class="$class" name="$name" cols="80" rows="$rows">$value</textarea>]]
EDIT_FORM_EDITOR        = [[<textarea class="$class" name="$name" cols="80" rows="$rows">$value</textarea>]]
EDIT_FORM_BIG_TEXTAREA  = [[<textarea class="$class" name="$name" id="main_text_area" cols="80" rows="$rows">$value</textarea><br/>
                            <a href="#" onclick="expandTextArea(); return false;">expand</a>]]
EDIT_FORM_CHECKBOX      = [[<input class="checkbox" style="border:1px solid black" 
                                   type="checkbox" name="$name" value="yes"
                                   $if_checked[=[checked="checked"]=] /><br/>]]
EDIT_FORM_CHECKBOX_TEXT = [[<input class="checkbox" style="border:1px solid black"
                                      type="checkbox" name="$name" value="yes"
                                      $if_checked[=[checked="checked"]=] />$text<br/>]]
EDIT_FORM_SELECT        = [[<select name="$name" tabindex="$tab_index">
                               $do_options[===[<option value="$value" $if_selected[=[selected="yes"]=]>$display</option>]===]
                            </select>]]
EDIT_FORM_SHOW_ADVANCED = [[<a id="more_fields" href="#" class="local" onclick="toggleElements('advanced_field')">
                             <div id="toggle_advanced_fields">_(SHOW_ADVANCED_OPTIONS)</div></a>]]
EDIT_FORM_DIV_START = [=[$do_collapse[[<h2 id="trigger_$id" class="ctrigger $state">$label</h2>]]<div id="$id" class="$class">]=]
EDIT_FORM_DIV_END = [[</div>]] 

LOGIN_FORM              = [===[
   
      <form method="post" action="$action_url">
       <input class="hidden" type="hidden" name="post_token" value="$post_token"/>
       <input class="hidden" type="hidden" name="post_timestamp" value="$post_timestamp"/>
       <input class="hidden" type="hidden" name="post_fields" value="$post_fields"/>
       $html_for_fields
       <button class="submit" type="submit" accesskey="c" name="action_login">_(LOGIN)</button>
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
     </font>
    ]]

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
       border: none;
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

VERSION = [=[
   <h2>Installer Version</h2>

   $installer

   <h2>Specific Rocks</h2> 

   <table>
    $rocks[[
    <tr>
     <th>$rock</th>
     <td>$version</td>
    </tr>
    ]]
   </table>  
]=]

]=====]

