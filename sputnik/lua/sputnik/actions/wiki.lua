module(..., package.seeall)

require("cosmo")
local util = require("sputnik.util")
local html_forms = require("sputnik.util.html_forms")
local date_selector = require("sputnik.util.date_selector")

---------------------------------------------------------------------------------------------------
-- Creates the HTML for the navigation bar.
--
--  @param node          A node table.
--  @param sputnik       The Sputnik object.
--  @return              An HTML string.
---------------------------------------------------------------------------------------------------
function get_nav_bar (node, sputnik)
   assert(node)
   local nav = sputnik:get_node(sputnik.config.DEFAULT_NAVIGATION_BAR).content.NAVIGATION
   local cur_node = sputnik:dirify(node.name)          

   for i, section in ipairs(nav) do
      section.title = section.title or section.id
      section.id = sputnik:dirify(section.id)
      if section.id == cur_node or section.id == node.category then
         section.is_active = true
         nav.current_section = section
      end
      for j, subsection in ipairs(section) do
         subsection.title = subsection.title or subsection.id
         subsection.id = sputnik:dirify(subsection.id)
         if subsection.id == cur_node or subsection.id == node.category then
            section.is_active = true
            nav.current_section = section
            subsection.is_active = true
         end
      end
   end

   local do_subsections = function(section)
              for i, subsection in ipairs(section or {}) do
                 cosmo.yield {
                    class = util.choose(subsection.is_active, "front", "back"),
                    link = sputnik:make_link(subsection.id),
                    label = subsection.title
                 }
              end
   end

   return cosmo.f(node.templates.NAV_BAR){  
            do_sections = function() 
               for i, section in ipairs(nav) do               
                  cosmo.yield { 
                     class = util.choose(section.is_active, "front", "back"),
                     id    = section.id,
                     link  = sputnik:make_link(section.id),  
                     label = section.title,
                     do_subsections = function() return do_subsections(section) end
                  }
               end
            end,
            do_subsections = function() return do_subsections(nav.current_section) end
         }
end

---------------------------------------------------------------------------------------------------
--     Actions
---------------------------------------------------------------------------------------------------
actions = {}

---------------------------------------------------------------------------------------------------
--     first the POST actions - those are a bit trickier
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
-- All "post" requests are routed through the same action ("post"). The reason for this is that we 
-- localize button labels, and their values are not predictable for this reason. Instead, we _name_ 
-- of the button to infer the action. So, to request node.save via post, we actually request
-- node.post&action_save=foo, where foo could be anything.
--
--  @param request       We'll look for request.params.action_* to figure out what we should be 
--                       actually doing.
--  @return              HTML (whatever is returned by the action that it dispatches to).
---------------------------------------------------------------------------------------------------
function actions.post(node, request, sputnik)
   for k,v in pairs(request.params) do
      local action = string.match(k, "^action_(.*)$")
      if action then
         function err_msg(err_code)
            request.try_again = "true"
            node:post_error(node.translator.translate_key(err_code))
         end
         sputnik.logger:debug(action)
         sputnik.logger:debug(request.params.post_token)
         sputnik.logger:debug(request.params.post_timestamp)
         if not request.params.post_token then
            err_msg"MISSING_POST_TOKEN"
         elseif not request.params.post_timestamp then
            err_msg"MISSING_POST_TIME_STAMP"
         elseif (os.time() - tonumber(request.params.post_timestamp)) > (3 * 60) then
            err_msg"YOUR_POST_TOKEN_HAS_EXPIRED"
         elseif sputnik.auth:timestamp_token(request.params.post_timestamp)
                 ~=request.params.post_token then
            err_msg"YOUR_POST_TOKEN_IS_INVALID"
         elseif not request.user then
            if request.auth_message then
               err_msg(request.auth_message)
            else 
               err_msg"YOU_MUST_BE_LOGGED_IN"
            end
         elseif not node:check_permissions(request.user, action) then
            err_msg"ACTION_NOT_ALLOWED"
         end

         -- TODO: Add a human readable error message here
         return node.actions[action](node, request, sputnik)
      end
   end 
end

---------------------------------------------------------------------------------------------------
-- Saves the node submitted as a set of cgi params, then returns its HTML representation.
--
--  @param request       request.params fields are used to update the node.
--  @param sputnik       The sputnik table is used to save and reload the node.  
---------------------------------------------------------------------------------------------------
function actions.save(node, request, sputnik)
   for k,v in pairs(request.params) do
      sputnik.logger:debug("~~ "..k)
   end
   if request.try_again then
      return node.actions.edit(node, request, sputnik)
   else
      local new_node = sputnik:update_node_with_params(node, request.params)
      new_node = sputnik:activate_node(new_node)
      new_node:save(request.user, request.params.summary or "", {minor=request.params.minor})
      new_node:redirect(sputnik:make_url(node.name))
      -- Redirect to the node
      return new_node.wrappers.default(new_node, request, sputnik)
   end
end

---------------------------------------------------------------------------------------------------
-- Same as "show_content" but updates the node with values in parameters before displaying it 
-- (would be used by both AHAH preview and server-side preview).  Note that this action is, 
-- strictly speaking, idempotent and can be called via GET.  However, it's simpler to put it
-- together with save.
--
--  @param request       request.params fields are used to update the node.
--  @param sputnik       The sputnik table is used to reload the node.
---------------------------------------------------------------------------------------------------
function actions.preview_content(node, request, sputnik)
   local new_node = sputnik:update_node_with_params(node, request.params)
   sputnik:activate_node(new_node)
   return new_node.actions.show_content(new_node, request, sputnik)
end

---------------------------------------------------------------------------------------------------
-- Returns HTML showing a preview of the node (based on request.params) and also a form to continue 
-- editing the node (the node is _not_ saved).
--
-- @param request       request.params fields are used to update the node.
-- @param sputnik       The sputnik table is used to save and reload the node.  
---------------------------------------------------------------------------------------------------
function actions.preview(node, request, sputnik)
   request.preview = actions.preview_content(node, request, sputnik)
   return actions.edit(node, request, sputnik)
end

---------------------------------------------------------------------------------------------------
--     now the GET actions - those should all be idempotent
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
-- Returns just the content of the node, without the navigation bar, the tool bars, etc.
--  
-- @param request       (Not used - all relevant parameters are already in the node)
-- @param sputnik       Used to wikify the node.
---------------------------------------------------------------------------------------------------
function actions.show_content(node, request, sputnik)
   return node.markup.transform(node.content or "")
end

---------------------------------------------------------------------------------------------------
-- Returns the complete HTML for the node.
--
-- @param request       (Not used - all relevant parameters are already in the node)
-- @param sputnik       
---------------------------------------------------------------------------------------------------
function actions.show(node, request, sputnik)
   request.is_indexable = true
   node.inner_html = node.actions.show_content(node, request, sputnik)
   return node.wrappers.default(node, request, sputnik)
end

---------------------------------------------------------------------------------------------------
-- Returns history of changes for _all_ nodes, by setting a request.show_complete_history and then 
-- forwarding to actions.history.
---------------------------------------------------------------------------------------------------
function actions.complete_history(node, request, sputnik)
   request.show_complete_history = 1
   return node.actions.history(node, request, sputnik)  
end

---------------------------------------------------------------------------------------------------
-- Returns the history of changes by users who created their accounts only recently.
---------------------------------------------------------------------------------------------------
function actions.edits_by_recent_users(node, request, sputnik)
   request.params.recent_users_only = 1
   return actions.complete_history(node, request, sputnik)  
end

---------------------------------------------------------------------------------------------------
-- Return HTML representing history of this node.
--
-- @param request       request.params.date is an optional filter.
---------------------------------------------------------------------------------------------------
function actions.history(node, request, sputnik)
   local history = sputnik:get_history(node.name, 200, request.params.date)
   node.inner_html = cosmo.f(node.templates.HISTORY){
      date_selector = date_selector.make_date_selector{
                         template = node.templates.DATE_SELECTOR,
                         current_date = request.params.date,
                         datelink = function(date)
                            return node.links:history{date=date}
                         end
                      },
      do_revisions  = function()
                           for i, edit in ipairs(history) do
                              if (not request.params.recent_users_only) or sputnik.auth:user_is_recent(edit.author) then
                                 cosmo.yield{
                                    version_link = node.links:show{ version = edit.version },
                                    version      = edit.version,
                                    timestamp    = edit.timestamp,
                                    if_minor     = cosmo.c((edit.minor or ""):len() > 0){},
                                    title        = node.name,
                                    author_link  = sputnik:make_link((edit.author or "Anon")),
                                    author       = edit.author,
                                    if_summary   = cosmo.c(edit.comment:len() > 0){ summary = edit.comment },
                                 }
                              end
                           end
                        end, 
      version       = node.version,
      node_name     = node.name,
      base_url      = sputnik.config.BASE_URL,
   }
   return node.wrappers.default(node, request, sputnik)
end

---------------------------------------------------------------------------------------------------
-- Return HTML representing history of edits to the whole wiki.
--
-- @param request       request.params.date is an optional filter.
---------------------------------------------------------------------------------------------------
function actions.complete_history(node, request, sputnik)
   local edits = sputnik:get_complete_history(limit, request.params.date)

   -- figure out which revisions are stale so that we could group them with the later ones
   local latest = {}
   local later
   for i, e in ipairs(edits) do
      if later then 
         later.previous = e.version
      end
      later = e
      if latest.id ~= e.id then
         latest = e
         latest.repeats = 0
         --n.title_style = ""
      else
         latest.repeats = latest.repeats + 1
         e.repeats = 0
         e.stale = true -- this is the field we'll be checking later
      end
   end
   
   node.inner_html = cosmo.f(node.templates.COMPLETE_HISTORY){
      date_selector = date_selector.make_date_selector{
                         current_date = request.params.date,
                         datelink = function(date)
                            return sputnik:pseudo_node(sputnik.config.HISTORY_node).links:show{date=date}
                         end
                      },
      do_revisions  = function()
                         for i, edit in ipairs(edits) do
                            if (not request.params.recent_users_only) or sputnik.auth:user_is_recent(edit.author) then
                               local is_minor = (edit.minor or ""):len() > 0
                               cosmo.yield{
                                    version_link = edit.node.links:show{ version = edit.version },
                                    diff_link    = edit.node.links:diff{ version=edit.version, other=edit.previous },
                                    history_link = edit.node.links:history(),
                                    latest_link  = edit.node.links:show(),
                                    version      = edit.version,
                                    if_minor     = cosmo.c(is_minor){},
                                    title        = edit.node.id,
                                    author_link  = sputnik:make_link((edit.author or "Anon")),
                                    author       = edit.author,
                                    if_summary   = cosmo.c(edit.comment and edit.comment:len() > 0){
                                                      summary = edit.comment
                                                   },
                                    if_stale     = cosmo.c(edit.stale){},
                                    row_span     = edit.repeats + 1,
                               }
                            end
                         end
                      end, 
      version       = node.version,
      base_url      = sputnik.config.BASE_URL,
      node_name     = node.name,
   }
   return node.wrappers.default(node, request, sputnik)
end


---------------------------------------------------------------------------------------------------
--     Now all the actions that return XML
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
-- Returns RSS of recent changes to this node or all nodes.
---------------------------------------------------------------------------------------------------
function actions.rss(node, request, sputnik)
   local title, history
   if request.show_complete_history then
      title = "Recent Wiki Edits" --::LOCALIZE::
      edits = sputnik:get_complete_history(50)
   else
      title = "Recent Edits to '" .. node.title .."'"  --::LOCALIZE::--
      edits = sputnik:get_history(node.name, 50)
   end
   sputnik.logger:debug("recent_users_only="..(request.params.recent_users_only or "nil")) 
   return cosmo.f(node.templates.RSS){  
      title   = title,
      baseurl = sputnik.config.BASE_URL, 
      items   = function()
                   for i, edit in ipairs(edits) do
                      edit.node = edit.node or node
                      if (not request.params.recent_users_only) or sputnik.auth:user_is_recent(edit.author) then
                         sputnik.logger:debug("recent_users_only="..(request.params.recent_users_only or "nil")) 
                         sputnik.logger:debug("user recent?"..tostring(sputnik.auth:user_is_recent(node.author)))
                         cosmo.yield{
                            link        = "http://" .. sputnik.config.DOMAIN ..
                                          sputnik:escape_url(
                                             edit.node.urls:show{version=node.version}
                                          ),
                            title       = string.format("%s: %s by %s",
                                                        edit.version,
                                                        edit.id or "",
                                                        edit.author or ""),
                            ispermalink = "false",
                            guid        = (edit.id or node.name).. "/" .. edit.version,
                            summary     = edit.comment
                         }
                      end
                   end
                end,
   }, "application/rss+xml"
end

---------------------------------------------------------------------------------------------------
-- Returns RSS for the whole site.
---------------------------------------------------------------------------------------------------
function actions.complete_history_rss(node, request, sputnik)
   request.show_complete_history = 1
   return actions.rss(node, request, sputnik)  
end

---------------------------------------------------------------------------------------------------
-- Returns RSS for edits done by recently registered users.
---------------------------------------------------------------------------------------------------
function actions.rss_for_edits_by_recent_users(node, request, sputnik)
   request.show_complete_history = 1
   request.params.recent_users_only = 1
   return actions.rss(node, request, sputnik)  
end

---------------------------------------------------------------------------------------------------
-- Returns a list of nodes.
---------------------------------------------------------------------------------------------------
function actions.list_nodes(node, request, sputnik)
   local node_names = sputnik:get_node_names()
   table.sort(node_names)
   local function yield_node(name) 
      cosmo.yield{name=name, url=sputnik.config.NICE_URL..name}
   end
   local special_prefix = "^[_@]"
   node.inner_html = cosmo.f(node.templates.LIST_OF_ALL_PAGES){
                        do_regular_nodes = function()
                                              for i, name in ipairs(node_names) do
                                                 if not string.match(name, special_prefix) then
                                                    yield_node(name)
                                                 end
                                              end
                                           end,   
                        do_special_nodes = function()
                                              for i, name in ipairs(node_names) do
                                                 if string.match(name, special_prefix) then
                                                    yield_node(name)
                                                 end
                                              end
                                           end,
                     }
   return node.wrappers.default(node, request, sputnik)
end

---------------------------------------------------------------------------------------------------
-- Returns an XML sitemap for this wiki.
---------------------------------------------------------------------------------------------------
function actions.show_sitemap_xml(node, request, sputnik)
   local node_names = sputnik:get_node_names()
   return cosmo.f(node.templates.SITEMAP_XML){
      do_urls = function()
          for i, name in ipairs(node_names) do
             if string.match(name, "^[%a%d]") then
                local priority, url
                
                if name == sputnik.config.HOME_PAGE then
                   url = sputnik.config.HOME_PAGE_URL
                   priority = ".9"
                else
                   url = sputnik.config.NICE_URL..name
                   priority = ".1"
                end
                cosmo.yield{
                   url = "http://"..sputnik.config.DOMAIN..url,
                   lastmod = sputnik:get_node(name).metadata.timestamp.."T"..sputnik.config.SERVER_TZ,
                   changefreq = "weekly",
                   priority = priority
                }
             end
          end
      end,   
   }, "text/xml"
end

---------------------------------------------------------------------------------------------------
--     Now the few remaining things
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
-- Shows HTML for the standard Edit field.
---------------------------------------------------------------------------------------------------
function actions.edit (node, request, sputnik, etc)
   etc = etc or {} -- additional parameters
   -- check if the user is even allowed to edit
   local admin = sputnik.auth:get_metadata(request.user, "IsAdmin")
   if (not node:check_permissions(request.user, request.action)) 
       or (node._id==sputnik.config.ROOT_PROTOTYPE and admin == "true") then
      local message = etc.message_if_not_allowed
      if request.action == "edit" then
         message = message or "NOT_ALLOWED_TO_EDIT"
      else
         message = message or "ACTION_NOT_ALLOWED"
      end
      node:post_error(node.translator.translate_key(message))
      node.inner_html = ""
      return node.wrappers.default(node, request, sputnik)
   end

   -- select the parameters that should be copied
   local fields = {}
   for field, field_params in pairs(node.fields) do
      if not field_params.virtual then
         fields[field] = sputnik:escape(request.params[field] or node.raw_values[field])
      end
   end
   fields.page_name = sputnik:dirify(node.name)  -- node name cannot be changed
   fields.user= request.params.user or ""
   fields.password=""
   fields.minor=nil
   fields.summary= request.params.summary or ""

   login_spec = [[
         please_login = {5.0, "note"}
         user         = {5.1, "text_field"}
         password     = {5.2, "password"}      
   ]]

   if request.user then
      login_spec = ""
   end 
   
   local honeypots = "" 
   math.randomseed(os.time())
   for i=0, (sputnik.config.NUM_HONEYPOTS_IN_FORMS or 0) do
      local field_name = "honey"..tostring(i)
      honeypots = honeypots.."\n"..cosmo.f([[$name          = {$order, "honeypot"}]]){
                                order = string.gsub (tostring(math.random()*5), ",", "."),
                                name  = field_name,
                             }
      fields[field_name] = ""
   end

   local post_timestamp = os.time()
   local post_token = sputnik.auth:timestamp_token(post_timestamp)
   
   local edit_ui_field = etc.edit_ui_field
   local admin = sputnik.auth:get_metadata(request.user, "IsAdmin")
   if admin == "true" then
      edit_ui_field = edit_ui_field or "admin_edit_ui"
   else
      edit_ui_field = edit_ui_field or "edit_ui"
   end 

   sputnik.logger:debug(node[edit_ui_field]..login_spec..honeypots)
   local html_for_fields, field_list = html_forms.make_html_form{
                                          field_spec = node[edit_ui_field]..login_spec..honeypots, 
                                          templates  = node.templates, 
                                          translator = node.translator,
                                          values     = fields,
                                          hash_fn    = function(field_name)
                                                          return sputnik:hash_field_name(field_name, post_token)
                                                       end
                                       }
   
   node.inner_html = cosmo.f(node.templates.EDIT){
                        if_preview      = cosmo.c(request.preview){
                                             preview = request.preview,
                                             summary = fields.summary
                                          },
                        html_for_fields = html_for_fields,
                        node_name       = node.name,
                        post_fields     = table.concat(field_list,","),
                        post_token      = post_token,
                        post_timestamp  = post_timestamp,
                        action_url      = sputnik.config.BASE_URL,
                     }
   return node.wrappers.default(node, request, sputnik)
end

---------------------------------------------------------------------------------------------------
-- Shows HTML of diff between two versions of the node.
---------------------------------------------------------------------------------------------------
function actions.diff(node, request, sputnik)
   local other_node = sputnik:get_node(node.id, request.params.other)

   local diff = ""
   for field, tokens in pairs(node:diff(other_node)) do
      diff = diff.."\n\n<h2>"..field.."</h2>\n\n"
      local diff_buffer = ""
      for i, token in ipairs(tokens) do
         token[1] = sputnik:escape(token[1])
         if token[2] == "in" then
            diff_buffer = diff_buffer.."<ins>"..token[1].."</ins>"
         elseif token[2] == "out" then
            diff_buffer = diff_buffer.."<del>"..token[1].."</del>"
         else 
            diff_buffer = diff_buffer..token[1]
         end
      end
      diff = diff.."<pre><code>"..diff_buffer.."</code></pre>\n"
   end
   node.inner_html  = cosmo.f(node.templates.DIFF){  
                         version1 = request.params.version,
                         link1    = node.links:show{version=request.params.version},
                         author1  = node.metadata.author,
                         version2 = request.params.other,
                         link2    = node.links:show{version=request.params.other},
                         author2  = other_node.metadata.author,
                         diff     = diff, 
                      }
   return node.wrappers.default(node, request, sputnik)
end

---------------------------------------------------------------------------------------------------
-- Shows the raw content of the node with content-type set to text/plain (note that unlike 
-- actions.raw, this method only returns the _content_ of the node, not its metadata).
---------------------------------------------------------------------------------------------------
function actions.raw_content(node, request, sputnik)
   if node:check_permissions(request.user, request.action) then
      return node.raw_values.content, "text/plain"
   else
      return "-- Access to raw content not allowed", "text/plain"
   end
end

---------------------------------------------------------------------------------------------------
-- Shows the underlying string representation of the node as plain text.
---------------------------------------------------------------------------------------------------
function actions.raw(node, request, sputnik)
   if node:check_permissions(request.user, request.action) then
      return node.data or "No source available.", "text/plain"
   else
      return "-- Access to raw content not allowed", "text/plain"
   end
end

---------------------------------------------------------------------------------------------------
-- Shows the _content_ of the node shown as 'code'.
---------------------------------------------------------------------------------------------------
function actions.show_content_as_code(node, request, sputnik)
   local escaped = sputnik:escape(node.content) 
   return "<pre><code>"..escaped.."</code></pre>"
end


---------------------------------------------------------------------------------------------------
-- Shows the complete page with it's content shown as 'code'.
---------------------------------------------------------------------------------------------------
function actions.code(node, request, sputnik)
   node.inner_html = actions.show_content_as_code(node, request, sputnik)
   return node.wrappers.default(node, request, sputnik)
end

---------------------------------------------------------------------------------------------------
-- Shows the content of the node as Lua code, checking whether it parses.
---------------------------------------------------------------------------------------------------
function actions.show_content_as_lua_code(node, request, sputnik)

   local DOLLAR_REPLACEMENT = "$<span></span>"
   local escaped = sputnik:escape(node.raw_values.content)
   escaped = escaped:gsub("%$", DOLLAR_REPLACEMENT)
   escaped = escaped:gsub(" ", "&nbsp;")
   escaped = string.gsub(escaped, "(%-%-[^\n]*)", 
                         function (comment) return "<font color='gray'>"..comment.."</font>" end)
   local f, errors = loadstring(node.raw_values.content)
   if errors then
      local reg_exp = "^.+%]%:(%d+)%:"
      error_line_num = string.match(errors, reg_exp)
      errors = string.gsub(errors, reg_exp, "On line %1:")
   end

   return cosmo.f(node.templates.LUA_CODE){
             do_lines  = function()
                            local i = 0
                            for line in ("\n"..escaped):gmatch"\n([^\n]*)" do
                               i = i+1
                               local class = "ok"
                               if i == tonumber(error_line_num) then
                                  class = "bad"
                               end
                               cosmo.yield{
                                  i = i, 
                                  line = line,
                                  class=class
                               }
                            end
                         end,
             if_ok     = cosmo.c(f~=nil){},
             if_errors = cosmo.c(errors~=nil){errors=errors},
          }
end

---------------------------------------------------------------------------------------------------
-- Shows the HTML for an error message when a non-existent action is requested.
---------------------------------------------------------------------------------------------------
function actions.action_not_found(node, request, sputnik)
   node.inner_html = cosmo.f(node.templates.ACTION_NOT_FOUND){
                        title             = node.title,
                        url               = node.urls:show(),
                        action            = request.action,
                        if_custom_actions = cosmo.c(node.raw_values.actions and node.raw_values.actions:len() > 0){
                                               actions = node.raw_values.actions
                                            }
                     }
   return node.wrappers.default(node, request, sputnik)
end


---------------------------------------------------------------------------------------------------
-- Shows the list of registered users
---------------------------------------------------------------------------------------------------
function actions.show_users(node, request, sputnik)

   local TEMPLATE = [[
   <table><thead><td>username</td><td>registration time</td></thead>
   $do_users[=[<tr><td><a $link>$username</a></td><td>$formatted_time</td></tr>
   ]=]
   </table>
   ]]

   local users = {}
   for username, record in pairs(node.content.USERS) do
      table.insert(users, {username=username, link=sputnik:make_link(username), time=record.time, formatted_time=os.date("%c", record.time)})
   end
   table.sort(users, function(x,y) return x.time > y.time end)

   node.inner_html = cosmo.f(TEMPLATE) {do_users = users}
   return node.wrappers.default(node, request, sputnik)
end

---------------------------------------------------------------------------------------------------
-- Shows login form.
---------------------------------------------------------------------------------------------------
function actions.show_login_form(node, request, sputnik)
   if (request.params.user and request.user) then -- we've just logged in the user
      return node.actions.show(node, request, sputnik)
   end
   local post_timestamp = os.time()
   local post_token = sputnik.auth:timestamp_token(post_timestamp)   
   local html_for_fields, field_list = html_forms.make_html_form{
                                          field_spec = [[
                                                           please_login = {4.0, "note"}
                                                           user = {4.1, "text_field"}
                                                           password = {4.2, "password"}      
                                                       ]], 
                                          templates  = node.templates, 
                                          translator = node.translator,
                                          values     = {user="", password=""},
                                          hash_fn    = function(field_name)
                                                          return sputnik:hash_field_name(field_name, post_token)
                                                       end
                                       }
   
   node.inner_html = cosmo.f(node.templates.LOGIN_FORM){
                        html_for_fields = html_for_fields,
                        node_name       = node.name,
                        post_fields     = "user,password",
                        post_token      = post_token,
                        post_timestamp  = post_timestamp,
                        action_url      = sputnik.config.BASE_URL,
                     }
   return node.wrappers.default(node, request, sputnik)
end


---------------------------------------------------------------------------------------------------
-- Shows the version of sputnik.
---------------------------------------------------------------------------------------------------
function actions.sputnik_version(node, request, sputnik)
   node.inner_html = sputnik.config.VERSION or "&lt;no version information&gt;"
   return node.wrappers.default(node, request, sputnik)
end

---------------------------------------------------------------------------------------------------
-- Shows the HTML for an error message when a non-existent action is requested.
---------------------------------------------------------------------------------------------------

wrappers = {}

---------------------------------------------------------------------------------------------------
-- Wraps the HTML content in bells and whistles such as the navigation bar, the header, the footer,
-- etc.
---------------------------------------------------------------------------------------------------
function wrappers.default(node, request, sputnik) 

   local is_old = request.params.version and node:is_old()

   return cosmo.f(node.templates.MAIN){  
      site_title       = sputnik.config.SITE_TITLE or "",
      title            = node.title,
      do_stylesheets   = function()
                            for i, url in ipairs(sputnik.config.STYLESHEETS) do
                               cosmo.yield {url=url}
                            end
                         end,
      nav_bar          = get_nav_bar(node, sputnik),
      if_no_index      = cosmo.c((not request.is_indexable) or is_old){},
      if_old_version   = cosmo.c(is_old){
                            version      = request.params.version,
                         },
      if_logged_in     = cosmo.c(request.user){
                            user         = request.user,
                            logout_link  = node.links:show{logout="1"} 
                         },
      if_not_logged_in = cosmo.c(not request.user){
                            login_link   = node.links:login{next_action=request.params.action},
                         },
      if_search        = cosmo.c(sputnik.config.SEARCH_PAGE){
                            base_url    = sputnik.config.BASE_URL,
                            search_page = sputnik.config.SEARCH_PAGE,
                            search_box_content = sputnik.config.SEARCH_CONTENT or "", 
                         },
      content          = node.inner_html,
      sidebar          = "",
      
      -- Include messages that may have been added to the page
      do_messages      = function()
                            for i,message in ipairs(node.messages) do
                               cosmo.yield(message)
                            end
                         end,
 
      -- "links" include "href="
      show_link        = node.links:show(),
      edit_link        = node.links:edit{version = request.params.version},
      history_link     = node.links:history(),
      site_rss_link    = sputnik:pseudo_node(sputnik.config.HISTORY_PAGE).links:rss(),
      node_rss_link    = node.links:rss(),
      -- urls are just urls
      base_url         = sputnik.config.BASE_URL, -- for mods
      nice_url         = sputnik.config.NICE_URL, -- for mods
      logo_url         = sputnik.config.IMAGES.logo,
      favicon_url      = sputnik.config.IMAGES.favicon,
      rss_medium_url   = sputnik.config.IMAGES.rss_medium,
      rss_small_url    = sputnik.config.IMAGES.rss_small,
      home_page_url    = sputnik.config.HOME_PAGE_URL,
      sputnik_link     = "href='http://sputnik.freewisdom.org/'"
   }, "text/html"
end

-- vim:ts=3 ss=3 sw=3 expandtab
