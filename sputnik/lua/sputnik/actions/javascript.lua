module(..., package.seeall)

actions = {}

actions.js = function(page, params, sputnik)
   return page.content, "text/javascript"
end

actions.configured_js = function(page, params, sputnik)
   return cosmo.fill(page.content, sputnik.config), "text/javascript"
end

