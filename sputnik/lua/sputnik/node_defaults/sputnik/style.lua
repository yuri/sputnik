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
BOLD_COLOR_1 = "#1B8B9A" -- a bold color used for the larger elements
BOLD_COLOR_2 = "#093D59" -- a bold color used for the smaller elements
TEXT_BG_COLOR = "#FFFEEF"  -- background for the main text
BRIGHT_LIGHT_TEXT_COLOR = "white" -- for text on dark bg that should stand ot
DULLER_LIGHT_TEXT_COLOR = "#DDDDDD" -- for text that should stand out less
INACTIVE_MENU_COLOR = "#133D49"

CONTAINER_WIDTH = "1100px"
POPUP_WIDTH = "900px"
POPUP_TOP = "200px"
SUBMENU_HEIGHT = "20px"
LEFT_MARGIN = "50px"
LEFT_MARGIN_FOR_MENU = "40px"
]]

NODE.content = [===[
/*-- HTML5 Boilerplate -----------------------------------------------------*/

article, aside, details, figcaption, figure, footer, header, hgroup, nav, section { display: block; }
audio, canvas, video { display: inline-block; *display: inline; *zoom: 1; }
audio:not([controls]) { display: none; }
[hidden] { display: none; }

html { font-size: 100%; -webkit-text-size-adjust: 100%; -ms-text-size-adjust: 100%; }
html, button, input, select, textarea { font-family: sans-serif; color: #222; }
body { margin: 0; font-size: 1em; line-height: 1.4; }

::-moz-selection { background: #fe57a1; color: #fff; text-shadow: none; }
::selection { background: #fe57a1; color: #fff; text-shadow: none; }

a { color: #00e; }
a:visited { color: #551a8b; }
a:hover { color: #06e; }
a:focus { outline: thin dotted; }
a:hover, a:active { outline: 0; }
abbr[title] { border-bottom: 1px dotted; }
b, strong { font-weight: bold; }
blockquote { margin: 1em 40px; }
dfn { font-style: italic; }
hr { display: block; height: 1px; border: 0; border-top: 1px solid #ccc; margin: 1em 0; padding: 0; }
ins { background: #ff9; color: #000; text-decoration: none; }
mark { background: #ff0; color: #000; font-style: italic; font-weight: bold; }
pre, code, kbd, samp { font-family: monospace, serif; _font-family: 'courier new', monospace; font-size: 1em; }
pre { white-space: pre; white-space: pre-wrap; word-wrap: break-word; }

q { quotes: none; }
q:before, q:after { content: ""; content: none; }
small { font-size: 85%; }
sub, sup { font-size: 75%; line-height: 0; position: relative; vertical-align: baseline; }
sup { top: -0.5em; }
sub { bottom: -0.25em; }

ul, ol { margin: 1em 0; padding: 0 0 0 40px; }
dd { margin: 0 0 0 40px; }
nav ul, nav ol { list-style: none; list-style-image: none; margin: 0; padding: 0; }

img { border: 0; -ms-interpolation-mode: bicubic; vertical-align: middle; }
svg:not(:root) { overflow: hidden; }
figure { margin: 0; }

form { margin: 0; }
fieldset { border: 0; margin: 0; padding: 0; }

label { cursor: pointer; }
legend { border: 0; *margin-left: -7px; padding: 0; white-space: normal; }
button, input, select, textarea { font-size: 100%; margin: 0; vertical-align: baseline; *vertical-align: middle; }
button, input { line-height: normal; }
button, input[type="button"], input[type="reset"], input[type="submit"] { cursor: pointer; -webkit-appearance: button; *overflow: visible; }
button[disabled], input[disabled] { cursor: default; }
input[type="checkbox"], input[type="radio"] { box-sizing: border-box; padding: 0; *width: 13px; *height: 13px; }
input[type="search"] { -webkit-appearance: textfield; -moz-box-sizing: content-box; -webkit-box-sizing: content-box; box-sizing: content-box; }
input[type="search"]::-webkit-search-decoration, input[type="search"]::-webkit-search-cancel-button { -webkit-appearance: none; }
button::-moz-focus-inner, input::-moz-focus-inner { border: 0; padding: 0; }
textarea { overflow: auto; vertical-align: top; resize: vertical; }
input:valid, textarea:valid {  }
input:invalid, textarea:invalid { background-color: #f0dddd; }

table { border-collapse: collapse; border-spacing: 0; }
td { vertical-align: top; }

.chromeframe { margin: 0.2em 0; background: #ccc; color: black; padding: 0.2em 0; }


@media only screen and (min-width: 35em) {
  

}

.ir { display: block; border: 0; text-indent: -999em; overflow: hidden; background-color: transparent; background-repeat: no-repeat; text-align: left; direction: ltr; *line-height: 0; }
.ir br { display: none; }
.hidden { display: none !important; visibility: hidden; }
.visuallyhidden { border: 0; clip: rect(0 0 0 0); height: 1px; margin: -1px; overflow: hidden; padding: 0; position: absolute; width: 1px; }
.visuallyhidden.focusable:active, .visuallyhidden.focusable:focus { clip: auto; height: auto; margin: 0; overflow: visible; position: static; width: auto; }
.invisible { visibility: hidden; }
.clearfix:before, .clearfix:after { content: ""; display: table; }
.clearfix:after { clear: both; }
.clearfix { *zoom: 1; }

@media print {
  * { background: transparent !important; color: black !important; box-shadow:none !important; text-shadow: none !important; filter:none !important; -ms-filter: none !important; } 
  a, a:visited { text-decoration: underline; }
  a[href]:after { content: " (" attr(href) ")"; }
  abbr[title]:after { content: " (" attr(title) ")"; }
  .ir a:after, a[href^="javascript:"]:after, a[href^="#"]:after { content: ""; } 
  pre, blockquote { border: 1px solid #999; page-break-inside: avoid; }
  thead { display: table-header-group; } 
  tr, img { page-break-inside: avoid; }
  img { max-width: 100% !important; }
  @page { margin: 0.5cm; }
  p, h2, h3 { orphans: 3; widows: 3; }
  h2, h3 { page-break-after: avoid; }
}

/*-- End of HTML5 Boilerplate ----------------------------------------------*/

/*-- The body and the #container --------------------------------------------

  The <body> has a single div inside it - #container. This way, the container
  includes everything, but can be narrower than the body and can have
  a different background. The children of container are:

     #header - the site-level elements that we want to show prominently
     #page - the content that is specific to this node
     #menu - the navigation system (links to other pages)
     #footer - less importnat site info
----------------------------------------------------------------------------*/

$if_use_web_fonts[[
@font-face {
  font-family: 'Sputnik Header Web Font';
  font-style: normal;
  font-weight: bold;  
  src: url('$font_base_url{}sputnik/fonts/header.woff') format('woff');
}]]

body {
 background-color: gray;
 font-family: Verdana, Tahoma, Helvetica, Arial, "sans-serif";
 font-size: 11pt;
}
#container {
 background-color: $TEXT_BG_COLOR;
 height: 100%;
 margin: 0 auto 0 auto;
 width: $CONTAINER_WIDTH;
}


/*-- #header ----------------------------------------------------------------

  The header is a unit that includes elements that do not change from one
  node to another. We call it a "header" since it usually comes at the top
  of the page, though we can put it anywhere.

  The #header includes: #logo, #login, #search.
----------------------------------------------------------------------------*/

#header {
 background: $BOLD_COLOR_1;
 height: 180px;
 padding-left: 10px;
 position: relative;
}

/* #logo identifies the site and links to the front page. */
#logo {
 font-family: $if_use_web_fonts[['Sputnik Header Web Font',]] 'Arial', sans-serif;
 font-weight: bold;
 left: 0px;
 position: absolute;
 top: 25px;
 width: 100%;
}
#logo a {
 color: black;
 font-size: 150%;
 text-decoration: none;
}
#logo a.home_page { /* a link to the home page */
 display: block;
 padding: 5px 20px 5px $LEFT_MARGIN;
}
p.site_title { /* a title for the site */
 font-size: 200%;
 line-height: 90%;
}
p.site_subtitle { /* a subtitle for the site */
 font-style:italic;
 line-height: 90%;
}

/* #login contains the login status and the links to login/logout/register. */
#login_container {
 background-color: $BOLD_COLOR_2;
 left: 0px;
 position:absolute;
 width: 100%;
 z-index: 1000;
}
#login {
 color: $DULLER_LIGHT_TEXT_COLOR;
 float:right;
 padding: 5px 10px 5px 5px;
}
#login a {
 color: $BRIGHT_LIGHT_TEXT_COLOR;
 font-weight: bold;
 text-decoration: none;
}

/* #search contains a form for searching the site.*/
#search {
 align:text;
 left: auto;
 position:absolute;
 right: 5px;
 top: 45px;
 z-index: 1000;
}

#search .search_box {
 background-position: 2px 2px; 
 background: white url($icon_base_url{}icons/search.png) no-repeat;
 border-radius: 5px;
 padding: .2em .2em .2em 1.5em;
}
#search .search_button {
 display: none;
}


/*-- #page ------------------------------------------------------------------

  #page groups content that relates to the particular page rather than the
  site as a whole. This includes both the actual content of the page and an
  additional set of tool or navigational elements. #page contains the
  following divs: #breadcrumbs, #toolbar, #node_title, and #content.

----------------------------------------------------------------------------*/

#page { /* no styling on at the moment */
  background-color: $TEXT_BG_COLOR;
  border-radius: 10px 10px 0 0;
}
#page p {
 line-height: 1.3;
 width: 80%;
}

#breadcrumbs {
 display: none;
}

#node_title {
 margin: 4em 1em 10px $LEFT_MARGIN;
}
#node_title a{
 color: $BOLD_COLOR_1;
 font-family: $if_use_web_fonts[['Sputnik Header Web Font',]] 'Arial', sans-serif;
 font-size: 240%;
 text-decoration: none;
}
img.title_icon {
 margin-bottom:15px;
 margin-right: 5px;
}

#toolbar {
 float: right;
 margin: 0px 10px 0px 0px;
}

#node_content {
 height: 100%;
 padding: 2em 2em 2em $LEFT_MARGIN;
}

/* Generic content tags */

b, strong {
 font-weight: bold;
}
i, em, emphasis {
 font-style:italic;
}

h1, h2, h3 {
 margin-bottom: .5em;
 margin-top: 1em;
 padding-bottom: .5em;
}
h4, h5, h6, p {
 margin: 5px 0 5px 0;
 padding: 5px 0 5px 0;
}
h1, h2 {
 color: $BOLD_COLOR_2;
}
h1, h2 {
 border-bottom: 1px solid $BOLD_COLOR_1;
}
h1 {
 font-size: 180%;
}
h2 {
 font-size: 140%;
}
h3 {
 font-size: 129%;
}
h4 {
 font-size: 107%;
 font-weight: bold;
}

blockquote {
 border-left: 2px solid #cccccc;
 line-height: 1.1;
 margin-left: 5em;
 padding-left: 1em;
 width: 80%;
}
blockquote p {
 line-height: 1.1;
 padding-bottom: .5em;
 padding-top: .5em;
}

table {
 border: 1px solid gray;
}
table.noborder {
 border: none;
}
table tr td, table tr th {
 border: 1px solid gray;
 padding: .5em;
}
table.noborder tr td, table.noborder tr th {
 border: none;
}

table tr th {
 font-weight: bold;
}

ul {
 list-style: disc;
 padding-left: 3em;
}
ol {
 list-style: decimal;
 padding-left: 3em;
}
#content>ul li, #content>ol li {
 line-height: 1.3;
 padding-top: .2em;
 padding-bottom: .2em;
 width: 80%;
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
 font-size: 90%;
 padding: 1em;
 padding-bottom: .5em;
 padding-top: .5em;
}


/* Extra content rules */

.teaser {
 font-size: 130%;
 font-weight: bold;
}
a.footnote {
 font-size:10px;
 text-decoration: none;
 vertical-align:top;
}
span.footnote {
 margin-top: 20px;
}

.error, .warning, .success, .notice {
 border-style: solid;
 border-width: medium;
 margin-bottom: 1em;
 padding: .5em;
 width: 90%;
}
.error {
 background-color: #F8E0E0;
 border-color: #DF0101;
}
.warning {
 background-color: #F8F8D0;
 border-color: #DF0101;
}
.success {
 background-color: #D0F8D0;
 border-color: #01DF01;
}
.notice {
 background-color: #D0D0F8;
 border-color: #0101DF;
}

ins {
 background: #d0f8d0;
 text-decoration: none;
}
del {
 background: #f8f8d0;
}


/*-- Edit forms -------------------------------------------------------------

  The edit form puts individual fields into divs, then groups those divs and
  gives them headings:

    h2#trigger_group1 -- group 1 title
    div#group1
       div.field
         label
         field

  Groups can be collapsed through Javascript.
----------------------------------------------------------------------------*/

h2.ctrigger { /* a header that controls collapsing a group, in open state */
 background: url($icon_base_url{}icons/minus.png) no-repeat right;
}
h2.ctrigger.closed {  /* a header that controls collapsing a group, closed */
 background: url($icon_base_url{}icons/plus.png) no-repeat right;
}
form div.honey {  /* a honeypot field */
 display: none;
}
form div.field {  /* a regular field */
 background-color: #ddd;
 margin-bottom: 2px;
 padding: .5em .2em .1em .5em ;
}
div.grippie { /* a grippie for resizing text areas */
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

form label.inline {
 display: inline-block;
 width: 200px;
}
form textarea {
 font-size: 110%;
 padding: 1em;
 width: 95%;
}
form label {
 padding: .5em;
}

button {
 font-size: 120%;
}

div.submit {
 margin-top: .5em;
}

/*-- #menu ------------------------------------------------------------------

  The menu contains links to other pages on the site. The menu can often be
  quite big, so we may want to put the HTML for it in the end of the page,
  then pull it up or to the side with CSS. This stylesheet turns the menu
  into a two-level system of tabs.
----------------------------------------------------------------------------*/

#menu {
 position: absolute;
 top: 145px;
 width: $CONTAINER_WIDTH;
 z-index: 1000;
}
#menu a {
 text-decoration: none;
 color: $BRIGHT_LIGHT_TEXT_COLOR;
}
#menu > ul {                          /* the top level menu */
 display: block;
 padding: 0em;
 text-align: left;
 width: 100%;
}
#menu > ul > li {                      /* top level menu items */
 background-color: $INACTIVE_MENU_COLOR;
 border-bottom: none;
 border-radius: 15px 15px 0 0;
 display: inline;
 margin: 1em .2em 1em .2em;
 padding: .5em .5em 1.5em .5em;
}
#menu > ul > li.first {
 margin-left: $LEFT_MARGIN_FOR_MENU;
}
#menu > ul > li > a {
 font-family: 'Arial', sans-serif;
 font-size: 120%;
 padding: .3em;
}
#menu > ul > li.current {              /* current top level item */
 background-color: $BOLD_COLOR_2;
}
#menu > ul > li.other {                /* other top level items */
 background-color: $INACTIVE_MENU_COLOR;
}
#menu > ul > li.other > a:hover {
 color: yellow;
}

/* 2nd level menu */

#menu > ul > li.other > ul {           /* hide all subitems of _other_ items */
 display: none;
}

#menu > ul > li.current > ul {         /* current second level menu */
 background: $BOLD_COLOR_2;
 margin-top: .5em;
 padding-left: 0em;
 padding-top: .7em; padding-bottom: .7em;
 position: absolute;
 width: $CONTAINER_WIDTH;
 z-index: 1004;
}
#menu > ul > li.current > ul > li {    /* current second level menu items */
 display: inline;
 z-index: 1005;
}
#menu > ul > li.current > ul > li.first {
 margin-left: $LEFT_MARGIN_FOR_MENU;
}
#menu > ul > li.current > ul > li > a {
 color: $BRIGHT_LIGHT_TEXT_COLOR;
 font-family: Arial, sans-serif;
 margin: .3em 1em .5em 1em;
 padding-bottom: .25em;
 z-index: 1006;
}
#menu > ul > li.current > ul > li.current > a {
 border-bottom: .2em solid #555;
}
#menu > ul > li.current > ul > li.other > a:hover {
 color: yellow;
}


/*-- An alternative #menu --------------------------------------------------

  Comment out the earlier #menu directives and uncomment the ones in this
  section to display the menu as a list floating to the left. Other things
  will need to be adjusted for this to actually look pretty, so this is just
  to get you started.
----------------------------------------------------------------------------*/

/*
#menu a {
 color: $BRIGHT_LIGHT_TEXT_COLOR;
 text-decoration: none;
}
#menu > ul {
 left: 0px;
 padding: 5px 5px 5px 5px;
 position: absolute;
 top: 220px;
}
#menu > ul > li > a {
 padding: 5px 5px 5px 5px;
}
#menu > ul > li > ul > li > a {
 font-size: 90%;
}
#menu > ul > li > ul > li.current > a {
 color: yellow;
}

*/

/*-- #footer ----------------------------------------------------------------

  Information that appears on every page but is less important than the stuff
  that goes into #header.
----------------------------------------------------------------------------*/

#footer {
 background-color: $BOLD_COLOR_2;
 color: $BRIGHT_LIGHT_TEXT_COLOR;
 margin-top: 20em;
 padding-top: 10px; padding-bottom: 10px;
 width: $CONTAINER_WIDTH;
}
#footer p {
 margin-left: $LEFT_MARGIN;
}
#footer a {
 color: $DULLER_LIGHT_TEXT_COLOR;
}
#footer a.etc {
  font-size: .7em
}


/*-- discussion -------------------------------------------------------------

  Rules for discussion markup.
----------------------------------------------------------------------------*/

.disc_snippet {
  display: none;
}
.comment {
  border: 1px solid gray;
  background: #ddd;
  margin-bottom: 1em;
  padding: 0;
  background-color: white;
}

.comment > .content {
  border-top: 1px solid purple;
  padding: .5em;
  margin: 0;
}

.comment > .post-header {
  padding-left: .5em;
  background-color: #ddd;
}

.comment > .post-header > .comment_id {
  font-size: 120%;
  font-weight: bold;
  float:right;
}

ul.post-toolbar {
 list-display: none;
 padding: .5em;
 margin: 0;
}
ul.post-toolbar li {
 display: inline;
}
ul.post-toolbar li a {
 text-decoration: none;
 color: black;
 border: 1px solid #bbb;
 background-color: #ddd;
 border-radius:3px;
 padding: 2px;
 font-size: 70%;
}

/*-- Popups ------------------------------------------------
----------------------------------------------------------------------------*/

.popup_background {
 z-index : 100000;
 width: 100%;
 height: 100%;
 position: absolute;
 top: 0;
 left: 0;
 background: rgba(0,0,0,0.7);
}

.popup_frame {
 width: $POPUP_WIDTH;
 margin-left: auto;
 margin-right: auto;
 margin-top: $POPUP_TOP;
 background: white;
 padding: 10px;
 box-shadow: 10px 10px 5px #444;
 border-radius: 10px;
}

.popup_content {
 background: white;
}

/*-- Config code with issues ------------------------------------------------
----------------------------------------------------------------------------*/


table.code {
 width: 100%;
 border-style: none;
 margin-bottom: 1em;
}
table.code th {
 font-size: 90%;
 line-height: 90%;
}
table.code th a{
 text-decoration: none;
 color: black;
}
table.code th.lineno { 
 width: 4em;
}
table.code th.bad {
 background: red;
}
table.code td {
 border: 1px solid #999;
  line-height: 90%;
}
table.code code {
 background: white;
}
table.code code.bad{
 background: yellow;
}

/*-- alternative media ------------------------------------------------------

  Special rules for media other than screen.
----------------------------------------------------------------------------*/

@media print {
 #menu, #login, #search, #footer, .toolbar {
   display: none; !important;
 }
 body, container, page {
   background-color: white;
   border: none;
   margin: 0px;
   padding: 0px;
 }
}


/*-- additional css ---------------------------------------------------------

  Additional CSS to be included based on the site configuration.
----------------------------------------------------------------------------*/

$more_css

]===]

