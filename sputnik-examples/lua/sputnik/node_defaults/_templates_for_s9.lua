module(..., package.seeall)
NODE = {
   title = "Templates for S9",
   prototype = "@Lua_Config"
}

NODE.permissions = [[
   allow(all_users, "edit")
]]

NODE.content = [========[

SLIDESHOW = [[<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" 
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
 <head>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
  <!-- shamelessly stolen from http://slideshow.rubyforge.org/ -->
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
      .bg_image { display: none}
      h1 { border: 2px solid #003300; background-color: #ddffdd;} 
      h1.first { display: none} 
    }
    @media projection {     
     body {
        height: 100%; margin: 0px; padding: 0px;
        font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
        color: white; background-color: #003300; 
        opacity: .99; 
     }    
    .slide {
      page-break-after: always;
      padding-left: 0px;
      padding-top: 0em;
    }
    .slide_content {
      padding-left: 3em;
      padding-top: 2em;
    }
    .banner {
      display: none;
    }
    .layout {
      display: block;
    }
    div.background {
        position: absolute;
        right: 0px;
        bottom: 0px;
        z-index: -1;
    }
    a:link, a:visited {
        color: white;
    } 
    a:hover { background-color: yellow; }
    h1 { font-size: 47pt; background-color: #ffffff; color: #003300; width: 100%; padding: 10px 0 0 10px; margin: 0}   
    h1.first { display: none} 
    h2 { font-size: 36pt;  }    
    h3 { font-size: 25pt; font-weight: bold; color: yellow; }
    h4 { font-size: 25pt; }
    p, li, td, th { font-size: 20pt; }
    pre { font-size: 18pt; padding-left: 1em; color: #9999ff; }
    pre.code { font-size: 16pt;
        background-color: black;
        color: white;
        padding: 5px;
        border: silver thick groove;
        -moz-border-radius: 11px;
    }
    hr {color: yellow; width: 90%;}
    bg_image { position: absolute; right: 0; width: 300px}
   }  
  </style>
 </head>

 <body>
  <div class="layout"> 
   <div class="background">  
    <!--object data="http://media.freewisdom.org/etc/sputnik-background.svg" width="100%" height="100%"-->
   </div>    
  </div> 
  <div class="banner">
   Turn this document into a (PowerPoint/KeyNote-style) slide show pressing F11.
   (Free <a href="https://addons.mozilla.org/en-US/firefox/addon/4650">FullerScreen</a> Firefox addon required).
  </div>
  $do_slides[=[
   <div class='slide'>
    <h1 class="$heading_class">$heading   <img class="bg_image" src="http://media.freewisdom.org/etc/sputnik-big.png"/></h1>
    <div class='slide_content'>

      $content
    </div>
   </div>
  ]=]
 </body>
</html>
]]
]========]
