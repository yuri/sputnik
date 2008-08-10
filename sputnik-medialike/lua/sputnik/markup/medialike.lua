module(..., package.seeall)

require("medialike")
local markdown = require("sputnik.markup.markdown")

function new(sputnik)
   local function wikilink_fn(wikilink)
   
   end
   return {
      transform = function(text)
                     local function wikilink_fn(wikilink)
                        return markdown.wikify_link(wikilink, page, sputnik)
                     end
                     return medialike.format_content(text, wikilink_fn)
      end
   }
end
