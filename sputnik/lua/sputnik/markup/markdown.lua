module(..., package.seeall)

require("markdown")
require("sputnik.util")
local split = sputnik.util.split
local WIKI_LINK = [[<a $link>$title</a>]]

function wikify_link(wikilink, sputnik)
   -- [[Page_Name.edit#A1|Edit the Page]]
   local title, page_name
   sputnik.logger:debug(wikilink)
   wikilink, title   = split(wikilink, "|")
   wikilink, anchor  = split(wikilink, "#")
   page_name, action = split(wikilink, "%.")
   sputnik.logger:debug(wikilink)
   sputnik.logger:debug(page_name)
   sputnik.logger:debug(anchor)
   sputnik.logger:debug(action)
   sputnik.logger:debug("-----------")
   local exists = true --helpers.storage:page_exists(page_name)

   return cosmo.f(WIKI_LINK){  
             title = title or page_name, 
             link = sputnik:make_link(page_name, action, {}, anchor),
             
          }
end

function new(sputnik) 
   return {
      transform = function(text)
                     local function dolink(wikilink)
			               return wikify_link(wikilink, sputnik)
			            end
                     return markdown(string.gsub(text, "%[%[([^%]]*)%]%]", dolink))
                  end
   }
end

