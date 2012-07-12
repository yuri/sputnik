module(..., package.seeall)


actions = {}

actions.get_auth_token = function(node, request, sputnik)
   return request.auth_token or "", "text/plain"
end
