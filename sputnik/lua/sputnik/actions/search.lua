module(..., package.seeall)

actions = {}

local wiki = require"sputnik.actions.wiki"
local util = require"sputnik.util"
local sorttable = require"sputnik.javascript.sorttable"

TEMPLATE = [[
$do_nodes[=[
  <p><a title="$title" href="$url">$name</a> - $time</p>
  <p>$snippet</p>
]=]
]]

function rank_hits(node, sputnik)
   local weights = {}   -- weight for each node ID
   local node_ids = {}  -- a list of node ids (to be sorted eventually)
   for id, node in pairs(node_map) do
      for term, hits_for_term in pairs(hits) do
         if hits_for_term[id] then 
            weights[id] = (weights[id] or 0) + 5 + hits_for_term[id]
         end 
      end
      if weights[id] then
         table.insert(node_ids, id)
      end
   end
   table.sort(node_ids, function(x,y) return weights[x] > weights[y] end)
   return node_ids, weights
end

function get_snippets(hits, node_map)
   local snippets = {}
   local snippets_for_node
   for id, node in pairs(node_map) do
      snippets_for_node = {}
      for word in node.content:lower():gmatch("[%w_0-9]+") do
         --print(word, hits[word])
         if hits[word] then
            table.insert(snippets_for_node, word)
         end
      end
      snippets[id] = table.concat(snippets_for_node, " ")
   end
   return snippets
end


actions.show_results = function(node, request, sputnik)
   local nodes = sputnik.saci:query_nodes({"title", "content"},
                                           request.params.q or "")
   local weights = {} --rank_hits(nodes, sputnik)
   --local snippets = get_snippets(hits, node_map)
   node.title = 'Search for "'..(request.params.q or "")..'"'
   node:add_javascript_snippet(sorttable.script)
   node.inner_html = util.f(TEMPLATE){
                        do_nodes = function()
                                      for i, node in ipairs(nodes) do
                                         local metadata = sputnik.saci:get_node_info(node.id)
                                         cosmo.yield {
                                            name = node.id:gsub("_", " "),
                                            title = node.title,
                                            url = sputnik:make_url(node.id),
                                            --backlinks = weights[node.id] or 0,
                                            snippet = "", --snippets[id],
                                            time = sputnik:format_time(metadata.timestamp, "%Y/%m/%d")
                                         }
                                      end
                        end,
                     }
   return node.wrappers.default(node, request, sputnik)
end
