module(..., package.seeall)

local util = require("sputnik.util")
local wiki = require("sputnik.actions.wiki").actions
require("saci")
require("lfs")
require("diff")

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

.luarocks_kudos {
  border: 1px solid green;
  background: white;
  margin: .3em;
  padding: .3em;
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
  <th width="10%">Stacks</th>
  <th width="60%">Description</th>
 </tr>
$do_rocks[=[
 <tr>
  <td class="luarocks_package_name">$package</td>
  <td>$kudos$stacks</td>
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
   $kudos_text

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
         rockspec.package = rockspec.package:lower()
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
      rock.stacks = ""
      table.insert(rocks, rock)
      rock_hash[rock_id] = rock
   end

   local dependencies = {}

   for i, rock in pairs(rocks) do
      for j, dep in ipairs(rock.dependencies or {}) do
         dep = dep:match("%S*")
         dependencies[dep] = dependencies[dep] or {}
         table.insert(dependencies[dep], rock.package) 
      end
   end


   local function list_to_stars(l, star)
      local buffer = ""
      l = l or {}
      star = star or "★"   
      for _, __ in ipairs(l or {}) do
         buffer=buffer..star
      end
      return buffer
   end

   for package, dependent in pairs(dependencies) do
      local more = {}
      --print(package, dependent, #dependent)
      if rock_hash[package] then
         for i, id in ipairs(dependent) do
            --for k,v in pairs(id) do print(k) end
            rock_hash[package].stacks = rock_hash[package].stacks..list_to_stars(dependencies[id], "п")
         end
         rock_hash[package].stacks = rock_hash[package].stacks..list_to_stars(dependent, "п") 
      end
   end

   local kudos = {}
   for _, kudo in ipairs(diff.split("\n"..node.content, "\n%#%s*", true)) do
      print(kudo)
      local what, who, kudo = kudo:match("^(%S*) / (%S*)\n(.*)")
      print(what, who)
      if what and who and kudo then
         kudos[what] = kudos[what] or {}
         table.insert(kudos[what], {kudo, who})
         print("----------")
      end
   end

   for _, rock in ipairs(rocks) do
      local rock_kudos = kudos[rock.package]
      rock.kudos = list_to_stars(rock_kudos)
      local buffer=""
      for __, kudo in ipairs(rock_kudos or {}) do
         buffer = buffer.."<div class='luarocks_kudos'><b>"..kudo[2]..":</b><br/>"..kudo[1].."</div>"
      end
      rock.kudos_text = buffer
   end

   table.sort(rocks, function(x,y) return x.package < y.package end)

   node.inner_html = cosmo.f(TEMPLATE){
                        do_rocks = rocks,
                     }

   return node.wrappers.default(node, request, sputnik)
end
