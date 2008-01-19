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
     <a href="http://www.freewisdom.org/projects/sputnik/Demo_Album.photo&id=$id" 
class='local'> 
        <img style="position: absolute; left: $left; top: $top;" 
             width="$width"
             height="$height"
             src="$thumb_base/$thumb_dir/$image.$suffix"
             title="$title"/>
     </a>
   ]]
  
   <img height='$height' style='border:none' 
        src='http://www.freewisdom.org/etc/blank.gif'/>
  </div>
 </center>
</div>

$after
]====]

SINGLE_PHOTO = [[
  <img src="$url"/>
]]

]=========]
