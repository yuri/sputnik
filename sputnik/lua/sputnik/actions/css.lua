module(..., package.seeall)

local yui_reset = require("sputnik.util.yui_reset")

--print(yui_reset.css)

actions = {}

actions.css = function(page, params, sputnik)
   -- Run the css content through cosmo in order to allow for relative URLS
   local content = cosmo.f(page.content){
      make_url = function(arg)
         return sputnik:make_url(arg.node, arg.action)
      end,
   }
   return content, "text/css"
end

actions.fancy_css = function(page, params, sputnik)
   require"colors"
   require"saci.sandbox"
   local data, e = saci.sandbox.new{
                      reset_code = yui_reset.css,
                      icon_base_url    = sputnik.config.ICON_BASE_URL or sputnik.config.NICE_URL,
                      string = string,
                      table  = table,
                      MAIN_COLOR = sputnik.config.MAIN_COLOR,
                      BODY_BG_COLOR = sputnik.config.BODY_BG_COLOR,
                      colors = colors,
                      ipairs = ipairs,
                      unpack = unpack,
                      config = page.config,
                   }:do_lua(page.css_config)
   if e then 
      error(e.err)
   else
      return cosmo.fill(page.content, data), "text/css"
   end

end

-- vim:ts=3 ss=3 sw=3 expandtab
