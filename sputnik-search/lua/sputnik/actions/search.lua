module(..., package.seeall)

actions = {}

actions.show_results = function(node, request, sputnik)
   if sputnik.config.SEARCH_API_KEY then
       node.inner_html = cosmo.f(node.content.TEMPLATE){
                            api_key = sputnik.config.SEARCH_API_KEY,
                            site    = sputnik.config.DOMAIN, --..sputnik.config.NICE_URL,
                            query   = request.params.q
                         }
   else 
       node.inner_html = [[ 
          Please set <code>SEARCH_API_KEY</code> in sputnik.config to <b>your</b> 
          <a href="http://code.google.com/apis/ajaxsearch/signup.html">Google API key</a>.
       ]]
   end
   return node.wrappers.default(node, request, sputnik)
end
