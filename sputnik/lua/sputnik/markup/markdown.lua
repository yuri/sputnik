module(..., package.seeall)

require("markdown")
require("xssfilter")

local split = require("sputnik.util").split
local WIKI_LINK = [[<a $link>$title</a>]]

function wikify_link(wikilink, sputnik)
   -- [[Page_Name.edit#A1|Edit the Page]]
   local title, page_name
   sputnik.logger:debug(wikilink)
   wikilink, title   = split(wikilink, "|")
   wikilink, anchor  = split(wikilink, "#")
   page_name, action = split(wikilink, "%.")

   return cosmo.f(WIKI_LINK){  
             title = string.gsub(title or page_name, "_", "\_"),
             link = sputnik:make_link(page_name, action, {}, anchor),
             
          }
end

function new(sputnik) 
   return {
      transform = function(text)
                     local function dolink(wikilink)
                        return wikify_link(wikilink, sputnik)
                     end
                     local buffer = ""
                     for line in string.gmatch("\n"..text, "(\n[^\n]*)") do
                        if line:len() < 5 or line:sub(1,5)~="\n    " then
                           buffer = buffer..string.gsub(line, "%[%[([^%]]*)%]%]", dolink)
                        else
                           buffer = buffer..line
                        end
                     end
                     local xss_filter = xssfilter.new()
                     xss_filter.generic_attributes.style = "."
                     local html, message = xss_filter:filter(markdown(buffer))
                     if html then
                        return html
                     elseif message then
                        return "<pre>"..message.."</pre>"
                     end
                  end
   }
end

