module(..., package.seeall)
NODE = {
   title = "Templates for S9",
   prototype = "@Lua_Config"
}

NODE.permissions = [[
   allow(all_users, "edit")
]]

NODE.content = [========[

SLIDESHOW = [[<html>
  <!-- shamelessly stolen from http://slideshow.rubyforge.org/ -->
  <head>
  <meta name="slideselector" content=".slide">
  <meta name="titleselector" content="h1">
  <meta name="stepselector" content=".step">
  <title>$title</title>
  <style type="text/css">
    @media screen {
     .layout { display: none; }
     .banner {
        display: block;
        border: green solid thick;
        padding: 1em;
        font-family: sans-serif;
        font-weight: bold;
        margin-bottom: 2em;
      } 
    }
    @media projection {     
     body {
        height: 100%; margin: 0px; padding: 0px;
        font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
        color: white;  
        opacity: .99; 
     }    
    .slide {
      page-break-after: always;
      padding-left: 2em;
      padding-top: 2em;
    }
    .banner {
      display: none;
    }
    .layout {
      display: block;
    }
    div.background {
        position: fixed;
        left: 0px;
        right: 0px;
        top: 0px;
        bottom: 0px;
        z-index: -1;
    }
    a:link, a:visited {
        color: white;
    } 
    a:hover { background-color: yellow; }
    h1, h2 { font-size: 36pt;  }    
    h3 { font-size: 25pt;  }
    p, li, td, th { font-size: 18pt; }
    pre { font-size: 16pt;  }
    pre.code { font-size: 16pt;
        background-color: black;
        color: white;
        padding: 5px;
        border: silver thick groove;
        -moz-border-radius: 11px;
    }
   }  
  </style>
 </head>

 <body>
  <div class="layout"> 
   <div class="background">  
    <object data="http://media.freewisdom.org/etc/sputnik-background.svg" width="100%" height="100%">
   </div>    
  </div> 
  <div class="banner">
   Turn this document into a (PowerPoint/KeyNote-style) slide show pressing F11.
   (Free <a href="https://addons.mozilla.org/en-US/firefox/addon/4650">FullerScreen</a> Firefox addon required).
  </div>
  $do_slides[=[
   <div class='slide'>
    <h1>$heading</h1>
    $content
   </div>
  ]=]
 </body>
</html>
]]
]========]
