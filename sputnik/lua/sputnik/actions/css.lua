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
   require"colors"
   require"saci.sandbox"
   local data, e = saci.sandbox.new{
                      string = string,
                      table  = table,
                      colors = colors,
                      ipairs = ipairs,
                      unpack = unpack,
                      config = page.config,
                   }:do_lua(page.content)
   if e then 
      return error(e)
   else
      return cosmo.fill(data.CSS, data), "text/css"
   end

end

-- vim:ts=3 ss=3 sw=3 expandtab
