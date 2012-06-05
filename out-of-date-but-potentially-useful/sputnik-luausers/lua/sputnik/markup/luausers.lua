module(..., package.seeall)

require("medialike")
medialike.heading_tags={ "h4", "h3", "h2", "h4", "h5" }

local markdown = require("sputnik.markup.markdown")


--   l = l.replace("        ", "\t")
--   l = l.replace("\t\t\t", "***").replace("\t\t*", "\t**").replace("\t*", "*").replace("\t", "        ")

function do_code(match)
   return string.gsub("\n"..match, "\n", "\n  ")
end

local function do_indented_code(match)
   return string.gsub("\n"..match, "\n", "\n          ")
end

local function dolist(match)
   match = string.gsub(match, "                        %*", "***")
   match = string.gsub(match, "                %*", "**")
   match = string.gsub(match, "        %*", "*")
   return match
end

CODE_PLACEHOLDER          = "JKDKIEJHSYKLSDNMSKJDLJWQYUISAKNMGHWELKDSMLNSQIYOPNKLAKAWEIOOUKHJAJKHGQWBVBN"
CODE_PLACEHOLDER_INDENTED = "BNMKJHLKLKWPEIRUIOAHJKLSADVBNVAMLKJQEWHJHGRJKWJGHGKAJHGDBCVCVDDSOIGDHGVCDED"
CODE_PLACEHOLDER_INLINE   = "UIYFDJLJFDSCNLIOHRXGBNMNMHEQDHIKUTGGDHHUJJJNFCFRDDHBGFGEFJHJFEIKFNUESWXHMKI"
function new(sputnik)
   return {
      transform = function(text)
                     local function dolink(wikilink)
                        return markdown.wikify_link(wikilink, sputnik)
                     end

                     -- normalize by getting rid of \r and \t
                     text = string.gsub(text, "\r\n", "\n").."\n\n"
                     text = string.gsub(text, "\t", "        ")
                     text = string.gsub(text, "<", "&lt;")
                     text = string.gsub(text, ">", "&gt;")

                     -- stash code sections
                     local code = {}
                     local function store_code(match)
                        code[#code+1] = string.gsub("\n"..match, "\n", "\n  ")
                        return "\n\n"..CODE_PLACEHOLDER.."\n"
                     end
                     local function store_indented_code(match)
                        code[#code+1] = string.gsub("\n"..match, "\n", "\n          ")
                        return "\n\n"..CODE_PLACEHOLDER_INDENTED.."\n"
                     end
                     local function store_inline_code(match)
                        code[#code+1] = "<code>"..match.."</code>"
                        return CODE_PLACEHOLDER_INLINE
                     end
                     local code_position = 0
                     local function next_code_segment()
                        code_position = code_position+1
                        return code[code_position]
                     end
                     text = string.gsub(text, "\n        %s*{{{(.-)}}}", store_indented_code)
                     text = string.gsub(text, "{{{(.-)}}}", store_code)
                     text = string.gsub(text, "{{(.-)}}", store_inline_code)  --function(x) return "<code>"..x.."<code>" end)


                     -- Do lists and links
                     text = string.gsub(text, "([A-Z][a-z]%w*[A-Z][a-z]%w*)", function(x) return "[["..x.."]]" end)
                     text = string.gsub(text, "(        %*.-\n\n)", dolist)  --"(\t|(        ))\*.*?\n\n", dolist)

                     -- Put the code back
                     text = string.gsub(text, CODE_PLACEHOLDER_INDENTED, next_code_segment)
                     text = string.gsub(text, CODE_PLACEHOLDER, next_code_segment)
                     text = string.gsub(text, CODE_PLACEHOLDER_INLINE, next_code_segment)
                     return medialike.format_content(text, dolink)
      end
   }
end
