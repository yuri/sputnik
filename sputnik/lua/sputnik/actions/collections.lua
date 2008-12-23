
module(..., package.seeall)

local wiki = require("sputnik.actions.wiki")
local util = require("sputnik.util")

actions = {}

function actions.list_children(node, request, sputnik)
   local nodes = wiki.get_visible_nodes(sputnik, request.user, node.id.."/")
   node.inner_html = util.f(node.templates.LIST_OF_ALL_PAGES){
                        do_nodes = function()
                                      for i, node in ipairs(nodes) do
                                         cosmo.yield {
                                            name  = node.id,
                                            url = sputnik.config.NICE_URL..node.id
                                         }
                                      end
                        end,
                     }
   return node.wrappers.default(node, request, sputnik)
end
