-----------------------------------------------------------------------------
-- Provides functions for collection of basic actions needed by a Sputnik to
-- serve as a wiki.
--
-- (c) 2007, 2008  Yuri Takhteyev (yuri@freewisdom.org)
--
-- License: MIT/X, see http://sputnik.freewisdom.org/en/License
-----------------------------------------------------------------------------
module(..., package.seeall)

require("coxpcall")
require("cosmo")
require("versium.util")
require("saci.sandbox")

local util = require("sputnik.util")
local html_forms = require("sputnik.util.html_forms")

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

   local function matches(id, patterns)
      patterns = patterns or {}
      for i, pattern in ipairs(patterns) do
         if id:match(pattern) then
            return true
         end
      end
   end

   local function remove_quotes(value)
      return value:gsub("'", ""):gsub('"', ''):gsub("%s+", " ")
   end

   local categories = {}

   for i, section in ipairs(nav) do
      section.title = section.title or section.id
      categories[section.id] = section.title
      section.accessibility_title = remove_quotes(section.title)
      section.id    = sputnik:dirify(section.id)
      section.link  = sputnik:make_link(section.id)
      section.class = "back"
      section.subsections = section
      if section.id == cur_node or section.id == node.category 
         or matches(node.name, section.patterns) then
         section.class = "front"
         section.accessibility_title = section.accessibility_title.." (current section)"
         nav.current_section = section
      end
      for j, subsection in ipairs(section) do
         subsection.title = subsection.title or subsection.id
         categories[subsection.id] = subsection.title
         subsection.accessibility_title = remove_quotes(subsection.title)
         subsection.id = sputnik:dirify(subsection.id)
         subsection.class = "back"
         subsection.link = sputnik:make_link(subsection.id)
         if subsection.id == cur_node or subsection.id == sputnik:dirify(node.category)
            or matches(node.name, subsection.patterns) then
            section.class = "front"
            nav.current_section = section
            subsection.class = "front"
            subsection.accessibility_title = subsection.accessibility_title
                                             .." (current subsection)"
         end
      end
   end

   local default_navsection = sputnik.config.DEFAULT_NAVSECTION
   if not nav.current_section and default_navsection and nav[default_navsection] then
      nav[default_navsection].class = "front"
   end

   return nav, categories
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
         if sputnik.captcha and not (request.user or request.params.user) then
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
      new_node = sputnik:save_node(new_node, request, request.user,
         request.params.summary or "", extra)

      -- redirect to the newly saved node
      request.redirect = sputnik:make_url(new_node.name)
      return
   end
end

-----------------------------------------------------------------------------
-- Forces a re-initialization of Sputnik.
-----------------------------------------------------------------------------
function actions.reload(node, request, sputnik)
   sputnik:init(sputnik.initial_config)
   node.inner_html = "Reloading..."
   request.redirect = sputnik:make_url(node.name)
   return
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
   -- Redirect to the show action
   request.redirect = sputnik:make_url(node.name)
   return
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
   local title = ""
   if request.params.show_title then
      title = "<h1>"..node.title.."</h1>\n\n"
   end
   return title..node.markup.transform(node.content or "", node)
end

REDIRECTION_PROTOCOLS = {
   http = true,
   https = true,
}

function actions.redirect(node, request, sputnik)
   local destination = node.redirect_destination
   local protocol = destination:match("^[^%:]*")
   if REDIRECTION_PROTOCOLS[protocol] or destination:sub(1,1)=="/" then
      request.redirect = destination
   else
      request.redirect = sputnik:make_url(destination)
   end
   return
end

-----------------------------------------------------------------------------
-- Returns the complete HTML for the node.
--
-- @param node
-- @param request        passed to show_content.
-- @param sputnik        passed to show_content.
-----------------------------------------------------------------------------

TMPL = [=[
<p>
 <span class="teaser">
  $note
 </span>
</p>

<br/><br/>

<table style="border: none">
$do_prototypes[[
  <tr>
   <td><a href="$url"><img src="$icon_base_url{}$icon"/></a></td>
   <td><a href="$url">$name</a></li></td>
  </tr>
]]
</table>
]=]


function actions.show(node, request, sputnik)
   if node.redirect_destination and node.redirect_destination~="" then
      return actions.redirect(node, request, sputnik)
   end

   if node.is_a_stub then
      request.is_indexable = false

      --node:post_notice(node.translator.translate_key("PLEASE_PICK_A_TYPE_TO_CREATE_A_NEW_NODE"))

      node.inner_html = cosmo.f(TMPL){
         note = node.translator.translate_key("PLEASE_PICK_A_TYPE_TO_CREATE_A_NEW_NODE"),
         icon_base_url = sputnik.config.ICON_BASE_URL or sputnik.config.NICE_URL,
         do_prototypes = function()
                            local prototypes = sputnik.config.NEW_NODE_PROTOTYPES or {}
                            for i,v in ipairs(prototypes) do
                               cosmo.yield{
                                  name =v.title or v[1],
                                  icon = v.icon,
                                  url  =sputnik:make_url(node.id, "edit", {prototype=v[1]})
                               }
                            end
                         end
      }
   else 
      request.is_indexable = true
      node.inner_html = node.actions.show_content(node, request, sputnik)
   end
   return node.wrappers.default(node, request, sputnik)
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
      if edit.ip then
         return edit.ip, "User at IP "..edit.ip:gsub("%.", "-")
      else
         return "Anonymous", "Anonymous User"
      end
   elseif edit.author:match("@") then
      return edit.author:gsub("@.*", "@..."), edit.author:gsub("@", "_at_")
   else
      return edit.author, edit.author
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
      local old_date = ""
      local new_date = ""
      for i, edit in ipairs(history) do
         new_date = sputnik:format_time(edit.timestamp, "%Y/%m/%d")
         if new_date ~= old_date then
            cosmo.yield {
               if_new_date = cosmo.c(true){
                  date = new_date
               },
               if_edit      = cosmo.c(false){},
            }
         end
         old_date = new_date
         local author_display, author_id_for_link = author_or_ip(edit)
         if (not request.params.recent_users_only)
             or sputnik.auth:user_is_recent(edit.author) then
            cosmo.yield{
               version_link = sputnik:make_link(node.id, nil, {version = edit.version}),
               version      = edit.version,
               date         = sputnik:format_time(edit.timestamp, "%Y/%m/%d"),
               time         = sputnik:format_time(edit.timestamp, "%H:%M %z"),
               if_minor     = cosmo.c((edit.minor or ""):len() > 0){},
               title        = node.name,
               author_link  = sputnik:make_link(author_id_for_link),
               author_icon  = sputnik:get_user_icon(edit.author),
               author       = author_display,
               if_summary   = cosmo.c(edit.comment:len() > 0){
                                 summary = util.escape(edit.comment)
                              },
               if_new_date  = cosmo.c(false){},
               if_edit      = cosmo.c(true){},
            }
         end
      end
   end 

   node.inner_html = cosmo.f(node.templates.HISTORY){
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
   require("md5")
   local edits = sputnik:get_complete_history(sputnik.config.MAX_ITEMS_IN_HISTORY or 200,
                                              request.params.date,
                                              request.params.prefix)

   -- figure out which revisions are stale so that we could group them with
   -- the later ones.
   local latest = {}
   local later
   local function same_date(t1, t2)
      local format = "%Y/%m/%d"
      return sputnik:format_time(t1, format)==sputnik:format_time(t2, format)
   end
   for i, e in ipairs(edits) do
      if later then 
         later.previous = e.version
      end
      later = e
      if not (latest.id == e.id 
              and same_date(latest.timestamp, e.timestamp)) then
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
   local old_date = ""
   local new_date = ""
   local function do_revisions()
      for i, edit in ipairs(edits) do
         new_date = sputnik:format_time(edit.timestamp, "%Y/%m/%d")
         if new_date ~= old_date then
            cosmo.yield {
               if_new_date = cosmo.c(true){
                  date = new_date
               },
               if_edit      = cosmo.c(false){},
            }
         end
         old_date = new_date
         if (not request.params.recent_users_only)
             or sputnik.auth:user_is_recent(edit.author) then
            local author_display, author_ip_for_link = author_or_ip(edit)
            local is_minor = (edit.minor or ""):len() > 0
            cosmo.yield{
               version_link = sputnik:make_link(edit.id, nil, {version = edit.version}),
               diff_link    = sputnik:make_link(edit.id, "diff", {version=edit.version, other=edit.previous}),
               diff_icon    = sputnik:make_url("icons/diff", "png"),
               history_link = sputnik:make_link(edit.id, "history"),
               history_icon = sputnik:make_url("icons/history", "png"),
               latest_link  = sputnik:make_link(edit.id),
               version      = edit.version,
               if_new_date  = cosmo.c(false){},
               if_edit      = cosmo.c(true){},
               time         = sputnik:format_time(edit.timestamp, "%H:%M %z"),
               if_minor     = cosmo.c(is_minor){},
               title        = edit.id,
               author_link  = sputnik:make_link(author_ip_for_link),
               author_icon  = sputnik:get_user_icon(edit.author),
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
      edits = sputnik:get_complete_history(sputnik.config.MAX_ITEMS_IN_HISTORY or 50,
                                            request.params.date,
                                            request.params.prefix)
   else
      title = "Recent Edits to '" .. node.title .."'"  --::LOCALIZE::--
      edits = sputnik:get_history(node.name, 50)
   end

   local channel_url = "http://"..sputnik.config.DOMAIN
   if request.show_complete_history then
      channel_url = channel_url .. sputnik.config.HOME_PAGE_URL
   else
      channel_url = channel_url .. sputnik:make_url(node.id)
   end

   return cosmo.f(node.templates.RSS){  
      title   = title,
      channel_url = channel_url,
      items   = function()
                   for i, edit in ipairs(edits) do
                      local author_display, author_ip_for_link = author_or_ip(edit)
                      edit.node = edit.node or node
                      if (not request.params.recent_users_only)
                          or sputnik.auth:user_is_recent(edit.author) then
                         cosmo.yield{
                            link        = "http://" .. sputnik.config.DOMAIN ..
                                           sputnik:make_url(
                                              edit.id or node.id, 
                                              "show", {version=edit.version}
                                           ),
                            title       = sputnik:escape(string.format("%s: %s by %s",
                                                        edit.version,
                                                        edit.id or "",
                                                        author_display or "")),
                            ispermalink = "false",
                            guid        = (edit.id or node.id).. "/" .. edit.version,
                            pub_date    = sputnik:format_time_RFC822(edit.timestamp),
                            author      = sputnik:escape(author_display),
                            summary     = sputnik:escape(cosmo.f(node.templates.RSS_SUMMARY){
                               if_summary_exists = cosmo.c(edit.comment:match("%S")){
                                  summary = edit.comment
                               },
                               if_no_summary = cosmo.c(not edit.comment:match("%S")){},
                               history_url = "http://" .. sputnik.config.DOMAIN .. 
                                 sputnik:make_url(edit.id, "history", {version = edit.version}),
                               diff_url = "http://" .. sputnik.config.DOMAIN ..  
                                 sputnik:make_url(edit.id, "diff", {version = edit.version}),
                            })
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
-- Returns a list of nodes that the specified user is allowed to see.
-----------------------------------------------------------------------------
function get_visible_nodes(sputnik, user, prefix, options)
   local nodes = {}
   local num_hidden = 0
   for i, node in pairs(sputnik.saci:get_nodes_by_prefix(prefix)) do
      if not options or not options.lazy then
         --sputnik:decorate_node(node)
         local ok, err = copcall(sputnik.activate_node, sputnik, node)
         --sputnik:activate_node(node)
         local ok = true
         if not ok then
            error("Could not load node '"..node.id.."'!\n"..err)
         end
      end
      if node:check_permissions(user, "show") then
         table.insert(nodes, node)
      else
         num_hidden = num_hidden + 1
      end
   end
   table.sort(nodes, function(x,y) return x.id < y.id end)
   return nodes, num_hidden
end

-----------------------------------------------------------------------------
-- Returns a list of nodes.
-----------------------------------------------------------------------------
function actions.list_nodes(node, request, sputnik)
   local nodes = get_visible_nodes(sputnik, request.user)
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

-----------------------------------------------------------------------------
-- Returns an XML sitemap for this wiki.
-----------------------------------------------------------------------------
function actions.show_sitemap_xml(node, request, sputnik)
   local nodes = get_visible_nodes(sputnik, request.user)
   return cosmo.f(node.templates.SITEMAP_XML){
      do_urls = function()
          for i, node in ipairs(nodes) do
             local priority, url
             if node.id == sputnik.config.HOME_PAGE then
                url = sputnik.config.HOME_PAGE_URL
                priority = "0.9"
             else
                url = sputnik.config.NICE_URL..node.id
                priority = "0.1"
             end
             cosmo.yield{
                url = "http://"..sputnik.config.DOMAIN..url,
                lastmod = sputnik:format_time(sputnik.repo:get_node_info(node.id).timestamp, 
                                             "%Y-%m-%dT%H:%M:%S+00:00", "+00:00"),
                changefreq = "weekly",
                priority = priority
             }
          end
      end,   
   }, "text/xml"
end

--=========================================================================--
--     Now the few remaining things
--=========================================================================--

function actions.configure (node, request, sputnik, etc)
   request.admin_edit = true
   return node.actions.edit(node, request, sputnik, etc)
end


-----------------------------------------------------------------------------
-- Shows HTML for the standard Edit field.
-----------------------------------------------------------------------------
function actions.edit (node, request, sputnik, etc)
   request.is_indexable = false

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

   -- Add the editpage stylesheet
   node:add_javascript_link(sputnik:make_url("sputnik/js/editpage.js"))

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
   if request.admin_edit then
      edit_ui_field = edit_ui_field or "admin_edit_ui"
   else
      edit_ui_field = edit_ui_field or "edit_ui"
   end 

   sputnik.logger:debug(node[edit_ui_field]..honeypots)

   -- Pre-compile the field spec
   local cfields, cfield_names = html_forms.compile_field_spec(node[edit_ui_field]..honeypots)
   for i, field in ipairs(cfields) do
      local editor_classes = {}
      if field.editor_modules then
         for j, module in ipairs(field.editor_modules) do
            local editor_module = require("sputnik.editor." .. module)
            editor_module.initialize(node, request, sputnik)
            table.insert(editor_classes, "editor_" .. module)
         end

         local editor_class_txt = table.concat(editor_classes, " ")
         if not field.class or #field.class <= 0 then
            field.class = editor_class_txt
         else
            field.class = field.class .. editor_class_txt
         end
      end
      if cfield_names[i] == "category" then
         if field[2] == "select" then
            local _, category_hash = get_nav_bar(node, sputnik)
            local categories = {{display="       ", value=""}}
            for id, _ in pairs(category_hash) do
               categories[#categories + 1] = {value=id, display=category_hash[id]}
            end
            table.sort(categories, function(x,y) return x.display < y.display end)
            field.options = categories
         end
      end
   end


   local form_params = {
      field_spec = node[edit_ui_field]..honeypots, 
      templates  = node.templates, 
      translator = node.translator,
      values     = fields,
      hash_fn    = function(field_name)
         return sputnik:hash_field_name(field_name, post_token)
      end
   }

   local html_for_fields, field_list = html_forms.make_html_form(form_params, cfields, cfield_names)

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
   request.is_indexable = false
   local this_node_info  = sputnik.saci:get_node_info(node.id, request.params.version)

   if not request.params.other then
      -- No version was specified for the "other" node, so compare with the
      -- immediately previous version
      local history = sputnik:get_history(node.id, 200)
      for idx,edit in ipairs(history) do
         if edit.version == this_node_info.version then
            local prior_edit = history[idx+1]
            request.params.other = prior_edit and prior_edit.version
         end
      end
   end

   local other_node_data, other_node_info, version2_exists
   if request.params.other then
      other_node_data = sputnik.saci:get_node(node.id, request.params.other)
      other_node_info = sputnik.saci:get_node_info(node.id, request.params.other)
      version2_exists = true
   else
      other_node_data = {raw_values = {}}
      other_node_info = {timestamp = 0}
      version2_exists = false
   end

   local diff = ""
   local diff_table = node:diff(other_node_data)
   for i, field in ipairs(node:get_ordered_field_names()) do
      local tokens = diff_table[field]
      if tokens then
         diff = diff.."<h2>"..node.translator.translate_key("EDIT_FORM_"..field:upper()).."</h2>\n"
                    .."<pre><code>"..tokens:to_html().."</code></pre>\n"
      end
   end

   node.inner_html  = cosmo.f(node.templates.DIFF){  
                         version1 = this_node_info.version,
                         link1    = sputnik:make_link(node.id, "show", {version=request.params.version}),
                         author1  = author_or_ip(this_node_info),
                         time1    = sputnik:format_time(this_node_info.timestamp, "%H:%M %z"),
                         date1    = sputnik:format_time(this_node_info.timestamp, "%Y/%m/%d"),
                         if_version2_exists = cosmo.c(version2_exists){},
                         version2 = other_node_info.version,
                         link2    = sputnik:make_link(node.id, "show", {version=request.params.other}),
                         author2  = author_or_ip(other_node_info),
                         time2    = sputnik:format_time(other_node_info.timestamp, "%H:%M %z"),
                         date2    = sputnik:format_time(other_node_info.timestamp, "%Y/%m/%d"),
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
   local escaped = sputnik:escape(node.raw_values.content) 
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
                        url               = sputnik:make_url(node.id),
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
   $do_users[=[<tr><td><a $link>$username</a></td><td>$time</td></tr>
   ]=]
   </table>
   ]]

   local users = {}
   for username, record in pairs(node.content.USERS) do
      table.insert(users, 
                   { username = username, link = sputnik:make_link(username),
                     time     = sputnik:format_time(record.creation_time, 
                                                    "%Y/%m/%d %H:%M %z")
                   })
   end
   table.sort(users, function(x,y) return x.time < y.time end)

   node.inner_html = cosmo.f(TEMPLATE) {do_users = users}
   return node.wrappers.default(node, request, sputnik)
end


function get_login_form(node, request, sputnik)
   local post_timestamp = os.time()
   local post_token = sputnik.auth:timestamp_token(post_timestamp)
   local field_spec = [[
      --please_login = {4.0, "note"}
      user = {4.1, "text_field", div_class="autofocus"}
      password = {4.2, "password"}
   ]]

   if request.params.next then
      field_spec = field_spec .. [[
      next = {4.3, "hidden", no_label = true, div_class="hidden"}
      ]]
   end

   local html_for_fields, field_list = html_forms.make_html_form{
                                          field_spec = field_spec,
                                          templates  = node.templates, 
                                          translator = node.translator,
                                          values     = {
                                             user = "",
                                             password = "",
                                             next = request.params.next,
                                          },
                                          hash_fn    = function(field_name)
                                                          return sputnik:hash_field_name(field_name, post_token)
                                                       end
                                       }

   return cosmo.f(node.templates.LOGIN_FORM){
                        html_for_fields = html_for_fields,
                        node_name       = request.params.next or node.name,
                        post_fields     = "user,password,next",
                        post_token      = post_token,
                        post_timestamp  = post_timestamp,
                        action_url      = sputnik:make_url(sputnik.config.LOGIN_NODE),
                        register_link   = sputnik:make_url(sputnik.config.REGISTRATION_NODE)
                     }


end

-----------------------------------------------------------------------------
-- Shows login form.
-----------------------------------------------------------------------------
function actions.show_login_form(node, request, sputnik)
   request.is_indexable = false
   if (request.params.user and request.user) then -- we've just logged in the user
      request.redirect = sputnik:make_url(node.id)
      return
   end

   node.inner_html = get_login_form(node, request, sputnik)
   return node.wrappers.default(node, request, sputnik)
end

function actions.logout_user(node, request, sputnik)
   request.is_indexable = false
   request.user = nil
   request.redirect = sputnik:make_url(request.params.next)
   return
end

-----------------------------------------------------------------------------
-- Shows the version of sputnik.
-----------------------------------------------------------------------------
function actions.sputnik_version(node, request, sputnik)
   request.is_indexable = false
   local rocks = {}
   if luarocks and luarocks.require then
      for _, rock in ipairs(sputnik.config.ROCK_LIST_FOR_VERSION or {}) do
         local __, version = luarocks.require.get_rock_from_module(rock)
         table.insert(rocks, {rock=rock, version=version or "unknown"})
      end
   end

   node.inner_html = cosmo.f(node.templates.VERSION){
                        installer = sputnik.config.VERSION or "UNKNOWN",
                        rocks     = rocks
                     }
   return node.wrappers.default(node, request, sputnik)
end

-----------------------------------------------------------------------------
-- Validates a chunk of Lua code.  Returns "valid" or "invalid" depending
-- on whether the code is ok.  (This 
-----------------------------------------------------------------------------
function actions.validate_lua(node, request, sputnik)
   request.is_indexable = false
   local code = request.params.code or ""
   local sandbox = saci.sandbox.new(sputnik.config)
   local result, err = sandbox:do_lua(code, true)
   if result then
      return "valid"
   else
      return "invalid" --tostring(err.err)
   end
end

-----------------------------------------------------------------------------
-- Shows the HTML for an error message when a non-existent action is requested.
-----------------------------------------------------------------------------

wrappers = {}

function get_breadcrumbs(node, sputnik)
   local breadcrumbs = {}
   local path = ""
   local not_first
   for i, part in ipairs{util.split(node.name, "/")} do
      path = path..part
      local b_node
      if path == node.id then
         b_node = node
      else
         b_node = sputnik:get_node(path)
      end
      local crumb = part
      if b_node.breadcrumb and b_node.breadcrumb:match("%S") then
         crumb = b_node.breadcrumb
      end
      table.insert(breadcrumbs, {
         link = sputnik:make_link(path),
         title = crumb,
         _template = not_first and 2
      })
      not_first = true
      path = path.."/"
   end
   return breadcrumbs
end


-----------------------------------------------------------------------------
-- Wraps the HTML content in bells and whistles such as the navigation bar, the header, the footer,
-- etc.
-----------------------------------------------------------------------------
function wrappers.default(node, request, sputnik)

   if request.params.skip_wrapper then
      return node.inner_html
   end

   if request.auth_message then
      node:post_error(node.translator.translate_key(request.auth_message))
   end

   local is_old = request.params.version
                  and sputnik.saci:get_node_info(node.id).version ~= request.params.version
                  and not request.is_diff

   local nav_sections, nav_subsections = get_nav_bar(node, sputnik)

   local translate = node.translator.translate

   local values = {
      site_title       = sputnik.config.SITE_TITLE or "",
      title            = sputnik:escape(node.title),
      if_no_index      = cosmo.c((not request.is_indexable) or is_old){},
      do_css_links     = node.css_links,
      do_css_snippets  = node.css_snippets,
      do_javascript_links = node.javascript_links,
      do_javascript_snippets  = node.javascript_snippets,
      if_old_version   = cosmo.c(is_old){
                            version      = request.params.version,
                         },
      logout_link      = sputnik:make_link(sputnik.config.LOGOUT_NODE, nil, {next = node.name},
                                           nil, {do_not_highlight_missing = true}),
      login_link       = sputnik:make_link(sputnik.config.LOGIN_NODE, nil, {next = node.name},
                                           nil, {do_not_highlight_missing=true}),
      register_link    = sputnik:make_link(sputnik.config.REGISTRATION_NODE),
      if_logged_in     = cosmo.c(request.user){ user = sputnik:escape(request.user) },
      if_not_logged_in = cosmo.c(not request.user){},
      if_search        = cosmo.c(sputnik.config.SEARCH_PAGE){},
      base_url         = sputnik.config.BASE_URL,
      search_page      = sputnik.config.SEARCH_PAGE,
      search_box_content = sputnik.config.SEARCH_CONTENT or "", 
      content          = node.inner_html,
      sidebar          = "",
      do_messages      = node.messages,

      do_nav_sections  = nav_sections,
      do_nav_subsections = nav_sections.current_section,
      do_breadcrumb    = get_breadcrumbs(node, sputnik),
      if_multipart_id  = cosmo.c(node.id:match("/")){},

      -- "links" include "href="
      show_link        = sputnik:make_link(node.id),
      icon_base_url    = sputnik.config.ICON_BASE_URL or sputnik.config.NICE_URL,
      css_base_url     = sputnik.config.CSS_BASE_URL or sputnik.config.NICE_URL,
      js_base_url      = sputnik.config.JS_BASE_URL or sputnik.config.NICE_URL,
      do_toolbar       = function(args)
                            local icons = sputnik.config.TOOLBAR_ICONS
                            for i, command in ipairs(sputnik.config.TOOLBAR_COMMANDS) do
                               if node:check_permissions(request.user, command) then
                                  local icon = icons[command]
                                  cosmo.yield{
                                     link = sputnik:make_link(node.id, command),
                                     title = translate("_("..command:upper()..")"),
                                     command = command,
                                     if_icon = cosmo.c(icon){ icon = icon },
                                     if_text = cosmo.c(not icon){},
                                  }
                               end
                            end
                         end,
      node_rss_link    = sputnik:make_link(node.id, "rss"),
      site_rss_link    = sputnik:make_link(sputnik.config.HISTORY_PAGE, "rss"),
      sputnik_link     = "href='http://spu.tnik.org/'",
      -- urls are just urls
      make_url         = function(args)
                            return sputnik:make_url(unpack(args))
                         end,
      base_url         = sputnik.config.BASE_URL, -- for mods
      nice_url         = sputnik.config.NICE_URL, -- for mods
      home_page_url    = sputnik.config.HOME_PAGE_URL,
      logo_url         = sputnik.config.LOGO_URL,
      favicon_url      = sputnik.config.FAVICON_URL,
      -- icons are urls of images
      if_title_icon    = cosmo.c(node.icon and node.icon~=""){title_icon = sputnik:make_url(node.icon)},
   }

   for k, v in pairs(node.fields) do
      values[k] = values[k] or node[k]
   end

   local function translate_and_fill(template, values)
      return cosmo.fill(node.translator.translate(template), values)
   end

   values.head = translate_and_fill(node.html_head, values)
   values.menu = translate_and_fill(node.html_menu, values)
   values.logo = translate_and_fill(node.html_logo, values)
   values.search = translate_and_fill(node.html_search, values)
   values.page = translate_and_fill(node.html_page, values)
   values.sidebar = translate_and_fill(node.html_sidebar, values)
   values.header = translate_and_fill(node.html_header, values)
   values.footer = translate_and_fill(node.html_footer, values)
   values.body = translate_and_fill(node.html_body, values)

   return cosmo.fill(node.html_main, values), "text/html"
end

-- vim:ts=3 ss=3 sw=3 expandtab
