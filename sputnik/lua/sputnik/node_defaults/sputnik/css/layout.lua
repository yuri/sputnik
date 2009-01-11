module(..., package.seeall)

NODE = {
   title="CSS for Layout",
   prototype="@CSS"
}
NODE.content=[===[

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
 margin     :    0em   0em   0em   0em;
 padding    :   1em   0em  .5em   0em;
 font-size  : 270%;
 font-weight: normal;
}
.title_icon {
 margin     :    0em   0em .15em   0em;
}
h1 a {
 text-decoration: none;
}
h2 {
 margin     :    2em  .3em   1em  -1em;   
 padding    :    0em   0em   0em   1em;
 font-size  : 140%;
 font-weight: normal;
}
h3 {
 margin:   20px   3px  10px  -5px; 
 padding:   1px   5px   1px   1em;
 font-size  : 129%; 
 font-weight: normal;  }
h4 {
 margin:   20px   3px  10px  -5px; 
 padding:   1px   5px   1px   1em;
 font-size  : 107%; 
 font-weight: normal;
}
h5 {
 margin:   20px   3px  10px  -5px; 
 padding:   1px   5px   1px   1em;
 font-size: 100%; 
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
 font-size  : 90%
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
a {
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
input {
 margin:   .5em  .5em .5em  .5em; 
 padding:   3px   3px   3px   3px;
 line-height: 20px;
 min-height : 20px; 
 font-family: monospace
}
select {
 margin:   auto  auto   5px 200px; 
 padding:   3px   3px   3px   3px; line-height: 20px;
 display    : block;
 min-height : 20px; 
 width      : 168px;
 height     : 27px;
}
option {
 margin:    0em   0em   0em   0em; 
 padding:   0em   0em   0em   0em; spacing    : 0em;
}
input.button {
 margin:    5px   4px   5px   4px;
}
input.search_box {
 margin:    0em   1px  auto   4px; 
 padding:   2px  auto   2px  auto;
 display : inline;
 line-height: 10px;  
 font-size  : 9pt;
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
	background:#F3F3F3 url($make_url{node="sputnik/grippie.png"}) no-repeat scroll center 2px;
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

span.ctrigger {
display : block;
width: 100%;
}

span.ctrigger {
  background: url($make_url{node="icons/minus.png"}) no-repeat right;
}
span.ctrigger.closed {
  background: url($make_url{node="icons/plus.png"}) no-repeat right;
}

.yui-t0 #sidebar {
  display: none;
}
.yui-t0 #page {
  margin-left: 3em;
}

]===]

