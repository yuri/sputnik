module(..., package.seeall)

require("cosmo")

actions = {}

actions.show_content = function(node, params, sputnik)
   local city_by_tz = {}
   for i, city in ipairs(node.content.cities) do
      city_by_tz[city[2]] = city
   end

   return cosmo.f(node.templates.WORLD_CLOCK){
             do_hour = function() for i=1,24 do
                          local slot = i + node.content.start
                          local t = os.date("*t", os.time() + 3600*(slot-node.content.local_tz))
                          local city = city_by_tz[slot]
                          local city_name
                          if city then city_name = city[1] end
                          cosmo.yield {
                             hh        = string.format("%02d", t.hour),
                             mm        = string.format("%02d", t.min),
                             ss        = string.format("%02d", t.sec),
                             city      = city_name,
                             _template = city and 1 or 2
                          }
                       end end,
          }
end

actions.full_html = function(node, params, sputnik)
   node.inner_html = cosmo.f(node.templates.TIMED_UPDATE){
                        url = node.urls:show_content(),
                        timeout = node.content.timeout * 1000 
                     }
   return node.wrappers.default(node, params, sputnik)
end

