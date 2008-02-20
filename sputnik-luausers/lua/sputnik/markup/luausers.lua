module(..., package.seeall)

require("medialike")
medialike.heading_tags={ "h4", "h3", "h2", "h4", "h5" }

local markdown = require("sputnik.markup.markdown")


--   l = l.replace("        ", "\t")
--   l = l.replace("\t\t\t", "***").replace("\t\t*", "\t**").replace("\t*", "*").replace("\t", "        ")



function new(sputnik)
   return {
      transform = function(text)
                     local function dolink(wikilink)
                        return markdown.wikify_link(wikilink, sputnik)
                     end
                     local function do_code(match)
                        return string.gsub("\n"..match, "\n", "\n  ")
                     end
                     local function do_indented_code(match)
                        return string.gsub("\n"..match, "\n", "\n      ")
                     end
                     local function dolist(match)
                        match = string.gsub(match, "                        %*", "***")
                        match = string.gsub(match, "                %*", "**")
                        match = string.gsub(match, "        %*", "*")
                        return match
                     end
                     text = string.gsub(text, "\r\n", "\n")
                     text = string.gsub(text, "\t", "        ")
                     text = string.gsub(text, "\n        {{{(.-)}}}", do_indented_code)
                     text = string.gsub(text, "{{{(.-)}}}", do_code)
                     text = string.gsub(text, "{{(.-)}}", function(x) return "<code>"..x.."<code>" end)
                     text = string.gsub(text, "(        %*.-\n\n)", dolist)  --"(\t|(        ))\*.*?\n\n", dolist)
                     return medialike.format_content(text, dolink)
      end
   }
end
