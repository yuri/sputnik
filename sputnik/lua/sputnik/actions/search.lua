module(..., package.seeall)

actions = {}

local wiki = require"sputnik.actions.wiki"
local util = require"sputnik.util"
local sorttable = require"sputnik.javascript.sorttable"

TEMPLATE = [[
<table class="sortable" width="100%">
     <thead>
      <tr>
       <th>Node ID</th>
       <th>Backlinks</th>
       <th>Modification Time</th>
      </tr>
     </thead>
     $do_nodes[=[
      <tr>
       <td width="200px"><a title="$title" href="$url">$name</a></td>
       <td width="20px">$backlinks</td>
       <td width="50px">$time</td>
      </tr>
     ]=]
</table>

]]

actions.show_results = function(node, request, sputnik)
   local query = {}
   for term in (request.params.q or ""):lower():gmatch("%w+") do
      query[term] = {}
   end
   node.title = 'Search for "'..request.params.q..'"'
   local backlinks = {}
   for i, node in ipairs(wiki.get_visible_nodes(sputnik, nil)) do
      if node.content and type(node.content)=="string" then
         for word in node.content:lower():gmatch("%w+") do
            if query[word] then
               query[word][node.id] = node
            end
         end
         for id in node.content:gmatch("%[%[([^%]]*)%]%]") do
            backlinks[id] = (backlinks[id] or 0) + 1
         end
      end
   end
   local nodes = {}
   for term, matches in pairs(query) do
      for id, node in pairs(matches) do
         nodes[id] = node
      end
   end
   local ordered_nodes = {}
   for id, node in pairs(nodes) do
      for term, _ in pairs(query) do
         if not query[term][node.id] then
            nodes[id] = nil
         end 
      end
      if nodes[id] then
         table.insert(ordered_nodes, node)
      end
   end
   nodes = ordered_nodes
   table.sort(nodes, function(x,y) return x.id < y.id end)
   node:add_javascript_snippet(sorttable.script)
   node.inner_html = util.f(TEMPLATE){
                        do_nodes = function()
                                      for i, node in ipairs(nodes) do
                                         local metadata = sputnik.saci:get_node_info(node.id)
                                         cosmo.yield {
                                            name = node.id,
                                            title = node.title,
                                            url = sputnik.config.NICE_URL..node.id,
                                            backlinks = backlinks[node.id] or 0,
                                            time = sputnik:format_time(metadata.timestamp, "%Y/%m/%d")
                                         }
                                      end
                        end,
                     }
   return node.wrappers.default(node, request, sputnik)
end
