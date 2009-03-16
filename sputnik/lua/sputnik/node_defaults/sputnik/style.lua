module(..., package.seeall)

NODE = {
   title="Color Configuration",
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
MAIN_HUE             = MAIN_COLOR or 200  -- pick a number between 0 and 360
STARTING_SATURATION  =  .7  -- pick a number between 0 and 1
MAIN                 = colors.new(MAIN_HUE, STARTING_SATURATION, .50)

SECOND, THIRD        = MAIN:neighbors()      -- MAIN:terciary() for more contrast
THIRD                = SECOND                -- stick with just one color

GRAY                 = MAIN:desaturate_to(0) -- set value > 0 to make your "grays" lightly colored
LIGHT_GRAY           = GRAY:tint(.7)         -- higher number = lighter
LIGHTEST_GRAY        = GRAY:tint(.9)         -- higher number = lighter
DARK_GRAY            = GRAY:shade(.7)        -- higher nu mber = darker
WHITE                = "white"
BLACK                = "black"

BODY_BG              = BODY_BG_COLOR or MAIN:desaturate_to(0):tint(.3)
LINK                 = "#0000cc" -- darker blue
TEXT                 = BLACK

NAVBAR               = SECOND:desaturate_to(.7):shade(.1)

MENU_TEXT         = WHITE
MENU_TEXT_HOVER   = "yellow"
MENU_BG           = SECOND:shade(.5)
MENU_BG_HOVER     = SECOND:shade(.4)
SUBMENU_CURRENT_BG     = THIRD:shade(.2)
SUBMENU_CURRENT_BORDER = WHITE
SUBMENU_CURRENT_FG     = WHITE
SUBMENU_BG           = THIRD:shade(.2)
SUBMENU_BORDER  = THIRD:tint(.3)
SUBMENU_FG      = WHITE

HEADER               = THIRD:shade(.1)
H_LINE               = THIRD:shade(.1)

FORM_BG              = WHITE --SECOND:desaturate_to(.6):tint(.9)
FORM_BG_SUBMIT       = SECOND:desaturate_to(.8):tint(.3)
FORM_BG_READONLY     = SECOND:desaturate_to(.2):tint(.7)
FORM_BORDER          = SECOND
INS                  = "#cfc"

icon_plus_wrapped = [=[
iVBORw0KGgoAAAANSUhEUgAAABEAAAARCAYAAAA7bUf6AAAAAXNSR0IArs4c6QAAAAZiS0dEAP8A/
wD/oL2nkwAAAAlwSFlzAAALEwAACxMBAJqcGAAAAAd0SU1FB9gMFBUUKV7DN4kAAAAZdEVYdENvbW
1lbnQAQ3JlYXRlZCB3aXRoIEdJTVBXgQ4XAAAAKUlEQVQ4y2NgoAJgJCD/nxi1TNRwyaghuGPnPyV
mDD7vjCa2wWgIVQAA4ZoDHFUwDWsAAAAASUVORK5CYII=
]=]

icon_plus = icon_plus_wrapped:gsub("%s", "")

]]

NODE.content = [===[

$reset_code

/* Note that the layout of the top level objects is largely determined by YUI. 

   The sequence of divs at the top level elemens:

   html
    head
    body
     div #doc3 (or doc2, doc, etc.)
      div #hd      -- the navigation bar
       div #login
       div #logo
       div #menu_bar
        ul.menu #menu
         li.front #Section_1
         li.back  #Section_2
         ul.submenu #submenu
          li.front #Page_1
          li.back  #Page_2
     div #bd
      div #yui-main
       div.yui-b #page
        span.toolbar
        h1.title
         a.local
        div.content
      div.yui-b #sidebar

margin/padding cheatsheet:  top right bottom left;

*/

/* TOP LEVEL ELEMS    */
html {
 overflow   : -moz-scrollbars-vertical;
 overflow-y : scroll;
 /* always use a vert. scroll bar. */
}

body { 
 min-width  : 800px; 
 text-align : left;
}

/* THE HEADER */

#hd {
 margin     :    0em   0em   0em   0em;
 padding    :    0em   0em   0em   0em;
}

#login {
 margin     :    0em   0em   0em   0em;  
 padding    :   .4em   0em   0em   0em;
 float      : right;
 text-align : right;         
 font-size  : 90%;
 vertical-align: text-bottom;
}
#rss_icon {
 margin     :    0em   0em   0em   0em; 
 padding    :    0em   0em   0em   0em;
 position   : relative; 
 top        : 3px
}
#logo {
}

#menu_bar ul#menu {
 margin     :  1.1em   0em   0em   0em; 
 padding    :    0em   0em   0em   0em;
 width      : 100%; 
 text-align : left;
 display    : block;
}
#menu_bar ul#menu li {
 margin     :    0em  .5em   0em   0em;  
 padding    :    0em   0em   0em   0em;
 display    : inline;  
 list-style-type: none;
}
#menu_bar ul#menu li a    {                                 
 padding    :   .3em   1em 0.3em   1em;
 position   : relative;
 text-decoration: none;
}

ul#menu li {
 font-size  : 140%; 
}

ul#menu li ul li {
 font-size  : 80%; 
}


#menu_bar ul#menu li ul {
 margin     :    0em   0em   0em   0em;
 padding    :   .8em   0em  .4em   0em;
 position   : relative; 
 left       : 0em;
 top        : 0em;
 min-height : 20px;
 text-align : left;
 display    : block;
}
#menu_bar ul#menu li ul.back {
 display    : none
}
#menu_bar ul#menu li ul.front{
 float      : left; 
 width      : 100%;
 z-index    : 1000
}
#menu_bar ul#menu li ul li{
 margin     :    0em   0em   0em   0em; 
 padding    :    0em   0em   0em   0em;
 display    : inline;
 list-style-type: none;
}

#sidebar ul#menu {
 margin: .3em 0 0 .3em ;
 list-style-type: none;
}

#sidebar ul#menu ul.back {
 display:none
}

#sidebar ul#menu, #sidebar ul#menu li {
 padding: 0 0 0 0;
}

#sidebar ul#menu li a {
 padding: 0.3em .2em .3em 1em;
 margin: 0 0 0 0;
 display: block;
 width: 80%;
}

#sidebar ul#menu li ul {
 padding: 0 0.5em 0 1em;
}

#menu_bar ul#menu li ul li a {
 margin     :    0em  .5em   0em  .5em; 
 padding    :    0em  .2em   0em  .2em;
 font-size  : 100%;
 font-family: Verdana, sans-serif;
 font-weight: bold;
}

ul#menu li a, ul#menu li ul li a {
 text-decoration:none;
}

/* "BODY"           */
#bd {
 margin:    0em   0em   0em   0em;
 padding:   0em   0em   0em   0em;
}
#yui-main {
}
#page {
 padding    :   0em   0em   0em   0em;
 min-height : 450px;
}

/* MESSAGES       */
.error, .warning, .success, .notice {
 margin     :    1em  auto  .5em  auto;  
 padding    :    1em   1em   1em   1em;
 width      : 90%; 
}
.error {
 border     : medium solid #DF0101; 
 background-color: #F8E0E0;
}
.warning {
 background-color: #F8F8D0;  
 border     : medium solid #DF0101;
}
.success {
 background-color: #D0F8D0; 
 border     : medium solid #01DF01; 
}
.notice {
 background-color: #D0D0F8; 
 border     : medium solid #0101DF; 
}

/* CONTENT = toolbar + actual content                                  */
.content       {
 padding    :   1em   3em   1em   3em;
 font-size  : 100%;
 max-width  : 700px;
} 
.crumbs_and_tools {
 margin     :    0em   0em   0em   0em; 
 padding    :   .5em  .5em  .5em   2em; width      : 100%;
}
.toolbar {
 margin     :    0em  .5em   0em   0em; 
 padding    :   .5em  .5em  .5em   2em;
 float      : right;
 /*position   : absolute;
 right      : 0;*/
}

.toolbar a {
 text-decoration: none;
}

/* ELEMENTS IN CONTENT --------------------------------------------------- */

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

.title a {
 font-size: 270%;
 text-decoration: none;
}

.title {
 color: orange;
 margin: 0 0 0 0;
 padding: 0 0 1em 1em;
}

h1, h2, h3, h4, h5 {
 margin     :    1.5em   0em    1em   0em;
 padding     :    0em   0em   0em   0em;
 font-weight: normal;
}

ul {
 margin:   10px   0em  10px  15px;
 list-style-type: square
}
li {
 line-height: 150% 
}
ol {
 margin:   10px   0em  10px  24px;
 list-style-type: decimal
} 
p  {
 margin:   15px   0em  auto  auto;
 line-height: 155%
}
blockquote {
 margin:   15px   0em  auto   3em;
 line-height: 120% 
}
code {
 padding:   2px   2px   2px   1em;
 font-size  : 100%;
 font-family: monospace
} 
pre {
 margin:   15px   0em  auto  auto; 
 padding:   8px  20px   8px   1em;
 display    : block; 
 font-family: monospace;
 font-size  : 90%;
 overflow: auto;
}
pre code {
 padding:   0em   0em   0em   0em;
}
th {
 padding:   2px   5px   2px   5px;
 vertical-align: top;
 font-weight: bold
}
td {
 padding:   2px   5px   2px   5px;
 vertical-align: top;
}
em {
 font-style : italic
}
strong {
 font-weight: bold
}
a.local {
 padding:  auto   3px  auto  auto;
 background : none transparent scroll repeat 0% 0%;
}

span.preview {
 margin:   auto   5px  10px  auto; 
 padding:   5px   5px   5px   5px;
}

form {
 /*display    : inline*/
}
label {
 margin     :   10px  .5em  1em  auto;
 font-weight: bold
}
label.inline {
 display    : inline-block;
 width: 200px; 
}
input, select {
 margin:   .5em  .5em .5em  .5em; 
 padding:   3px   3px   3px   3px;
 line-height: 20px;
 min-height : 20px; 
 font-family: monospace
}
select {
 min-width: 300px;
}
option {
 margin:    0em   0em   0em   0em; 
 padding:   0em   0em   0em   0em; spacing    : 0em;
}
input.button {
 margin:    5px   4px   5px   4px;
}

form.search {
 margin-right: 0px;
 padding-right: 0px;
 display: inline;
}

input.search_box {
 margin:    0em   0px  0px   0px; 
 padding:   2px  2px   2px  2px;
 display : inline;
 line-height: 10px;  
 font-size  : 9pt;
 vertical-align: text-bottom;
 height: 22px;
}
input.search_button {
 margin:    0em   0px  0px   0px; 
 padding:   2px  2px   2px  2px;
 display : inline;
 line-height: 10px;  
 font-size  : 9pt;
 border: none;
 background: none;
 vertical-align: text-bottom;
}
input.submit {
 margin:   .8em   0em  .8em  .4em; 
 padding:  .3em  .5em  .3em .5em;
 display    : inline; 
 float: right;
 font-size: 140%;
 width: 180px;
}
a.button {
 margin:   .8em    0em  .8em  .4em; 
 padding:  .3em  .5em  .3em .5em;
 font-size: 140%;
 width: 180px;
}
input.small_submit {
 margin:   auto   0em  auto   1px; 
 padding:   1px   0em   1px  auto;
 display    : inline;
 line-height: 10px; 
 font-size: 90%;
}
input.diff_radio   {
 margin:    0em   0em   0em   0em; 
 padding:   0em   0em   0em   0em;
}
textarea {
 margin:   1em  1em   5px  1em; 
 padding:   4px   2px   1px   2px;
 font-family: monospace;
}
input.textfield {
 min-width: 300px;
}
#more_fields       {margin:   auto  auto  auto 200px; 
                    padding:  auto  auto  auto 200px; display: block;        }
input.hidden       {                                  display: none;         }
div.hidden         {                                  display: none;         }
div.honey          {                                  display: none;         }
div.advanced_field {                                  display: none;         }

ins                {                                  text-decoration: none  }

.history_dates     {                                  font-size  : 80%;      }
.error_message     {margin:   15px  15px  15px  15px; 
                    padding:  15px  15px  15px  15px;                        } 
.teaser            {                                  font-size  : 120%; 
 font-weight: bold      }

#breadcrumbs       {margin:    0em   0em   0em   0em; 
	                padding:   0em   0em   0em  .5em; float      : left;
 width      : 100%;
 min-height : 3em;      }
#breadcrumbs ul    {margin:    0em   0em   0em   0em;
	                padding:   0em   0em   0em   0em; display    : inline;
 list-style : none;     }
#breadcrumbs li    {margin:    0em   0em   0em   0em;
	                padding:   0em   0em   0em   0em; display    : inline;   }
#breadcrumbs a     {margin:    0em  .5em   0em   0em; text-decoration: none; }

textarea.resizeable{
 height     : 20%;
}

div.field {
 margin-bottom: 2px;
 padding: .5em .2em .1em .5em ;
 background-color: #ddd;
 
}

div.grippie {
	background:#F3F3F3 url($icon_base_url{}sputnik/grippie.png) no-repeat scroll center 2px;
	border-color:#DDDDDD;
	border-style:solid;
	border-width:0pt 1px 1px;
	cursor:s-resize;
	height:6px;
	overflow:hidden;
	margin-bottom: 10px;
    width: 70px;
    margin-left: 300px;
}

h2.ctrigger {
  background: url($icon_base_url{}icons/minus.png) no-repeat right;
}
h2.ctrigger.closed {
  background: url(data:image/png;base64,$icon_plus) no-repeat right;
}

.yui-t0 #sidebar {
  display: none;
}
.yui-t0 #page {
  /*margin-left: 3em;*/
}

/*.yui-u > * {
  margin-right: .5em;
  margin-left: 1em;
}

.yui-u h2, .yui-u h3, .yui-u h4, .yui-u h5 {
  margin-right: .5em;
  margin-left: .5em;
} */

.box {
  /*margin-right: .5em;
  margin-left: .5em;*/
  border: 1px solid green;
  background-color: #efe;
}


body                  {                          background: $BODY_BG;                                                     }

#bd                   {                          background: $WHITE;               BORDER:        1px solid  $DARK_GRAY;   }
#sidebar              {
 /*border-right:  1px solid  $NAVBAR;      */
}

.title                {                                              BORDER-BOTTOM: 3px solid  $NAVBAR;      }
.title a:visited              { color: black;   }
H1                    { COLOR: $HEADER;                                            BORDER-BOTTOM: 3px solid  $NAVBAR;      }
H2                    { COLOR: $HEADER;                                            BORDER-BOTTOM: 2px solid  $H_LINE;      }
H3                    { COLOR: $HEADER;                                            BORDER-BOTTOM: 1px dotted $H_LINE;      }
ul#menu li a             { color: $MENU_TEXT;       background: $MENU_BG;                                                  }

#sidebar ul#menu li.level1 > a:hover    {
 color: $MENU_TEXT_HOVER;       
}
#menu_bar ul#menu li a:hover    {
 color: $MENU_TEXT_HOVER;
}
ul#menu li.front a    {                          background: $NAVBAR;                                                      }

ul#menu li ul li a {
 background: white;
 color: black;
}
ul#menu li.front ul li a {
 background: white;
 color: black;
}

#menu_bar ul#menu li ul            {                          background: $NAVBAR;                                                      }
#menu_bar ul#menu li ul li.front a { color: $WHITE;           background: $SUBMENU_CURRENT_BG;  BORDER:        2px solid  $SUBMENU_CURRENT_BORDER; }
#menu_bar ul#menu li ul li.back a  { color: $SUBMENU_FG;      background: $SUBMENU_BG;          BORDER:        1px solid  $SUBMENU_BORDER; }
#menu_bar ul#menu li ul li a:hover { color: $MENU_TEXT_HOVER;                                                                           }

#sidebar ul#menu li ul li.front a {
 font-weight: bold;
}


DEL                   { COLOR: $BLACK;           background: $LIGHT_GRAY;                                                  }
INS                   { COLOR: $TEXT;            background: $INS;                                                         }
A:link                { COLOR: $LINK;                                                                                      }
A:visited             { COLOR: $LINK;                                                                                      }
A:hover               { COLOR: $LINK;                                                                                      }
A.no_such_node        {                          background: #fffacd;                                                      }

CODE                  {                          background: $LIGHTEST_GRAY;                                               }
PRE                   {                          background: $LIGHTEST_GRAY;       BORDER:        1px solid  $LIGHT_GRAY;  }
TH                    {                          background: $LIGHTEST_GRAY;       BORDER:        1px solid  $LIGHT_GRAY;  }
TD                    {                                                            BORDER:        1px solid  $LIGHT_GRAY;  } 
.preview              {                                                            BORDER:        4px solid  #666;         }
.missing_page         {                          background: $LIGHT_GRAY                                                   }




input, select, textarea {
 background: $FORM_BG;
 border:        2px solid  $GRAY; 
}
input.readonly {
 background: $FORM_BG_READONLY;
}

input.submit {
 background: $FORM_BG_SUBMIT;
}

.active_input {
  border: 2px solid $NAVBAR;
  background: #ffffd6;
}



A.button              {                          background: $FORM_BG_SUBMIT;      BORDER:        1px outset $FORM_BORDER; 
    color: black; text-decoration: none;                                                                               
}
INPUT.small_submit    {                          background: $FORM_BG_SUBMIT;      BORDER:        1px outset $FORM_BORDER; }
.save input           {                          background: #ffa20f;              border:        2px outset #d7b9c9       }

.error_message        {                                                            BORDER:        2px solid  red;          }
.content .preview     {                                                            BORDER:        3px dashed $NAV_BAR;     }



div.popup_form div.transparency {
  background: black;
  height: 100%;  width: 100%;
  position: absolute;
  top: 0px;
  left: 0px;
  z-index: 10000;
  opacity: .7;
}

div.popup_form div.popup_frame {
  margin: 100px;
  padding: .3em;
  border: 5px solid $NAVBAR;
  background: white;
  position: absolute;
  width: 700px;
  opacity: 2;
  z-index: 10001;
}

div.popup_form div.actual_form {
  padding: 2em;
}

div.close_popup {
  width: 100%;
  text-align: right;
}

/* Comments Styles */

ol.discussion {
    margin: 0;
    list-style-type: none;
}

ol.discussion li {
   padding-bottom: 10px;
}

ol.discussion div.content {
    clear: both;
    padding: 5px 20px;
    margin: 0;
}

ol.discussion div.header {
    border-bottom-color: black;
    border-bottom-style: solid;
    border-bottom-width: 2px;
    padding-bottom: 5px;
}

ol.discussion ul.toolbar {
    float:right;
    list-style: none;
    margin: 0;
    padding: 0;
    padding-top: 1em;
}

ol.discussion ul.toolbar li {
    float: left;
    margin: 0;
    padding: 0;
    padding-left: 8px;
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

]===]

