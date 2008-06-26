module(..., package.seeall)

NODE = {
   title="Templates:Mixed Album",
   prototype="@Lua_Config",
}
NODE.content=[=========[
MIXED_ALBUM = [====[

$before

<div width='100%'>
 <center>
  <div style='position:relative;' class='image-links'> 
   $do_photos[[
     <a href="$url" 
class='local'> 
        <img style="position: absolute; left: $left; top: $top;" 
             width="$width"
             height="$height"
             src="$image_base/$thumb_dir/$image.thumb$suffix.jpg"
             title="$title"/>
     </a>
   ]]
  
   <img height='$height' style='border:none' 
        src='http://www.freewisdom.org/etc/blank.gif'/>
  </div>
 </center>
</div>

]====]

SINGLE_PHOTO = [==[
  <img src="$photo_url"/><br/>
  <a $album_link>Back to the album</a>
]==]

]=========]
