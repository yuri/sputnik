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

/*-- RESET ------------------------------------------------------------------

  Before applying any styling, we start with a global reset to bring
  everything to the same baseline. The reset code is based on
  http://meyerweb.com/eric/tools/css/reset/ 

----------------------------------------------------------------------------*/

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


/*-- The body and the #container --------------------------------------------

  The <body> has a single div inside it - #container. This way, the container
  includes everything, but can be narrower than the body and can have
  a different background. The children of container are:

     #header - the site-level elements that we want to show prominently
     #page - the content that is specific to this node
     #menu - the navigation system (links to other pages)
     #footer - less importnat site info
----------------------------------------------------------------------------*/

body {
 background-color: gray;
}
#container {
 background-color: white;
 height: 100%;
 margin: 0 auto 0 auto;
 width: $CONTAINER_WIDTH;
}


/*-- #header ----------------------------------------------------------------

  The header is a div that includes elements that do not change from one
  node to another. We call it a "header" since it usually comes at the top
  of the page, though we can put it anywhere.

  The #header includes: #logo, #login, #search.
----------------------------------------------------------------------------*/

#header {
 background: $HEADER_COLOR;
 height: 150px;
 padding-left: 10px;
 position: relative;
}

/* #logo identifies the site and links to the front page. */
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
#logo a.home_page { /* a link to the home page */
 display: block;
 padding: 5px 20px 5px 20px;
}
p.site_title { /* a title for the site */
 font-size: 200%;
}
p.site_subtitle { /* a subtitle for the site */
 font-style:italic;
}

/* #login contains the login status and the links to login/logout/register. */
#login {
 position:absolute;
 top: 45px;
 left: 700px;
 z-index: 1000;
}
#login a {
 text-decoration: none;
 font-weight: bold;
}

/* #search contains a form for searching the site.*/
#search {
 position:absolute;
 align:text;
 top: 10px;
 left: 700px;
 z-index: 1000;
}


/*-- #page ------------------------------------------------------------------

  #page groups content that relates to the particular page rather than the
  site as a whole. This includes both the actual content of the page and an
  additional set of tool or navigational elements. #page contains the
  following divs: #breadcrumbs, #toolbar, #page_title, and #content.

----------------------------------------------------------------------------*/

#page { /* no styling on at the moment */
}
#page p {
 line-height: 1.4;
}

#breadcrumbs {
 display: none;
}

#page_title {
 margin: 4em 1em 2em 2em;
}
#page_title a{
 color: $ACTIVE_GRAY;
 font-size: 240%;
 text-decoration: none;
}

#toolbar {
 float: right;
 margin: -5px 10px 0px 0px;
}

#content {
 height: 100%;
 padding: 2em 2em 2em 2em;
}

/* Generic content tags */

b, strong {
 font-weight: bold;
}
i, emphasis {
 font-style:italic;
}

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
 line-height: 1;
 margin-left: 5em;
 padding-left: 1em;
}
blockquote p {
 line-height: 1;
 padding-bottom: .5em;
 padding-top: .5em;
}

ul {
 list-style: disc;
 padding-left: 3em;
}
ol {
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


/* Extra content rules */

.teaser {
 font-size: 120%;
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
form.edit div.honey {  /* a honeypot field */
 display: none;
}
form.edit div.field {  /* a regular field */
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

form.edit label.inline {
 display: inline-block;
 width: 200px;
}
form.edit textarea {
 font-size: 110%;
 padding: 1em;
 width: 95%;
}
form.edit label {
 padding: .5em;
}


/*-- #menu ------------------------------------------------------------------

  The menu contains links to other pages on the site. The menu can often be
  quite big, so we may want to put the HTML for it in the end of the page,
  then pull it up or to the side with CSS. This stylesheet turns the menu
  into a two-level system of tabs.
----------------------------------------------------------------------------*/

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
 padding-left: 0em;
}
#menu ul li {
 display: inline;
 margin-left: 10px;
 padding-right: 1em;
}
#menu ul li.other ul {
 display: none;
}
#menu ul li.current ul {
 background: $SUBMENU_COLOR;
 float: left;
 margin-top: 1em;
 padding-top: .7em; padding-bottom: .7em;
 padding-left: 0em;
 width: $CONTAINER_WIDTH;
 z-index: 1000;
}
#menu ul li.current ul li{
 display: inline;
 z-index: 1001;
}
#menu a {
 text-decoration: none;
}
#menu ul li a {
 padding: .3em;
}
#menu ul li.current a {
 border-bottom: .2em solid $SUBMENU_COLOR;
 color: $SUBMENU_COLOR;
}
#menu ul li.other a {
 border-bottom: .2em solid #555;
}
#menu ul li.current ul li {
 margin: 0;
 padding: 0;
}
#menu ul li.current ul li a {
 color: white;
 font-family: Verdana, Arial, sans-serif;
 font-size: 70%;
 margin-left: 10px;
 padding: .3em 1em .3em 1em;
}
#menu ul li.current ul li.current a {
 background: $ACTIVE_GRAY;
}
#menu ul li.current ul li.other a {
 background: $SUBMENU_COLOR;
}
#menu ul li.current ul li.other a:hover {
 background-color: gray;
}


/*-- An alternative #menu --------------------------------------------------

  Comment out the earlier #menu directives and uncomment the ones in this
  section to display the menu as a list floating to the left. Other things
  will need to be adjusted for this to actually look pretty, so this is just
  to get you started.
----------------------------------------------------------------------------*/

/*
#menu a {
 text-decoration: none;
 color: white;
}
#menu > ul {
 position: absolute;
 top: 220px;
 left: 0px;
 padding: 5px 5px 5px 5px;
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
#footer a.etc {
  font-size: .7em
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

