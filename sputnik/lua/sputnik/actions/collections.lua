
module(..., package.seeall)

local sorttable = require"sputnik.javascript.sorttable"
local wiki = require("sputnik.actions.wiki")
local util = require("sputnik.util")

actions = {}

local function format_list(nodes, template, sputnik, node, request)
   return util.f(template){
            new_url = sputnik:make_url(node.id.."/new", "edit"),
            id      = node.id,
            content = node.content,
            format_time = function(params)
               return sputnik:format_time(unpack(params))
            end,
            make_link = function(params)
               return sputnik:make_link(unpack(params))
            end,
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

function actions.show(node, request, sputnik)
   local node_hash, node_ids, num_hidden = node:get_visible_children(request.user or "Anonymous")
   local non_proto_nodes = {}
   for i, id in ipairs(node_ids) do
      n = node_hash[id]
      if n.id ~= node.id .. "/@Child" then
         table.insert(non_proto_nodes, n)
      end
   end

   local template = node.translator.translate(node.html_content)

   local values = {
      new_id  = node.id .. "/new",
      new_url = sputnik:make_url(node.id.."/new", "edit"),
      id      = node.id,
      content = node.content,
      markup = function(params)
         return node.markup.transform(params[1], node)
      end,
      format_time = function(params)
         return sputnik:format_time(unpack(params))
      end,
      make_url = function(params)
         local id, action, _, anchor = unpack(params)
         for i=1,#params do
            params[i] = nil
         end
         return sputnik:make_url(id, action, params, anchor)
      end,
      do_nodes = function()
         for i, node in ipairs(non_proto_nodes) do
             sputnik:decorate_node(node)
            local t = {
               url = sputnik.config.NICE_URL..node.id,
               id  = node.id,
               short_id = node.id:match("[^%/]*$"),
               nice_url = sputnik.config.NICE_URL,
               markup = function(params)
                  return node.markup.transform(params[1], node)
               end,
            }
            for k, v in pairs(node.fields) do
               t[k] = tostring(node[k])
            end
            for action_name in pairs(node.actions) do
               if node:check_permissions(request.user, action_name) then
                  sputnik.logger:debug("Action: " .. tostring(action_name))
                  t[action_name .. "_link"] = sputnik:make_url(node.id, action_name)
                  t["if_user_can_" .. action_name] = cosmo.c(true){}
               else
                  t["if_user_can_" .. action_name] = cosmo.c(false){}
               end
            end
            cosmo.yield (t)
         end
      end,
   }

   for k,v in pairs(node.fields) do
      if not values[k] then
         values[k] = tostring(node[k])
      end
   end
   
   for action_name in pairs(node.actions) do
      if node:check_permissions(request.user, action_name) then
         sputnik.logger:debug("Action: " .. tostring(action_name))
         values[action_name .. "_link"] = sputnik:make_url(node.id, action_name)
         values["if_user_can_" .. action_name] = cosmo.c(true){}
      else
         values["if_user_can_" .. action_name] = cosmo.c(false){}
      end
   end

   node.inner_html = cosmo.fill(template, values)
   return node.wrappers.default(node, request, sputnik)
end

function actions.list_children_as_xml(node, request, sputnik)
   local nodes = wiki.get_visible_nodes(sputnik, request.user, node.id.."/")
   return format_list(nodes, node.xml_template, sputnik, node), "text/xml"
end

local PARENT_PATTERN = "(.+)%/[^%/]+$" -- everything up to the last slash

actions.edit_new_child = function(node, request, sputnik)
   local child_node = sputnik:get_node(node.id.."/__new")
   local child_proto = node.id .. "/@Child"
   if parent.child_proto and parent.child_proto:match("%S") then
      child_proto = parent.child_proto
   end
   sputnik:update_node_with_params(child_node,
                                   { prototype = child_proto,
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
   local uid_format = "%06d"
   if parent.child_uid_format and parent.child_uid_format:match("%S") then
      uid_format = parent.child_uid_format
   end
   local uid = string.format(uid_format, sputnik:get_uid(parent_id))
   local new_id = string.format("%s/%s", parent_id, uid)
   local new_node = sputnik:get_node(new_id)
   local child_proto = node.id .. "/@Child"
   if parent.child_proto and parent.child_proto:match("%S") then
      child_proto = parent.child_proto
   end
   sputnik:update_node_with_params(new_node, {prototype = child_proto})
   new_node = sputnik:activate_node(new_node)

   request.params.actions = ""
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

