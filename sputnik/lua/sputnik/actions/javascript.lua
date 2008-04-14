module(..., package.seeall)

actions = {}

actions.js = function(page, params, sputnik)
   return page.content, "text/javascript"
end
