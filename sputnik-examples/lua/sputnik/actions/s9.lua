module(..., package.seeall)

actions = {}
actions.slides = function(node, request, sputnik)
   require"markdown"
   local delim = "@@@@@@@@@@"
   local html = ("\n"..node.markup.transform(node.content or "").."<h2>"):gsub("<h2>", "\n"..delim.."\n<h2>").."\n"..delim
   return cosmo.f(node.templates.SLIDESHOW){
      title = node.title,
      do_slides = function()
                     for heading, content in html:gmatch("\n<h2>(.-)</h2>(.-)\n"..delim) do
                        cosmo.yield{heading=heading, content=content}
                     end
                  end
   }
end

