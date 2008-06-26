module(..., package.seeall)

actions = {}

actions.show_results = function(page, request, sputnik)
   local search_page = sputnik:get_node(page.name)
   if sputnik.config.SEARCH_API_KEY then
       page.inner_html = cosmo.f(search_page.TEMPLATE){
                            api_key = sputnik.config.SEARCH_API_KEY,
                            site    = sputnik.config.DOMAIN, --..sputnik.config.NICE_URL,
                            query   = request.params.q
                         }
   else 
       page.inner_html = [[ 
          Please set <code>SEARCH_API_KEY</code> in sputnik.config to <b>your</b> 
          <a href="http://code.google.com/apis/ajaxsearch/signup.html">Google API key</a>.
       ]]
   end
   return page.wrappers.default(page, request, sputnik)
end
