-----------------------------------------------------------------------------
-- Defines functions for searching Saci data.
--
--
-- (c) 2007, 2008  Yuri Takhteyev (yuri@freewisdom.org)
-- License: MIT/X, see http://sputnik.freewisdom.org/en/License
-----------------------------------------------------------------------------


function rank_hits(hits, node_map)
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

