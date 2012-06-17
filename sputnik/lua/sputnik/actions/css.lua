module(..., package.seeall)

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
   require"saci.sandbox"

   local data, e = saci.sandbox.new{
                      icon_base_url = sputnik:make_url_prefix(sputnik.config.ICON_BASE_URL),
                      font_base_url = sputnik:make_url_prefix(sputnik.config.FONT_BASE_URL),
                      string = string,
                      table  = table,
                      ipairs = ipairs,
                      unpack = unpack,
                      config = page.config,
                      more_css = sputnik.config.MORE_CSS or "",
                   }:do_lua(page.css_config)
   if e then 
      error(e.err)
   else
      return cosmo.fill(page.content, data), "text/css"
   end

end

-- vim:ts=3 ss=3 sw=3 expandtab
