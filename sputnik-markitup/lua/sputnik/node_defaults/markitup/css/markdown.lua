module(..., package.seeall)

NODE = {
	prototype = "@CSS",
	title = "Markitup style for markdown",
}

local markItUpButtons = {
   "markitup/images/h1",
   "markitup/images/h2",
   "markitup/images/h3",
   "markitup/images/h4",
   "markitup/images/code",
   "markitup/images/bold",
   "markitup/images/italic",
   "markitup/images/list-bullet",
   "markitup/images/list-numeric",
   "icons/sputnik",
   "markitup/images/picture",
   "markitup/images/link",
   "markitup/images/quotes",
   {"markituppreview", "markitup/images/preview"},
}

MARKITUP_BUTTON_CSS = [[.markItUpButton%d a { 
   background-image:url($make_url{node = "%s", action="png"});  
}
]]
MARKITUP_NAMED_BUTTON_CSS = [[.%s a { 
   background-image:url($make_url{node = "%s", action="png"});  
}
]]

local function make_markitup_css(buttons)
   local buf = ""
   for i,v in ipairs(buttons) do
      if type(v) == "table" then
         buf = buf..string.format(MARKITUP_NAMED_BUTTON_CSS, v[1], v[2])
      else
         buf = buf..string.format(MARKITUP_BUTTON_CSS, i, v)
      end
   end
   return buf
end

NODE.content = make_markitup_css(markItUpButtons)



