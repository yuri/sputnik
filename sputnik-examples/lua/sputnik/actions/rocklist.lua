module(..., package.seeall)

local util = require("sputnik.util")
local wiki = require("sputnik.actions.wiki").actions
require("saci")
require("lfs")
require("diff")

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

function list_to_stars(l, star)
   local star_buffer = ""
   l = l or {}
   star = star or "★"   
   for _, __ in ipairs(l or {}) do
      star_buffer=star_buffer..star
   end
   return star_buffer
end

function flatten(rock, field, subfields)
   for i, k in ipairs(subfields) do
      rock[field.."_"..k] = rock[field][k] or "Unknown"
   end
end

function by_version(x,y)
   return x.version < y.version
end

actions = {}

actions.show_list_of_rocks = function(node, request, sputnik)

   node:add_javascript_snippet(SCRIPTS)

   local rock_hash = {}
   local rocks = {} 
   for file in lfs.dir(node.path_to_rockspecs) do
      if file:sub(file:len()-string.len("rockspec")+1) == "rockspec" then
         local rockspec_text = io.open(node.path_to_rockspecs.."/"..file):read("*all")
         local rockspec = saci.sandbox:new():do_lua(rockspec_text)
         rockspec.package = rockspec.package:lower()
         rock_hash[rockspec.package] = rock_hash[rockspec.package] or {}
         table.insert(rock_hash[rockspec.package], rockspec)
      end
   end

   for rock_id, rockspecs in pairs(rock_hash) do
      table.sort(rockspecs, by_version)
      local rock = {}
      for field, value in pairs(rockspecs[1]) do
         rock[field] = value
      end

      flatten(rock, "description", {"summary", "detailed", "homepage", "maintainer", "license"})
      flatten(rock, "source", {"url", "md5"})
   
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

   for package, dependent in pairs(dependencies) do
      local more = {}
      if rock_hash[package] then
         for i, id in ipairs(dependent) do
            --for k,v in pairs(id) do print(k) end
            rock_hash[package].stacks = rock_hash[package].stacks..list_to_stars(dependencies[id], "|")
         end
         rock_hash[package].stacks = rock_hash[package].stacks..list_to_stars(dependent, "|") 
      end
   end

   local kudos = {}
   for _, kudo in ipairs(diff.split("\n"..node.content, "\n%#%s*", true)) do
      local what, who, kudo = kudo:match("^(%S*) / (%S*)\n(.*)")
      if what and who and kudo then
         kudos[what] = kudos[what] or {}
         table.insert(kudos[what], {kudo, who})
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

   node.inner_html = cosmo.f(node.html_content){
                        do_rocks = rocks,
                     }

   return node.wrappers.default(node, request, sputnik)
end
