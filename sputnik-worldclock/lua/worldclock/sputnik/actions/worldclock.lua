module(..., package.seeall)

require("cosmo")

actions = {}

actions.show_content = function(page, params, sputnik)
   local data = sputnik:load_config_page(page.name)
   city_by_tz = {}
   for i, city in ipairs(data.cities) do
      city_by_tz[city[2]] = city
   end

   return cosmo.fill(page.templates.WORLD_CLOCK, {
      do_hour = function()
	 for i=1,24 do
	    local slot = i + data.start
	    local t = os.date("*t", os.time() + 3600*(slot-data.local_tz))
	    local city = city_by_tz[slot]
	    local city_name
	    if city then city_name = city[1] end
	    local tab = {
	       hh       = string.format("%02d", t.hour),
	       mm       = string.format("%02d", t.min),
	       ss       = string.format("%02d", t.sec),
	       city     = city_name}
	    cosmo.yield { 
	       if_city = cosmo.cond(city, tab),
	       if_no_city = cosmo.cond(not city, tab)
	    }				    
	 end
      end,
   })
end

actions.full_html = function(page, params, sputnik)
   local data = sputnik:load_config_page(page.name)
   page.inner_html = cosmo.fill (page.templates.TIMED_UPDATE, {
				    url = page.urls:show_content(),
				    timeout = data.timeout * 1000 })
   return page.wrappers.default(page, params, sputnik)
end

