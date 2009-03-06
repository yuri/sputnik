
module(..., package.seeall)

local sorttable = require"sputnik.javascript.sorttable"
local wiki = require("sputnik.actions.wiki")
local util = require("sputnik.util")

actions = {}

local function format_list(nodes, template, sputnik, node)
   return util.f(template){
            new_url = sputnik:make_url(node.id.."/new", "edit"),
            id      = node.id,
            content = node.content,
            do_nodes = function()
                          for i, node in ipairs(nodes) do
                             local t = {
                                url = sputnik.config.NICE_URL..node.id,
                                id  = node.id,
                                short_id = node.id:match("[^%/]*$"),
                                nice_url = sputnik.config.NICE_URL,
                             }
                             for k, v in pairs(node.fields) do
                                 t[k] = tostring(node[k])
                             end
                             cosmo.yield (t)
                          end
            end,
         }
end

function actions.list_children(node, request, sputnik)
   node:add_javascript_snippet(sorttable.script)
   local nodes = wiki.get_visible_nodes(sputnik, request.user, node.id.."/")
   local non_proto_nodes = {}
   for i, n in ipairs(nodes) do
      if n.id ~= node.id.."/@Child" then
         table.insert(non_proto_nodes, n)
      end
   end
   node.inner_html = format_list(non_proto_nodes, node.html_content, sputnik, node)
   return node.wrappers.default(node, request, sputnik)
end

function actions.list_children_as_xml(node, request, sputnik)
   local nodes = wiki.get_visible_nodes(sputnik, request.user, node.id.."/")
   return format_list(nodes, node.xml_template, sputnik, node), "text/xml"
end

local PARENT_PATTERN = "(.+)%/[^%/]+$" -- everything up to the last slash

actions.edit_new_child = function(node, request, sputnik)
   local child_node = sputnik:get_node(node.id.."/__new")
   sputnik:update_node_with_params(child_node,
                                   { prototype = node.id.."/@Child",
                                     permissions ="allow(all_users, 'new_child')",
                                     title = "A new item",
                                     actions = 'save="collections.save_new"'
                                   })
   sputnik:activate_node(child_node)
   sputnik:decorate_node(child_node)
   return wiki.actions.edit(child_node, request, sputnik)
end

actions.save_new = function(node, request, sputnik)
   local parent_id = node.id:match(PARENT_PATTERN)
   local parent = sputnik:get_node(parent_id)
   local new_id = string.format("%s/%06d", parent_id, sputnik:get_uid(parent_id))
   local new_node = sputnik:get_node(new_id)
   sputnik:update_node_with_params(new_node, {prototype = parent.id.."/@Child"})
   request.params.actions = ""
   new_node = sputnik:activate_node(new_node)
   new_node.inner_html = "Created a new item: <a "..sputnik:make_link(new_id)..">"
                         ..new_id.."</a><br/>"
                         .."List <a "..sputnik:make_link(parent_id)..">items</a>"
   return wiki.actions.save(new_node, request, sputnik)
end

function actions.rss(node, request, sputnik)
   local title = "Recent Additions to '" .. node.title .."'"  --::LOCALIZE::--
   local edits = sputnik:get_history(node.name, 50)

   local items = wiki.get_visible_nodes(sputnik, request.user, node.id.."/")
   table.sort(items, function(x,y) return x.id > y.id end )

   return cosmo.f(node.templates.RSS){  
      title   = title,
      baseurl = sputnik.config.BASE_URL, 
      items   = function()
                   for i, item in ipairs(items) do
					   local node_info = sputnik.saci:get_node_info(item.id)
                       cosmo.yield{
                          link        = "http://" .. sputnik.config.DOMAIN ..
                          sputnik:escape_url(sputnik:make_url(item.id)),
                          title       = item.title,
                          ispermalink = "false",
                          guid        = item.id,
                          author      = node_info.author,
                          pub_date    = sputnik:format_time_RFC822(node_info.timestamp),
                          summary     = item.content,
                       }
                   end
                end,
   }, "application/rss+xml"
end

