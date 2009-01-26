module(..., package.seeall)

actions = {}

local jquery = require("sputnik.util.jquery")


actions.js = function(page, params, sputnik)
   return page.content, "text/javascript"
end

actions.configured_js = function(page, params, sputnik)
   sputnik.config.jquery = jquery.js
   return cosmo.fill(page.content, sputnik.config), "text/javascript"
end

