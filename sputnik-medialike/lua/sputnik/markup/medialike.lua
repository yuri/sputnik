module(..., package.seeall)

require("medialike")
local markdown = require("sputnik.markup.markdown")

function new(sputnik)
   return {
      transform = function(text)
                     local function wikilink_fn(wikilink)
                        return markdown.wikify_link(wikilink, sputnik)
                     end
                     return medialike.format_content(text, wikilink_fn)
      end
   }
end
