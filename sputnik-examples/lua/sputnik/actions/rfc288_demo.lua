module(..., package.seeall)
actions = {}
actions.msg = function(node, request, sputnik)
   node.message_date = sputnik:format_time(
                          sputnik.saci:get_node_info(node.id).timestamp, 
                          "%d %b %y %H:%M:%S +0000 (UTC)", "+00:00")
   return cosmo.f(node.message_template)(node), "text/plain"
end

