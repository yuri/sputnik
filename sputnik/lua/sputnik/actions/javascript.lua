module(..., package.seeall)

actions = {}

local jquery = require("sputnik.javascript.jquery")
local modernizr = require("sputnik.javascript.jquery")

actions.js = function(page, params, sputnik)
   return page.content, "text/javascript"
end

actions.configured_js = function(page, params, sputnik)
   local config = {}
   setmetatable(config, {__index=sputnik.config})
   config.jquery = jquery.js
   config.modernizr = modernizr.js
   config.more_javascript = sputnik.config.MORE_JAVASCRIPT or ""
   config.LOGIN_NODE = sputnik.config.LOGIN_NODE or "foo"
   config.make_url_without_wrapper = function(arg)
         local node = cosmo.f(arg.node)(config)
         return sputnik:make_url(node, nil, {skip_wrapper="1"}, nil, true)
   end
   return cosmo.fill(page.content, config), "text/javascript"
end


