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
 border: 0;
 font-family: inherit;
 font-size: 100%;
 font-style: inherit;
 font-weight: inherit;
 margin: 0;
 outline: 0;
 padding: 0;
 vertical-align: baseline;
}
/* remember to define focus styles! */
:focus {
 outline: 0;
}
body {
 background: white;
 color: black;
 line-height: 1;
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
 font-weight: normal;
 text-align: left;
}
blockquote:before, blockquote:after, q:before, q:after {
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
 background-color: white;
 height: 100%;
 margin: 0 auto 0 auto;
 width: $CONTAINER_WIDTH;
}
#header {
 background: $HEADER_COLOR;
 height: 150px;
 padding-left: 10px;
 position: relative;
}
#logo {
 background: #f0f0f0;
 border: 2px solid #303030;
 left: -40px;
 position: absolute;
 top: 10px;
}
#logo a {
 color: black;
 text-decoration: none;
}

#logo a.logo {
 display: block;
 padding: 5px 20px 5px 20px;
}

p.site_title {
 font-size: 200%;
}
p.site_subtitle {
 font-style:italic;
}

#content {
 height: 100%;
 padding: 2em 2em 2em 2em;
}

#page p {
 line-height: 1.8;
}

#footer {
 background-color: $SUBMENU_COLOR;
 border-top: 1px solid $ACTIVE_GRAY;
 color: white;
 margin-top: 20em;
 padding-top: 10px; padding-bottom: 10px;
 width: $CONTAINER_WIDTH;
}

#footer p {
 margin-left: 1em;
 margin-right: 1em;
}

#footer a {
 color: #aaaaff;
}

/*** Content *******************************************************/

h1, h2, h3 {
 margin-bottom: .5em;
 margin-top: 1em;
 padding-bottom: .5em;
}

h1, h2, h3, #logo, #page_title {
 font-family: Verdana, Tahoma, Helvetica, Arial, "sans-serif";
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
 font-size: 120%;
 position: absolute;
 top: 120px;
 width: $CONTAINER_WIDTH;
}
#menu > ul {
 display: block;
 text-align: center;
 width: 100%;
}
#menu ul li {
 display: inline;
 margin-left: 10px;
 padding-right: 1em;
}
#menu  ul  li.back  ul {
 display: none;
}
#menu  ul  li.front  ul {
 background: $SUBMENU_COLOR;
 float: left;
 margin-top: 1em;
 padding-top: .7em; padding-bottom: .7em;
 width: $CONTAINER_WIDTH;
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
 border-bottom: .2em solid $SUBMENU_COLOR;
 color: $SUBMENU_COLOR;
}
#menu  ul  li.back  a {
 border-bottom: .2em solid #555;
}

#menu  ul  li.front  ul  li {
 margin: 0;
 padding: 0;
}
#menu  ul  li.front  ul  li  a {
 color: white;
 font-family: Verdana, Arial, sans-serif;
 font-size: 70%;
 margin-left: 10px;
 padding: .3em 1em .3em 1em;
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
 font-size: 240%;
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
 text-decoration: none;
 vertical-align:top;
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
 border-left: 2px solid #cccccc;
 line-height: 1;
 margin-left: 5em;
 padding-left: 1em;
}

#page blockquote p {
 line-height: 1;
 padding-bottom: .5em;
 padding-top: .5em;
}

.next_node_link {
 margin-left: 400px;
}

#chapter_download_link {
 margin: 1em;
 margin-left: 500px;
 margin-right: -3em;
 padding: 0;
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
 font-family: "monospace";
 margin-bottom: 2em;
 margin-top: 2em;
}

pre code {
 background: #fffaf0;
 border-left: 1px solid gray;
 display: block;
 margin-left: 2em;
 padding: 1em;
 padding-bottom: .5em;
 padding-top: .5em;
}

.honey {
 display: none;
}

label.inline {
 display: inline-block;
 width: 200px;
}

div.field {
 background-color: #ddd;
 margin-bottom: 2px;
 padding: .5em .2em .1em .5em ;
}

div.grippie {
 background:#F3F3F3 url($icon_base_url{}sputnik/grippie.png) no-repeat scroll center 2px;
 border-color:#DDDDDD;
 border-style:solid;
 border-width:0pt 1px 1px;
 cursor:s-resize;
 height:6px;
 margin-bottom: 10px;
 margin-left: 300px;
 overflow:hidden;
 width: 70px;
}

h2.ctrigger {
 background: url($icon_base_url{}icons/minus.png) no-repeat right;
}

h2.ctrigger.closed {
 background: url($icon_base_url{}icons/plus.png) no-repeat right;
}

.teaser {
 font-size  : 120%;
}

textarea {
 padding: 1em;
 width: 95%;
 font-size: 110%;
}
label {
 padding: .5em;
}
.error {
 background-color: #F8E0E0;
 border: medium solid #DF0101;
}
.warning {
 background-color: #F8F8D0;
 border: medium solid #DF0101;
}
.success {
 background-color: #D0F8D0;
 border: medium solid #01DF01;
}
.notice {
 background-color: #D0D0F8;
 border: medium solid #0101DF;
}
.error, .warning, .success, .notice {
 margin-bottom: 1em;
 padding: .5em;
 width: 90%;
}

ins {
 background: #d0f8d0;
 text-decoration: none;
}
del {
 background: #f8f8d0;
}


@media print {
 #menu_bar, #login, #ft, .toolbar {
   display: none; !important;
 }
 body {
   background-color: white;
 }
 #bd {
   border: none;
   margin: 0px;
   padding: 0px;
 }
}

$more_css

]===]

