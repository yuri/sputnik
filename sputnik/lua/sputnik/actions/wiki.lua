-----------------------------------------------------------------------------
-- Provides functions for collection of basic actions needed by a Sputnik to
-- serve as a wiki.
--
-- (c) 2007, 2008  Yuri Takhteyev (yuri@freewisdom.org)
--
-- License: MIT/X, see http://sputnik.freewisdom.org/en/License
-----------------------------------------------------------------------------
module(..., package.seeall)

require("cosmo")
require("versium.util")
local format_time = versium.util.format_time
local util = require("sputnik.util")
local html_forms = require("sputnik.util.html_forms")
local date_selector = require("sputnik.util.date_selector")

-----------------------------------------------------------------------------
-- Creates the HTML for the navigation bar.
--
--  @param node          A node table.
--  @param sputnik       The Sputnik object.
--  @return              An HTML string.
-----------------------------------------------------------------------------
function get_nav_bar (node, sputnik)
   assert(node)
   local nav_node = sputnik:get_node(sputnik.config.DEFAULT_NAVIGATION_BAR)
   local nav = nav_node.content.NAVIGATION
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
                      do_subsections = function()
                                          return do_subsections(section)
                                       end
                   }
                end
             end,
             do_subsections = function()
                                 return do_subsections(nav.current_section)
                              end
          }
end


-----------------------------------------------------------------------------
-- Checks the post parameters are OK.
-----------------------------------------------------------------------------

function check_post_parameters(node, request, sputnik)
   local token = request.params.post_token
   local timestamp = request.params.post_timestamp
   local timeout = (sputnik.config.POST_TOKEN_TIMEOUT or 15) * 60
   if not token then
      return false, "MISSING_POST_TOKEN"
   elseif not timestamp then
      return false, "MISSING_POST_TIME_STAMP"
   elseif (os.time()-tonumber(timestamp)) > timeout then 
      return false, "YOUR_POST_TOKEN_HAS_EXPIRED"
   elseif  sputnik.auth:timestamp_token(timestamp) ~= token then 
      return false, "YOUR_POST_TOKEN_IS_INVALID"
   else
      return true
   end
end


--=========================================================================--
--     Actions - this is what this module is all about                     --
--=========================================================================--
actions = {}

--=========================================================================--
-- First the post actions - those are a bit tricker                        --
--=========================================================================--

-----------------------------------------------------------------------------
-- Handles all post actions.  All "post" requests are routed through this
-- action ("post"). The reason for this is that we localize button labels,
-- and their values are not predictable for this reason. Instead, we we look
-- at the _name_ the button to infer the action. So, to request node.save via
-- post, we actually request node.post&action_save=foo, where foo could be
-- anything.
--
-- @param node
-- @param request        We'll look for request.params.action_* to figure out
--                       what we should be actually doing.
-- @return               HTML (whatever is returned by the action that it
--                       dispatches to).
-----------------------------------------------------------------------------
function actions.post(node, request, sputnik)
   for k,v in pairs(request.params) do
      local action = string.match(k, "^action_(.*)$")
      if action then
         function err_msg(err_code, message)
            request.try_again = "true"
            node:post_error(node.translator.translate_key(err_code)..(message or ""))
         end

         -- check the validity of the request
         local ok, err = check_post_parameters(node, request, sputnik)
         if not ok then
            err_msg(err)
         end

         -- test captcha, if configured
         if not request.user and sputnik.captcha then
            local client_ip = request.wsapi_env.REMOTE_ADDR
            local captcha_ok, err = sputnik.captcha:verify(request.POST, client_ip)
            if not captcha_ok then
               err_msg("COULD_NOT_VERIFY_CAPTCHA", err)
            end
         end

         -- check if the user is allowed to do this
         if not node:check_permissions(request.user, action) then
            err_msg("ACTION_NOT_ALLOWED")
         end

         return node.actions[action](node, request, sputnik)
      end
   end 
end

-----------------------------------------------------------------------------
-- Saves/updates the node based on query params, then redirects to the new
-- version of the node.
--
-- @param node
-- @param request        request.params fields are used to update the node.
-- @param sputnik        used to save and reload the node.  
-----------------------------------------------------------------------------
function actions.save(node, request, sputnik)
   if request.try_again then
      return node.actions.edit(node, request, sputnik)
   else
      local new_node = sputnik:update_node_with_params(node, request.params)
      new_node = sputnik:activate_node(new_node)
      local extra = {minor=request.params.minor}
      if not request.user then
         extra.ip=request.wsapi_env.REMOTE_ADDR -- track IPs for anonymous
      end
      new_node:save(request.user, request.params.summary or "", extra)
      new_node:redirect(sputnik:make_url(node.name)) -- Redirect to the node
      return new_node.wrappers.default(new_node, request, sputnik)
   end
end

-----------------------------------------------------------------------------
-- Updates the node with values in query parameters, then calls show_content.
-- This has the effect of showing us what the node would look like if we
-- saved it.  Note that this action is, strictly speaking, idempotent and can
-- be called via GET.  However, it's simpler to do it with post - for
-- symmetry with "save".
--
-- @param node
-- @param request        request.params fields are used to update the node.
-- @param sputnik        used to access update functionality.
-----------------------------------------------------------------------------
function actions.preview_content(node, request, sputnik)
   local new_node = sputnik:update_node_with_params(node, request.params)
   sputnik:activate_node(new_node)
   return new_node.actions.show_content(new_node, request, sputnik)
end

-----------------------------------------------------------------------------
-- Returns HTML showing a preview of the node (based on request.params) and
-- also a form to continue editing the node.  (The node is _not_ saved.)
--
-- @param request        request.params fields are used to update the node.
-- @param sputnik        passed to preview_content().
-----------------------------------------------------------------------------
function actions.preview(node, request, sputnik)
   request.preview = actions.preview_content(node, request, sputnik)
   return actions.edit(node, request, sputnik)
end

-----------------------------------------------------------------------------
-- Handles the clicking of the "cancel" button from the edit form.  This
-- action is idempotent and can be called via GET, but is submitted via POST,
-- for symmetry with "save".
--
-- @param node
-- @param request        not used.
-- @param sputnik        not used.
-----------------------------------------------------------------------------
function actions.cancel(node, request, sputnik)
   node:redirect(node.name) -- redirect to "show"
   return node.wrappers.default(node, request, sputnik)
end


--=========================================================================--
-- Now the GET actions - those should all be idempotent                    --
--=========================================================================--

-----------------------------------------------------------------------------
-- Returns just the content of the node, without the navigation bar, the tool
-- bars, etc.
-- 
-- @param node
-- @param request        not used.
-- @param sputnik        not used.
-----------------------------------------------------------------------------
function actions.show_content(node, request, sputnik)
   return node.markup.transform(node.content or "")
end

-----------------------------------------------------------------------------
-- Returns the complete HTML for the node.
--
-- @param node
-- @param request        passed to show_content.
-- @param sputnik        passed to show_content.
-----------------------------------------------------------------------------
function actions.show(node, request, sputnik)
   request.is_indexable = true
   node.inner_html = node.actions.show_content(node, request, sputnik)
   return node.wrappers.default(node, request, sputnik)
end

-----------------------------------------------------------------------------
-- Returns history of changes for _all_ nodes. 
--
-- @param node
-- @param request        not used.
-- @param sputnik        not used.
-----------------------------------------------------------------------------
function actions.complete_history(node, request, sputnik)
   request.show_complete_history = 1
   -- let the "history" action actually do all the work.
   return node.actions.history(node, request, sputnik)  
end

-----------------------------------------------------------------------------
-- Returns the history of changes by users who created their accounts only
-- recently.
--
-- @param node
-- @param request        passed to complete_history().
-- @param sputnik        passed to complete_history().
-----------------------------------------------------------------------------
function actions.edits_by_recent_users(node, request, sputnik)
   request.params.recent_users_only = 1
   return actions.complete_history(node, request, sputnik)  
end


-----------------------------------------------------------------------------
-- Given an edit table, retursn either the author (if other than ""), or the
-- IP address of the edit (if defined), or "Anonymous."
-----------------------------------------------------------------------------

local function author_or_ip(edit)
   if not edit.author or edit.author == "" then
      return edit.ip or "Anonymous"
   else
      return edit.author
   end
end

-----------------------------------------------------------------------------
-- Returns the history of this node as HTML.
--
-- @param node
-- @param request        request.params.date is an optional filter.
-- @param sputnik        used to access history.
-----------------------------------------------------------------------------
function actions.history(node, request, sputnik)
   local history = sputnik:get_history(node.name, 200, request.params.date)

   -- cosmo iterator for revisions
   local function do_revisions()
      for i, edit in ipairs(history) do
         local author_display = author_or_ip(edit)
         if (not request.params.recent_users_only)
             or sputnik.auth:user_is_recent(edit.author) then
            cosmo.yield{
               version_link = node.links:show{ version = edit.version },
               version      = edit.version,
               date         = format_time(edit.timestamp, "%Y/%m/%d"),
               time         = format_time(edit.timestamp, "%H:%M GMT"),
               if_minor     = cosmo.c((edit.minor or ""):len() > 0){},
               title        = node.name,
               author_link  = sputnik:make_link(author_display),
               author       = author_display,
               if_summary   = cosmo.c(edit.comment:len() > 0){
                                 summary = util.escape(edit.comment)
                              },
            }
         end
      end
   end 

   node.inner_html = cosmo.f(node.templates.HISTORY){
      date_selector = date_selector.make_date_selector{
                         template = node.templates.DATE_SELECTOR,
                         current_date = request.params.date,
                         datelink = function(date)
                            return node.links:history{date=date}
                         end
                      },
      do_revisions  = do_revisions, -- the function defined above
      version       = node.version,
      node_name     = node.name,
      base_url      = sputnik.config.BASE_URL,
   }
   return node.wrappers.default(node, request, sputnik)
end

-----------------------------------------------------------------------------
-- Return HTML representing history of edits to the whole wiki.
--
-- @param request       request.params.date is an optional filter.
-----------------------------------------------------------------------------
function actions.complete_history(node, request, sputnik)
   local edits = sputnik:get_complete_history(limit, request.params.date)

   -- figure out which revisions are stale so that we could group them with
   -- the later ones.
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

   -- the cosmo iterator over revisions
   local function do_revisions()
      for i, edit in ipairs(edits) do
         if (not request.params.recent_users_only)
             or sputnik.auth:user_is_recent(edit.author) then
            local author_display = author_or_ip(edit)
            local is_minor = (edit.minor or ""):len() > 0
            cosmo.yield{
               version_link = edit.node.links:show{ version = edit.version },
               diff_link    = edit.node.links:diff{ version=edit.version, other=edit.previous },
               history_link = edit.node.links:history(),
               latest_link  = edit.node.links:show(),
               version      = edit.version,
               date         = format_time(edit.timestamp, "%Y/%m/%d"),
               time         = format_time(edit.timestamp, "%H:%M GMT"),
               if_minor     = cosmo.c(is_minor){},
               title        = edit.node.id,
               author_link  = sputnik:make_link((author_display or "Anon")),
               author       = author_display,
               if_summary   = cosmo.c(edit.comment and edit.comment:len() > 0){
                                 summary = edit.comment
                              },
               if_stale     = cosmo.c(edit.stale){},
               row_span     = edit.repeats + 1,
            }
         end
      end
   end 

   
   node.inner_html = cosmo.f(node.templates.COMPLETE_HISTORY){
      date_selector = date_selector.make_date_selector{
                         current_date = request.params.date,
                         datelink = function(date)
                            local n = sputnik:pseudo_node(sputnik.config.HISTORY_NODE)
                            return n.links:show{date=date}
                         end
                      },
      do_revisions  = do_revisions, -- function defined above
      version       = node.version,
      base_url      = sputnik.config.BASE_URL,
      node_name     = node.name,
   }
   return node.wrappers.default(node, request, sputnik)
end


--=========================================================================--
--     Now all the actions that return XML                                 --
--=========================================================================--

-----------------------------------------------------------------------------
-- Returns RSS of recent changes to this node or all nodes.
-----------------------------------------------------------------------------
function actions.rss(node, request, sputnik)
   local title, history
   if request.show_complete_history then
      title = "Recent Wiki Edits" --::LOCALIZE::
      edits = sputnik:get_complete_history(50)
   else
      title = "Recent Edits to '" .. node.title .."'"  --::LOCALIZE::--
      edits = sputnik:get_history(node.name, 50)
   end
   return cosmo.f(node.templates.RSS){  
      title   = title,
      baseurl = sputnik.config.BASE_URL, 
      items   = function()
                   for i, edit in ipairs(edits) do
                      edit.node = edit.node or node
                      if (not request.params.recent_users_only)
                          or sputnik.auth:user_is_recent(edit.author) then
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

-----------------------------------------------------------------------------
-- Returns RSS for the whole site.
-----------------------------------------------------------------------------
function actions.complete_history_rss(node, request, sputnik)
   request.show_complete_history = 1
   return actions.rss(node, request, sputnik)  
end

-----------------------------------------------------------------------------
-- Returns RSS for edits done by recently registered users.
-----------------------------------------------------------------------------
function actions.rss_for_edits_by_recent_users(node, request, sputnik)
   request.show_complete_history = 1
   request.params.recent_users_only = 1
   return actions.rss(node, request, sputnik)  
end

-----------------------------------------------------------------------------
-- Returns a list of nodes.
-----------------------------------------------------------------------------
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

-----------------------------------------------------------------------------
-- Returns an XML sitemap for this wiki.
-----------------------------------------------------------------------------
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
                   lastmod = sputnik:get_node_info(name).timestamp.."T"..sputnik.config.SERVER_TZ,
                   changefreq = "weekly",
                   priority = priority
                }
             end
          end
      end,   
   }, "text/xml"
end

--=========================================================================--
--     Now the few remaining things
--=========================================================================--

-----------------------------------------------------------------------------
-- Shows HTML for the standard Edit field.
-----------------------------------------------------------------------------
function actions.edit (node, request, sputnik, etc)
   etc = etc or {} -- additional parameters

   -- check if the user is even allowed to edit
   local admin = sputnik.auth:get_metadata(request.user, "is_admin")
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

   -- Add the scripts and stylesheets
   node:add_stylesheet("/css/markitup/simple.css", "screen")
   node:add_stylesheet("/css/markitup/markdown.css", "screen")
   node:add_javascript("/js/jquery.js")
   node:add_javascript("/js/markitup.js")
   node:add_javascript("/js/markdown.js")
   node:add_javascript(nil, [[
   $(document).ready(function() {
      $(".editor").markItUp(mySettings);
   });]])

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
   local admin = sputnik.auth:get_metadata(request.user, "is_admin")
   if admin == "true" then
      edit_ui_field = edit_ui_field or "admin_edit_ui"
   else
      edit_ui_field = edit_ui_field or "edit_ui"
   end 

   sputnik.logger:debug(node[edit_ui_field]..honeypots)
   local html_for_fields, field_list = html_forms.make_html_form{
                                          field_spec = node[edit_ui_field]..honeypots, 
                                          templates  = node.templates, 
                                          translator = node.translator,
                                          values     = fields,
                                          hash_fn    = function(field_name)
                                                          return sputnik:hash_field_name(field_name, post_token)
                                                       end
                                       }

   local captcha_html = ""
   if not request.user and sputnik.captcha then
      for _, field in ipairs(sputnik.captcha:get_fields()) do
         table.insert(field_list, field)
      end
      captcha_html = node.translator.translate_key("ANONYMOUS_USERS_MUST_ENTER_CAPTCHA")..sputnik.captcha:get_html()
   end

   
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
                        captcha         = captcha_html,
                     }
   return node.wrappers.default(node, request, sputnik)
end

-----------------------------------------------------------------------------
-- Shows HTML of diff between two versions of the node.
-----------------------------------------------------------------------------
function actions.diff(node, request, sputnik)
   local other_node_data = sputnik.saci:get_node(node.id, request.params.other)
   local diff = ""
   for field, tokens in pairs(node:diff(other_node_data)) do
      diff = diff.."<pre><code>"..tokens:to_html().."</code></pre>\n"
   end

   local other_node_info = sputnik.saci:get_node_info(node.id, request.params.other)
   local this_node_info  = sputnik.saci:get_node_info(node.id, request.params.version)
   node.inner_html  = cosmo.f(node.templates.DIFF){  
                         version1 = request.params.version,
                         link1    = node.links:show{version=request.params.version},
                         author1  = author_or_ip(this_node_info.author),
                         time1    = format_time(this_node_info.timestamp, "%H:%M GMT"),
                         date1    = format_time(this_node_info.timestamp, "%Y/%m/%d"),
                         version2 = request.params.other,
                         link2    = node.links:show{version=request.params.other},
                         author2  = author_or_ip(other_node_info.author),
                         time2    = format_time(other_node_info.timestamp, "%H:%M GMT"),
                         date2    = format_time(other_node_info.timestamp, "%Y/%m/%d"),
                         diff     = diff, 
                      }

   request.is_diff = true
   return node.wrappers.default(node, request, sputnik)
end

-----------------------------------------------------------------------------
-- Shows the raw content of the node with content-type set to text/plain (note that unlike 
-- actions.raw, this method only returns the _content_ of the node, not its metadata).
-----------------------------------------------------------------------------
function actions.raw_content(node, request, sputnik)
   if node:check_permissions(request.user, request.action) then
      return node.raw_values.content, "text/plain"
   else
      return "-- Access to raw content not allowed", "text/plain"
   end
end

-----------------------------------------------------------------------------
-- Shows the underlying string representation of the node as plain text.
-----------------------------------------------------------------------------
function actions.raw(node, request, sputnik)
   if node:check_permissions(request.user, request.action) then
      return node.data or "No source available.", "text/plain"
   else
      return "-- Access to raw content not allowed", "text/plain"
   end
end

-----------------------------------------------------------------------------
-- Shows the _content_ of the node shown as 'code'.
-----------------------------------------------------------------------------
function actions.show_content_as_code(node, request, sputnik)
   local escaped = sputnik:escape(node.content) 
   return "<pre><code>"..escaped.."</code></pre>"
end


-----------------------------------------------------------------------------
-- Shows the complete page with it's content shown as 'code'.
-----------------------------------------------------------------------------
function actions.code(node, request, sputnik)
   node.inner_html = actions.show_content_as_code(node, request, sputnik)
   return node.wrappers.default(node, request, sputnik)
end

-----------------------------------------------------------------------------
-- Shows the content of the node as Lua code, checking whether it parses.
-----------------------------------------------------------------------------
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

-----------------------------------------------------------------------------
-- Shows the HTML for an error message when a non-existent action is requested.
-----------------------------------------------------------------------------
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


-----------------------------------------------------------------------------
-- Shows the list of registered users
-----------------------------------------------------------------------------
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

-----------------------------------------------------------------------------
-- Shows login form.
-----------------------------------------------------------------------------
function actions.show_login_form(node, request, sputnik)
   if (request.params.user and request.user) then -- we've just logged in the user
      node:redirect(sputnik:make_url(node.name, prev))
      return node.wrappers.default(node, request, sputnik)
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
                        register_link   = sputnik:make_url("register")
                     }
   return node.wrappers.default(node, request, sputnik)
end


-----------------------------------------------------------------------------
-- Shows the version of sputnik.
-----------------------------------------------------------------------------
function actions.sputnik_version(node, request, sputnik)
   node.inner_html = sputnik.config.VERSION or "&lt;no version information&gt;"
   return node.wrappers.default(node, request, sputnik)
end

-----------------------------------------------------------------------------
-- Shows the HTML for an error message when a non-existent action is requested.
-----------------------------------------------------------------------------

wrappers = {}

-----------------------------------------------------------------------------
-- Wraps the HTML content in bells and whistles such as the navigation bar, the header, the footer,
-- etc.
-----------------------------------------------------------------------------
function wrappers.default(node, request, sputnik) 

   for i, url in ipairs(sputnik.config.STYLESHEETS) do
      node:add_stylesheet(url, "screen")
   end

   local is_old = request.params.version
                  and sputnik.saci:get_node_info(node.id).version ~= request.params.version
                  and not request.is_diff

   return cosmo.f(node.templates.MAIN){  
      site_title       = sputnik.config.SITE_TITLE or "",
      title            = node.title,
      if_no_index      = cosmo.c((not request.is_indexable) or is_old){},
      if_old_version   = cosmo.c(is_old){
                            version      = request.params.version,
                         },
      if_logged_in     = cosmo.c(request.user){
                            user         = request.user,
                            logout_link  = sputnik:make_link(node.name, request.params.action, {logout="1"}) 
                         },
      if_not_logged_in = cosmo.c(not request.user){
                            login_link = sputnik:make_link(node.name, "login", {prev = request.params.action}),
                            register_link = sputnik:make_link("register")
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
 

      -- Navigation bar (two solutions for now, until we figure out how to unify them)
      nav_bar = get_nav_bar(node, sputnik),
      do_navbar = function()
         local nav = sputnik:get_node("_navigation")
         if nav and nav.content and nav.content.NAVIGATION then
            local nav = nav.content.NAVIGATION
            for i=#nav,1,-1 do
               local v = nav[i]
               local active = false;
               if v.patterns then
                  for idx,pattern in ipairs(v.patterns) do
                     if node.name:match(pattern) then
                        active = true
                        break
                     end
                  end
               end
               -- url, title, patterns
               cosmo.yield{
                  class = active and "active" or "inactive",
                  title = v.title,
                  url = v.url,
               }
            end
         end
      end,
      do_stylesheets = function()
         for idx,entry in ipairs(node.stylesheets) do
            if entry.href then
               cosmo.yield{
                  href = entry.href,
                  media = entry.media or "screen",
               }
            end
         end
      end,
      do_stylesheets_src = function()
         for idx,entry in ipairs(node.stylesheets) do
            if entry.src then
               cosmo.yield{
                  src = entry.src,
                  media = entry.media or "screen",
               }
            end
         end
      end,
      do_javascript_link = function()
         for idx,entry in ipairs(node.javascript) do
            if entry.href then
               cosmo.yield{
                  href = entry.href,
               }
            end
         end
      end,
      do_javascript_src = function()
         for idx,entry in ipairs(node.javascript) do
            if entry.src then
               cosmo.yield{
                  src = entry.src,
               }
            end
         end
      end,
      -- "links" include "href="
      show_link        = node.links:show(),
      edit_link        = node.links:edit{version = request.params.version},
      history_link     = node.links:history(),
      site_rss_link    = sputnik:pseudo_node(sputnik.config.HISTORY_PAGE).links:rss(),
      node_rss_link    = node.links:rss(),
      -- urls are just urls
      make_url         = function(args)
         return sputnik:make_url(unpack(args))
      end,
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
