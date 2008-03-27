module(..., package.seeall)

actions = {}

actions.css = function(page, params, sputnik)
   return page.content, "text/css"
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

