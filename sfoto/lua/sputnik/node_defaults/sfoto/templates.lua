module(..., package.seeall)

NODE = {
   title="SFoto Templates",
   prototype="@Lua_Config",
}
NODE.content=[=========[

ALBUM = [======[

$if_has_hidden[[
  <p><img src="$lock_icon_url"/> This album has $num_hidden hidden photos.</p><br/>
]]

<table>
 $rows[=[
  <tr>
   $photos[==[
    <td style="vertical-align: middle; text-align: center; min-width: 150px; min-height: 150px; border: none;">
     <a href="$album_url/$id" style="min-height: 150px">
      <img src="$thumb"/>
     </a>
    </td>
   ]==]
  </tr>
 ]=]
</table>

]======]

INDEX = [======[
<style>
.odd {
   background: #999999;
   border: none;
}
.even
{
   background: #cccccc;
   border: none;
} 
.date {
   font-size: 300%;
}
.blog {
   display: block;
   font-size: 120%;
   border: 1px solid gray;
   background: white;
   padding: 3px;
   min-height: 94px;
   min-width: 150px;
   text-decoration: none;
}
.blog:hover {
   background: #ffd;
}
</style>

<script type="text/javascript">/* <![CDATA[ */
      function ahah(url,target) {
         document.getElementById(target).innerHTML = 'fetching data...';
         if (window.XMLHttpRequest) {
            req = new XMLHttpRequest();
            req.onreadystatechange = function() {ahahDone(target);};
            req.open("GET", url, true);
            req.send(null);
         } else if (window.ActiveXObject) {
            req = new ActiveXObject("Microsoft.XMLHTTP");
            if (req) {
               req.onreadystatechange = function() {ahahDone(target);};
               req.open("GET", url, true);
               req.send();
            }
         }
      }
 
      function ahahDone(target) {
         // only if req is "loaded"
         if (req.readyState == 4) {
            // only if "OK"
            if (req.status == 200 || req.status == 304) {
               results = req.responseText;
               document.getElementById(target).innerHTML = results;
            } else {
               document.getElementById(target).innerHTML="ahah error:\n" +
               req.statusText;
            }
         }
      } 

      function updateTime() {
         setTimeout( 'ahah( "$url", "world_clock", 1)', 1 );
         setTimeout("updateTime()", $timeout);
      }


      function showBlog(id, url, content_url) {
         document.getElementById("controller_"+id).style.display = "block";
         document.getElementById("expander_"+id).style.display = "block";
         document.getElementById("controller2_"+id).style.display = "block";
         document.getElementById("permalink_"+id).href=url;
         ahah(content_url, "expander_"+id, 1);
         window.scrollBy(0,100);
      }

      function hideBlog(id) {
         document.getElementById("controller_"+id).style.display = "none";
         document.getElementById("expander_"+id).style.display = "none";
         document.getElementById("controller2_"+id).style.display = "none";
      }
/* ]]> */</script>



<table>
 <tr>
 <td colspan="6">
  <a href="$reverse_url" style="text-decoration: none">reverse the order</a>
  | jump to: 
  $months[[ <a href="#month_$id" style="text-decoration: none">$short_name</a>]]
 </tr>
 $do_months[=[ 
  <tr><th colspan="6" class="date" style="background: #333333; color: white;">$month<a name="month_$month_id"></a></th></tr>
  $do_rows[==[
   <tr>
    $dates[===[
     <th class="$odd date">$date</th>
    ]===]
   </tr>
   <tr>
    $items[===[
     <td class="$odd" style="min-width: 150px">
      $if_blog[====[
       <a class="blog" href="$url" onclick="showBlog('$row_id', '$url', '$content_url'); return false;">$title</a>
      ]====]
      $if_album[====[
       <a href="$url" title="$title" onclick="showBlog('$row_id', '$url', '$content_url'); return false;"><img src="$thumbnail"/></a>
       <br/>$title
      ]====]
     </td>
    ]===]
   </tr>
   <tr>
    <th colspan="6" style="background: #333333; color: white;">
     <div id="controller_$row_id" style="display:none;">
      <style>
       table.sfoto_toolbar { border:none; margin: 0; padding: 0; }
       .sfoto_toolbar tr { margin: 0; padding: 0; }
       .sfoto_toolbar tr td { vertical-align: middle; border: none; color: gray; margin: 0; padding: 0; padding-right: .5em;    }
       .sfoto_toolbar tr td a {  color: white; text-decoration: none; }
       .sfoto_toolbar tr td a:hover {  color: yellow; }
      </style>
      <table class="sfoto_toolbar">
       <tr>
        <td><a href="#" onclick="hideBlog('$row_id'); return false;" style="font-size: 200%;">&#10799;</a></td>
        <td>&#124;</td>
        <td><a id="permalink_$row_id">permalink</a></td>
       </tr>
      </table>
     </div>
     <div id="expander_$row_id"
          style="background:white; color: black; display:none; padding: 15px;">
     </div>
     <div id="controller2_$row_id" style="display:none; color: white;">
      <a href="#" onclick="hideBlog('$row_id'); return false;" style="text-decoration:none; color:white; color: yellow;">hide</a>
     </div>
    </th>
   </tr>
  ]==]
]=]
</table>
]======]


MIXED_ALBUM = [====[

<div width='100%'>
 <center>
  <div style='position:relative;' class='image-links'> 
   $do_photos[[
     <a href="$url" class='local'> 
        <img style="position: absolute; left: $left; top: $top;" 
             width="$width"
             height="$height"
             src="$photo_url"
             title="$title"/>
     </a>
   ]]
  
   <img style='border:none; min-height: $height{}px' 
        src='http://www.freewisdom.org/etc/blank.gif'/>
  </div>
 </center>
</div>

]====]

SINGLE_PHOTO = [==[
  <a href="$next_link" title="$note"><img src="$photo_url"/></a>
  <br/>
  <a href="$prev_link" style="text-decoration: none;">&lt;</a>
  <a href="$original_size">original size</a> (large image)
  <a href="$next_link" style="text-decoration: none;">&gt;</a>
]==]

]=========]
