module(..., package.seeall)

local util = require("sputnik.util")
local wiki = require("sputnik.actions.wiki").actions
require("saci")
require("lfs")

actions = {}

ROCKSPECS = "/home/yuri/git/sputnik/mainline/tmp/rocks/"

SCRIPTS = [[
$(document).ready(function(){
 $("div.luarocks_details").each(
   function() {
     $(this).hide();
   }
 )
 $(".luarocks_more").click(
   function(){
     $(this).siblings("div").slideToggle();
     return false;
   }
 );
});
]]

TEMPLATE = [[
<style>
.luarocks_package_name {
  font-size: 150%;
}
.luarocks_details {
  border: 1px solid gray;
  background-color: #dd8;
  padding: .5em;
  margin: .5em;
  display: none;
}
</style>
<table border="0">
 <tr>
  <th width="30%">Package</th>
  <th width="70%">Description</th>
 </tr>
$do_rocks[=[
 <tr>
  <td class="luarocks_package_name">$package</td>
  <td>
  $description_summary
  <a href="#" class="luarocks_more">...</a>
  <div class="luarocks_details">
   $description_detailed
   <br/><br/>

   license: $description_license<br/>
   home page: <a href="$description_homepage">$description_homepage</a><br/>
   latest version: $version<br/>
   rock maintainer: $description_maintainer<br/>

  </div>
  
  </td>
 </tr>
]=]
</table>
]]

function flatten(rock, field, subfields)
   for i, k in ipairs(subfields) do
      rock["description_"..k] = rock[field][k] or "Unknown"
   end
end

actions.show_list_of_rocks = function(node, request, sputnik)

   node:add_javascript_snippet(SCRIPTS)

   local buffer = ""

   local rock_hash = {}
   local rocks = {}
 
   for file in lfs.dir(ROCKSPECS) do
      if file:sub(file:len()-string.len("rockspec")+1) == "rockspec" then
         local rockspec_text = io.open(ROCKSPECS.."/"..file):read("*all")
         local rockspec = saci.sandbox:new():do_lua(rockspec_text)
         rock_hash[rockspec.package] = rock_hash[rockspec.package] or {}
         table.insert(rock_hash[rockspec.package], rockspec)
      end
   end

   local by_version = function(x,y) return x.version < y.version end

   for rock_id, rockspecs in pairs(rock_hash) do
      table.sort(rockspecs, by_version)
      local rock = {}
      for field, value in pairs(rockspecs[1]) do
         rock[field] = value
      end

      flatten(rock, "description", {"summary", "detailed", "homepage", "maintainer", "license"})
   
      rock.description_maintainer =  rock.description_maintainer:gsub("@", " at ")
      table.insert(rocks, rock)
   end

   table.sort(rocks, function(x,y) return x.package < y.package end)

   node.inner_html = cosmo.f(TEMPLATE){
                        do_rocks = rocks,
                     }

   return node.wrappers.default(node, request, sputnik)
end
