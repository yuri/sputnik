module(..., package.seeall)

require("medialike")
medialike.heading_tags={ "h4", "h3", "h2", "h4", "h5" }

local markdown = require("sputnik.markup.markdown")

function new(sputnik)
   return {
      transform = function(text)
                     local function dolink(wikilink)
                        return markdown.wikify_link(wikilink, sputnik)
                     end
                     local function docode(match)
                        lang, rest = string.match(match, "^%s+lang=([^%>]+)>(.*)")
                        if lang then 
                           match = "====="..lang.."=====\n"..(rest or "") 
                        else
                           match = match:sub(2)
                        end 
                        return string.gsub("\n"..match, "\n", "\n  ")
                     end
                     text = string.gsub(text, "<source(.-)%s*</source>", docode)
                     return medialike.format_content(text, dolink)
      end
   }
end
