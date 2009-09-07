module(..., package.seeall)

NODE = {
   title="Style",
   prototype="@CSS",
   actions=[[css="css.fancy_css"]],
   fields = [[
      css_config = {}
   ]],
   admin_edit_ui = [[
      css_config = {0.0, "textarea"}
   ]],
   --fields = [[content.activate = nil]],
   permissions=[[allow(all_users, "css")]],
   --http_cache_control = "max-age=3600",
   --http_expires = "2",
}

NODE.css_config = [[
CONTAINER_WIDTH = "900px"
SUBMENU_HEIGHT = "20px"
HEADER_COLOR = "white"
SUBMENU_COLOR = "#33374d"
ACTIVE_GRAY = "#737373"

]]

NODE.content = [===[

/*** RESET ***/

/* Curtesy http://meyerweb.com/eric/tools/css/reset/ */

html, body, div, span, applet, object, iframe,
h1, h2, h3, h4, h5, h6, p, blockquote, pre,
a, abbr, acronym, address, big, cite, code,
del, dfn, em, font, img, ins, kbd, q, s, samp,
small, strike, strong, sub, sup, tt, var,
dl, dt, dd, ol, ul, li,
fieldset, form, label, legend,
table, caption, tbody, tfoot, thead, tr, th, td {
	margin: 0;
	padding: 0;
	border: 0;
	outline: 0;
	font-weight: inherit;
	font-style: inherit;
	font-size: 100%;
	font-family: inherit;
	vertical-align: baseline;
}
/* remember to define focus styles! */
:focus {
	outline: 0;
}
body {
	line-height: 1;
	color: black;
	background: white;
}
ol, ul {
	list-style: none;
}
/* tables still need 'cellspacing="0"' in the markup */
table {
	border-collapse: separate;
	border-spacing: 0;
}
caption, th, td {
	text-align: left;
	font-weight: normal;
}
blockquote:before, blockquote:after,
q:before, q:after {
	content: "";
}
blockquote, q {
	quotes: "" "";
}

/*** Let the styling begin. First the overall layout. ***/

body {
 background-color: gray;
}

#container {
 /*position: relative;*/
 margin: 0 auto 0 auto;
 width: $CONTAINER_WIDTH;
 background-color: white;
 height: 100%;
}
#header {
 height: 150px;
 padding-left: 10px; 
 position: relative;
 background: $HEADER_COLOR;
}
#logo {
 background: #f0f0f0;
 border: 2px solid #303030;
 padding: 10px 10px 10px 10px;
 font-size: 250%;
 position: absolute;
 left: -20px;
 top: 10px;
}
#logo a {
 text-decoration: none;
}

#content {
 padding: 2em 2em 2em 2em;
 height: 100%;
}

#page p {
 line-height: 1.8;
}

#footer {
 background-color: $SUBMENU_COLOR;
 border-top: 1px solid $ACTIVE_GRAY;
 padding-top: 10px; padding-bottom: 10px; 
 margin-top: 20em;
 width: $CONTAINER_WIDTH;
 color: white;
 padding-left: 1em;
}

#footer a {
 color: #aaaaff;
}

/*** Content *******************************************************/

h1, h2, h3 {
 margin-top: 4em;
 margin-bottom: 1.5em;
 padding-bottom: .5em;
}

h4, h5, h6, p {
 margin: 5px 0 5px 0;
 padding: 5px 0 5px 0;
}
h1, h2 {
 color: $ACTIVE_GRAY;
}
h1, h2 {
 border-bottom: 1px solid $ACTIVE_GRAY;
}
h1 {
 font-size  : 180%;
}
h2 {
 font-size  : 140%;
}
h3 {
 font-size  : 129%; 
}
h4 {
 font-size  : 107%; 
}

/*** The Menu ******************************************************/

#menu {
 position: absolute;
 top: 120px;
 width: $CONTAINER_WIDTH;
 font-size: 120%;
}
#menu > ul {
 display: block;
 width: 100%;
 text-align: center; 
}
#menu ul li {
 padding-right: 1em;
 display: inline;
 margin-left: 10px;
}
#menu  ul  li.back  ul {
 display: none;
}
#menu  ul  li.front  ul {
 float: left;
 margin-top: 1em;
 width: $CONTAINER_WIDTH;
 background: $SUBMENU_COLOR;
 padding-top: .7em; padding-bottom: .7em;
 z-index: 1000;
}
#menu  ul  li.front  ul  li{
 display: inline;
 z-index: 1001;
}

#menu a {
 text-decoration: none;
}

#menu  ul  li  a {
 padding: .3em;
}

#menu  ul  li.front  a {
 color: $SUBMENU_COLOR;
 border-bottom: .2em solid $SUBMENU_COLOR;
}
#menu  ul  li.back  a {
 border-bottom: .2em solid #555;
}

#menu  ul  li.front  ul  li {
 margin: 0;
 padding: 0;
}
#menu  ul  li.front  ul  li  a {
 padding: .3em 1em .3em 1em;
 margin-left: 10px;
 color: white;
 font-size: 70%;
 font-family: Verdana, Arial, sans-serif;
}
#menu  ul  li.front  ul  li.front  a {
 background: $ACTIVE_GRAY;
}
#menu  ul  li.front  ul  li.back  a {
 background: $SUBMENU_COLOR;
}
#menu  ul  li.front  ul  li.back  a:hover {
 background-color: gray;
}

#breadcrumbs {
 display: none;
}

#toolbar {
 float: right;
 margin: -5px 10px 0px 0px;
}

#page_title {
 margin: 4em 1em 2em 2em;
}

#page_title a{
 font-size: 200%;
 text-decoration: none;
 color: $ACTIVE_GRAY;
}

/* Sputnik-Specific */

#search_box {
 position:absolute;
 top: 10px;
 left: 700px;
 z-index: 1000;
}

#login {
 position:absolute;
 top: 45px;
 left: 700px;
 z-index: 1000;
}

form.search {
 display: inline;
}

input.search_box {
 padding:   2px  2px   2px  2px;
 display : inline;
 line-height: 10px;  
 font-size  : 9pt;
 vertical-align: text-bottom;
 height: 22px;
}

#page p .nr {
   font-size:10px;
   vertical-align:top;
   text-decoration: none;
}

.footnote {
   margin-top: 20px;
}
h4 {
   font-weight: bold;
}

#bd {
   padding-left: 5em;
}
#page blockquote {
   margin-left: 5em;
   padding-left: 1em;
   line-height: 1;
   border-left: 2px solid #cccccc;
}

#page blockquote p {
   line-height: 1;
   padding-top: .5em;
   padding-bottom: .5em;
}

.next_node_link {
   margin-left: 400px;
}

#chapter_download_link {
   margin: 1em;
   margin-right: -3em;
   padding: 0;
   margin-left: 500px;
}
#chapter_download_link a {
   text-decoration: none;
}

#page ul {
   list-style: disc;
   padding-left: 3em;
}

#page ol {
   list-style: decimal;
   padding-left: 3em;
}

pre {
   font-family: "Courier New" Courier monospace;
   font-size: 80%;
   margin-top: 2em;
   margin-bottom: 2em;
}

pre code {
   display: block;
   margin-left: 4em;
   border-left: 1px solid gray;
   padding: 1em;
   padding-top: .5em;
   padding-bottom: .5em;
   background: #fffaf0;
}

$more_css

]===]

