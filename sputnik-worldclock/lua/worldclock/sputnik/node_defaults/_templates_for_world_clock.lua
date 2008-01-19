title="Templates for World Clock"
prototype="@Lua_Config"
category="Demo Templates"
content = [=============[WORLD_CLOCK = [==========[
<style>
 table { spacing : 0px 0px 0px 0px}
 table { margins: 50 50 50 50}
 table {font-size: 80% }
 .active {font-size : 180%}
 .more_cities {font-size : 16px}
 td { border : 1px solid orange;}
 .hour00 { background-color: black; color: #ccc}
 .hour01 { background-color: black; color: #ccc}
 .hour02 { background-color: black; color: #ccc}
 .hour03 { background-color: black; color: #ccc}
 .hour04 { background-color: black; color: #ccc}
 .hour05 { background-color: #666; color: black}
 .hour06 { background-color: #f99; color: black}
 .hour07 { background-color: #fdd; color: black}
 .hour08 { background-color: #fdd; color: black}
 .hour09 { background-color: white; color: black}
 .hour10 { background-color: white; color: black}
 .hour11 { background-color: white; color: black}
 .hour12 { background-color: yellow; color: black}
 .hour13 { background-color: yellow; color: black}
 .hour14 { background-color: white; color: black}
 .hour15 { background-color: white; color: black}
 .hour16 { background-color: white; color: black}
 .hour17 { background-color: white; color: black}
 .hour18 { background-color: #ddd; color: black}
 .hour19 { background-color: #ddd; color: black}
 .hour20 { background-color: #ddd; color: black}
 .hour21 { background-color: #999; color: yellow}
 .hour22 { background-color: #999; color: yellow}
 .hour23 { background-color: black; color: white}
 </style>
 <div id="worldclock">
 <table>
  $do_hour[===[
      $if_city[[
          <tr class="hour$hh">
           <td class="active">$city</td>
           <td align="right" class="active">$hh:$mm:$ss</td>
          </tr>
	 ]]
      $if_no_city[[
          <tr>
           <td class="hour$hh" colspan="2">&nbsp;</td>
          </tr>
	 ]]
  ]===]
 </table>
 </div>
]==========]



TIMED_UPDATE = [======[
     <div id="world_clock">Wait a second</div>
     <script>
      function ahah(url,target) {
         //document.getElementById(target).innerHTML = 'loading data...';
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

      updateTime();
     </script>

   ]======]]=============]

