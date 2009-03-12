-----------------------------------------------------------------------------
-- Defines the main class for Sputnik - an extensible wiki implemented in Lua.
-- (For usage, see sputnik.wsapi_app.)
--
-- (c) 2007, 2008  Yuri Takhteyev (yuri@freewisdom.org)
-- License: MIT/X, see http://sputnik.freewisdom.org/en/License
-----------------------------------------------------------------------------

module(..., package.seeall)

require("md5")
require("wsapi.util")
require("cosmo")

require("saci")
require("sputnik.actions.wiki")
require("sputnik.i18n")
require("sputnik.util")
require("sputnik.wsapi_app")

local zlib_loaded, zlib = pcall(require, "zlib")

new_wsapi_run_fn = sputnik.wsapi_app.new  -- for backwards compatibility

-----------------------------------------------------------------------------
-- Applies default config values.
-----------------------------------------------------------------------------
local function apply_defaults(config)
   config = config or {}
   assert(config.TOKEN_SALT, "TOKEN_SALT must be set")
   assert(config.BASE_URL, "BASE_URL must be set")

   -- Set some defaults on the configuration table
   local defaults = {}
   setmetatable(config, {__index = defaults})

   defaults.ROOT_PROTOTYPE          = "@Root"
   defaults.PASSWORD_SALT           = "2348979898237082394172309847123"
   defaults.CONFIG_PAGE_NAME        = "sputnik/config"

   return config
end

-----------------------------------------------------------------------------
-- THE SPUTNIK CLASS  -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-----------------------------------------------------------------------------
local Sputnik = {}
local Sputnik_mt = {__metatable = {}, __index = Sputnik}

-----------------------------------------------------------------------------
-- Creates a new instance of Sputnik.
--
-- @param config         a table of bootstrap configurations.
-- @param logger         a lualogging-compatible logger or nil.
-- @return               an instance of Sputnik.
-----------------------------------------------------------------------------
function new(config, logger)
   -- Set up default configuration variables
   config = apply_defaults(config)
   -- Create and return the new initialized Sputnik instance
   local obj = setmetatable({logger=logger or util.make_logger()}, Sputnik_mt)
   obj:init(config)
   return obj
end

-----------------------------------------------------------------------------
-- Initializes a the new Sputnik instance.
--
-- @param initial_config a table representing bootrastrap configurations.
-----------------------------------------------------------------------------
function Sputnik:init(initial_config)
   -- setup the logger -- do this before loading user configuration
   self.initial_config = initial_config -- for reloading

   --- Turns a string into something that can be used as a node name.
   local dirify = initial_config.DIRIFY_FN or sputnik.util.dirify
   self.dirify = function(self, text) return dirify(text) end
   -- setup the repository -- do this before loading user configuration
   self.saci = saci.new(initial_config.VERSIUM_STORAGE_MODULE or "versium.filedir",
                        initial_config.VERSIUM_PARAMS,
                        initial_config.ROOT_PROTOTYPE)
   self.saci.sandbox_values = setmetatable({}, {__index = initial_config})
   assert(self.saci)
   assert(self.saci.root_prototype_id)
   self.repo = self.saci -- for backwards compatibility

   self.saci.get_fallback_node = function(repo, id, version)
      local status, page_module = pcall(require, "sputnik.node_defaults."..id:gsub("/", "."))
      if not status then
         -- Attempt to escape the node_id using basic filesystem rules
         local esc_id = id:gsub("%%", "%%25"):gsub(":", "%%3A"):gsub("/", ".")
         status, page_module = pcall(require, "sputnik.node_defaults."..esc_id)
      end

      if status then
         local data = self.saci:deflate(page_module.NODE)
         local node = self.saci:make_node(data, id)
         assert(node)
         if page_module.CREATE_DEFAULT then
            node = self:save_node(node, nil)
            node = self.saci:get_node(id)
         end
         return node
      else
         return self.saci:make_node("", id), true -- set stub=true
      end
   end

   assert(self.saci)
   self.saci.logger = self.logger 

   -- WARNING ---------------------------------------------------------------
   -- Up to now we were using "initial_config" which is loaded from
   -- sputnik/config.lua We are now going to load values from the
   -- configuration node.  This means that the config values can no longer be
   -- trusted quite as much.
   
   self.config = initial_config
   initial_config = nil -- just to keep us honest

   local config_node = self:get_node(self.config.CONFIG_PAGE_NAME)
   assert(config_node, "Failed to retrieve the config node "
                       ..tostring(self.config.CONFIG_PAGE_NAME))
   assert(type(config_node)=="table")
   --print(config_node.content, "XX", config_node.fields.content.activate)
   for k,v in pairs(config_node.content) do
      self.config[k] = v
   end

   -- setup cache
   if self.config.CACHE_MODULE then
      local cache_mod = require(self.config.CACHE_MODULE)
      self.cache = cache_mod.new(self, self.config.CACHE_MODULE_PARAMS)
   else
      self.cache = {
         add = function() end,
         del = function() end,
         get = function() end,
      }
   end

   -- setup app cache
   if self.config.APP_CACHE_STORAGE_MODULE then
      local cache_mod = require(self.config.APP_CACHE_STORAGE_MODULE)
      self.app_cache = cache_mod.new(self.config.APP_CACHE_PARAMS)
   end

   -- setup captcha

   if self.config.CAPTCHA_MODULE then
      local captcha_mod = require(self.config.CAPTCHA_MODULE)
      self.captcha = captcha_mod.new(self.config.CAPTCHA_PARAMS)
   end
      
   -- setup authentication
   self.auth_mod = require(self.config.AUTH_MODULE or "sputnik.auth.simple")
   self.auth = self.auth_mod.new(self, self.config.AUTH_MODULE_PARAMS)
   self.saci.permission_groups.Admin = function(user)
      return user and self.auth:get_metadata(user, "is_admin") == "true"
   end

   local groups_mt = {
      __index = function(table, key)
         return function (user)
                   return user and self.auth:get_metadata(user, "is_"..key) == "true"
                end
      end
   }
   self.saci.permission_groups.is = setmetatable({}, groups_mt)
   self.saci.permission_groups.edit_and_save = {"save", "edit", "preview"}
   self.saci.permission_groups.show = {"show", "show_content", "cancel"}
   self.saci.permission_groups.history_and_diff = {"history", "diff"}
   self.saci.permission_groups.show_etc = {"show", "show_content", "cancel", "history", "diff"}

   -- setup wrappers
   self.wrappers = sputnik.actions.wiki.wrappers -- same for "wiki" wrappers      
end

-----------------------------------------------------------------------------
-- Converts a versium time stamp into the requested format.  (Same as
-- versium.util.format_time, except that config parameters are applied.)
--
-- @param timestamp      Versium timestamp (string) 
-- @param format         Lua time format (string) 
-- @param tzoffset       time zone offset as "+hh:mm" or "-hh:mm"
--                        (ISO 8601) or "local" [string, optional, defaults 
--                        to "local"]
-- @param tzname         name/description of the time zone [string, optional,
--                        defaults to tzoffset, valid XHTML is ok]
-- @return               formatted time (string)
-----------------------------------------------------------------------------
function Sputnik:format_time(timestamp, format, tzoffset, tzname)
   if type(timestamp) == "number" or timestamp:match("^[0-9]*$") then
      timestamp = os.date("!%Y-%m-%d %H:%M:%S", timestamp)
   end
   return versium.util.format_time(timestamp,format, 
                                   tzoffset or self.config.TIME_ZONE,
                                   tzname or self.config.TIME_ZONE_NAME)
end

-----------------------------------------------------------------------------
-- Converts a versium time stamp into the format specified in RFC-822.  This
-- format will always be given in GMT for simplicity, which will be correctly
-- altered by the reader.
--
-- @param timestamp      Versium timestamp (string) 
-- @return               Time string that complied with RFC-822 (string)
-----------------------------------------------------------------------------
function Sputnik:format_time_RFC822(timestamp)
   return self:format_time(timestamp, "!%a, %d %b %Y %H:%M:%S +0000")
end

function Sputnik:get_gravatar_for_email(email)
   if self.config.USE_GRAVATAR then
      return "http://www.gravatar.com/avatar/"..md5.sumhexa(email)
                .."?s=22&d="
                ..sputnik.util.escape_url("http://"
                    ..self.config.DOMAIN..self:make_url("icons/user", "png"))
   else
      return self:make_url("icons/user", "png")
   end
end


-----------------------------------------------------------------------------
-- Returns a small icon to represent a given user.
--
-- @param user           username
-- @return               a url of an icon
-----------------------------------------------------------------------------
function Sputnik:get_user_icon(user)
   self.user_icon_hash = self.user_icon_hash or {}
   if self.user_icon_hash[user] then
      return self.user_icon_hash[user]
   end
   local icon
   if not user or user:len()==0 then
      icon = self:make_url("icons/anon", "png")
   elseif user=="admin" or user=="Admin" then 
      icon = self:make_url("icons/admin", "png")
   elseif user=="Sputnik-UID" or user=="Sputnik" then
      icon = self:make_url("icons/system", "png") 
   elseif self.auth:user_exists(user) then
      local email = self.auth:get_metadata(user, "email")
      if email then 
         icon = self:get_gravatar_for_email(email)
      end
   end
   if (not icon) and user:match("@") then
      icon = self:get_gravatar_for_email(user)
   end
   self.user_icon_hash[user] = icon or self:make_url("icons/user", "png")
   return self:escape(self.user_icon_hash[user])
end

-----------------------------------------------------------------------------
-- Escapes a text for using in a textarea.
--
-- @param text           text to be escaped.
-- @return               escaped text.
-----------------------------------------------------------------------------
function Sputnik:escape(text)
   return sputnik.util.escape(text)
end

-----------------------------------------------------------------------------
-- Escapes a URL.
--
-- @param url            a URL to be escaped.
-- @return               the escaped URL
-----------------------------------------------------------------------------
function Sputnik:escape_url (url)
   return sputnik.util.escape_url(url)
end

-----------------------------------------------------------------------------
-- Checks if a node with the given ID exists.
--
-- @param id             the id of a node.
-- @return               true or false.
-----------------------------------------------------------------------------
function Sputnik:node_exists(id)
   id = self:dirify(id)
   return self.saci:node_exists(id) or pcall(require, 
                                             "sputnik.node_defaults."..id)
end

-----------------------------------------------------------------------------
-- Makes a URL from a table of parameters.
--
-- @param node_name      a node id.
-- @param action         action/command as a string.
-- @param params         query parameters
-- @param anchor         link anchor
-- @return               a URL.
-----------------------------------------------------------------------------
function Sputnik:make_url(node_name, action, params, anchor)
   if not node_name or node_name=="" then
      node_name = self.config.HOME_PAGE
   end

   local interwiki_code = node_name:match("^([^%:]*)%:")
   local interwiki_handler = self.config.INTERWIKI[interwiki_code]
   if interwiki_handler then
      node_name = node_name:gsub("^[^%:]*%:", "") -- crop the code
   end

   local dirified = self:dirify(node_name) --wsapi.util.url_encode()

   local url

   -- first the node name
   if interwiki_handler then
      local handler_type = type(interwiki_handler)
      if handler_type == "string" then
         if interwiki_handler:match("%%s") then
            url = string.format(interwiki_handler, node_name)
         else
            url = interwiki_handler..node_name
         end
      elseif handler_type == "function" then
         url = interwiki_handler(node_name)
      else
         error("Interwiki handler should be string or function, but is "..handler_type)
      end
   else
      url = self.config.NICE_URL..dirified
   end

   -- then the action and HOME_PAGE
   if action and action~="show" then 
      url = url.."."..action
   elseif dirified==self.config.HOME_PAGE and #(params or {})==0 then
      url = self.config.HOME_PAGE_URL
   end

   -- then the parameters
   if params and next(params) then
      for k, v in pairs(params or {}) do
         if k~="p" then
            url = url.."&"..wsapi.util.url_encode(k).."="
                          ..wsapi.util.url_encode(v or "")
         end
      end
   end

   -- finally the anchor
   if anchor then
      url = url.."#"..anchor
   end

   return self:escape(url), node_name
end

-----------------------------------------------------------------------------
-- Makes a link from a table of parameters.
--
-- @param node_name      a node id.
-- @param action         action/command as a string.
-- @param params         query parameters
-- @param anchor         link anchor
-- @return               a URL.
-----------------------------------------------------------------------------
function Sputnik:make_link(node_name, action, params, anchor, options)
   assert(node_name)
   options=options or {}
   -- check if we have a command attached to the node name
   if node_name:find("%.") then 
      node_name, action = node_name:match("(.+)%.(.+)")
   end
   --local css_class = "local"
   local url = self:make_url(node_name, action, params, anchor)
   self.logger:debug("Creating a link to "..node_name)
   if (not options.mark_missing==false)
      and (not self:node_exists(node_name)) then
      css_class="no_such_node"
      url = self:make_url(node_name, action, params, anchor)
      self.logger:debug("No such node, will link to .edit")
   end
   --return string.format("href='%s' class='%s'", url, css_class)
   return string.format("href='%s'", url, css_class)
end

-----------------------------------------------------------------------------
-- Further "activates" a node for use in Sputnik.
--
-- @param node           a Saci node.
-- @return               the same node with some extra methods added.
-----------------------------------------------------------------------------
function Sputnik:activate_node(node)

   -- setup the page-specific translator
   for i, translation_node in ipairs(node.translations) do
      local translations = self:get_node(translation_node).content
      assert(type(translations) == "table",
             "Could not load translation node")
      for k, translation in pairs(translations) do
         node.translations[k] = translation
      end
    end
    node.translator = sputnik.i18n.make_translator(node.translations,
                                              self.config.INTERFACE_LANGUAGE)
    
   -- translate the templates
   for i, template_node_id in ipairs(node.templates) do
      local template_node = self:get_node(template_node_id)
      local templates = template_node.content
      --templates.MAIN = template_node.main
      --templates.HEAD = template_node.head
      --templates.BODY = template_node.body
      assert(type(templates) == "table", "Could not load templates node")
      for k, template in pairs(templates) do
         node.templates[k] = node.translator.translate(template)
      end
      
   end
   
   -- load the actions (turn them into callable functions)
   local function action_loader() 
      local mod_cache = {}
      return { 
         load = function(mod_name)
            if not mod_cache[mod_name] then
               mod_cache[mod_name] = require("sputnik.actions." .. mod_name)
            end
            return mod_cache[mod_name].actions
         end
      }
   end
   local action_loader = action_loader()
   
   for command, action_function in pairs(node.actions) do
      if type(action_function) == "string" then
         local mod_name, dot_action = sputnik.util.split(action_function, "%.")
         node.actions[command] = action_loader.load(mod_name)[dot_action]
      end
   end

   -- set wrappers -----------------------------------------------------
   node.wrappers = self.wrappers
   
   return node
end

-----------------------------------------------------------------------------
-- Returns the node with this name (without additional activation).
-----------------------------------------------------------------------------
function Sputnik:get_node(id, version, mode)
   local node, stub = self.saci:get_node(id, version)
   
   node.name = id
   if not node.title then
      local temp_title = string.gsub(node.name, "_", " ")
      node.title = temp_title
      node.raw_values.title = temp_title
   end
   return node, stub
end

-----------------------------------------------------------------------------
-- Adds extra sputnik-specific fields to a node.
-----------------------------------------------------------------------------
function Sputnik:decorate_node(node)
   -- Determine which markup module the node should be using based on
   -- the markup_module field, or the default
   local markup_module_name
   if node.markup_module and node.markup_module:len() > 0 then
      markup_module_name = "sputnik.markup."..node.markup_module
   else
      markup_module_name = "sputnik.markup.markdown"
   end

   local markup_module = require(markup_module_name)
   node.markup = markup_module.new(self)

   node.messages = {}
   for i, class in ipairs{"error", "warning", "success", "notice"} do
      node["post_"..class] = function(self, message) 
         table.insert(self.messages, {message=message, class=class})
      end
   end
   -- Table/Function that allow the developer to add custom HTML response headers
   node.headers = {}
   node.add_header = function(self, header, value) self.headers[header] = value end
   node.redirect = function(node_self, url)
      node_self.headers["Location"] = url
   end

   node.css_links = {}
   node.css_snippets = {}
   node.javascript_links = {}
   node.javascript_snippets = {}

   local function add(tab, key, values, defaults)
      if tab[key] then return end
      tab[key] = true
      table.insert(tab, values)
   end
   function node:add_css_link(href, media)
      media = media or "screen"
      return add(self.css_links, href.."|"..media, {href = href, media = media})
   end
   function node:add_css_snippet(href, snippet, media)
      media = media or "screen"
      return add(self.css_snippets, href.."|"..media, {snippet = snippet, media = media})
   end
   function node:add_javascript_link(href)
      add(self.javascript_links, href, {href=href})
   end
   function node:add_javascript_snippet(snippet)
      return add(self.javascript_snippets, snippet, {snippet=snippet})
   end
   return node
end  

-----------------------------------------------------------------------------
--- Updates node with values from params table.
-----------------------------------------------------------------------------
function Sputnik:update_node_with_params(node, params)
   node:update(params, node.fields)
   --new_node.name = node.name
   self:decorate_node(node)
   return node
end

-----------------------------------------------------------------------------
-- This function is provided as a wrapper to node:save(...) that respects the
-- save_hook field in a node.  This field defines a module and function name
-- that are called when the node is being saved, allowing for last minute
-- changes to the node parameters, or for other actions to be taken alongside
-- the save.
--
-- NODE: A save hook is passed the node, the request object and the sputnik
-- instance, although request and sputnik are not guaranteed to be available
-- for certain types of nodes.
-----------------------------------------------------------------------------
function Sputnik:save_node(node, request, ...)
   local new_node = node
   if type(node.save_hook) == "string" and #node.save_hook > 0 then
      local mod_name, func_name = sputnik.util.split(node.save_hook, "%.")
      local module = require("sputnik.hooks." .. mod_name)
      local save_hook = module[func_name]
      new_node = save_hook(node, request, self)
   end
   -- Actually perform the save at the saci layer
   new_node:save(...)
   return new_node
end

-----------------------------------------------------------------------------
-- Returns node's history.
-----------------------------------------------------------------------------
function Sputnik:get_history(node_name, limit, date_prefix)
   local edits = self.saci:get_node_history(node_name, date_prefix, limit)
   if limit then 
      for i=limit, #edits do
         table.remove(edits, i)
      end
   end
   return edits
end

-----------------------------------------------------------------------------
-- Returns history for all nodes.
-----------------------------------------------------------------------------
function Sputnik:get_complete_history(limit, date_prefix, id_prefix)
   return self.saci:get_complete_history(id_prefix, date_prefix, limit)
end

-----------------------------------------------------------------------------
-- Returns a list of all node ids.
-----------------------------------------------------------------------------
function Sputnik.get_node_names(self, args)
   return self.saci.versium:get_node_ids(args and args.prefix or nil,
                                         args and args.limit or nil)
end

-----------------------------------------------------------------------------
-- Generates a hash for a POST field name.
-----------------------------------------------------------------------------
function Sputnik:hash_field_name(field_name, token)
   return "field_"..md5.sumhexa(field_name..token..self.config.TOKEN_SALT)
end

-----------------------------------------------------------------------------
-- Generates a unique numeric or hashed identifier using sputnik's default
-- storage repository as the shared state.
--
-- @param namespace      [optional] a namespace idenfier string (defaults to
--                       "sputnik").
-- @param type           [optional] the type of uid to generate ("hash" or
--                       "number", defaults to "number").
-- @return               uid a unique identifier for the given namespace.
-----------------------------------------------------------------------------
function Sputnik:get_uid(namespace, type)
   -- Initialize the default values
   namespace = namespace or "sputnik"
   type = type or "number"

   -- Generate the values we'll use in the initial hash
   local memory = collectgarbage("count")
   local time = os.time() + os.clock()
   local hash = md5.sumhexa(namespace .. memory .. time)

   -- Create and store a node
   local node_name = "_uid:" .. namespace
   local node = self:get_node(node_name)
   node = self:update_node_with_params(node, {content=hash})
   node = self:save_node(node, nil, "Sputnik-UID", hash)

   -- Retrieve the node history 
   local history = self:get_history(node_name)
   local history_id

   -- Find our specific hash in the history
   for i=1,#history do
	   if history[i].comment == hash then
		   -- This is our node, it will likely be the first entry
		   -- So add it to the total number of entries
		   history_id = #history + (i - 1)
		   break
	   end
   end

   assert(history_id)
   if type == "number" then
	  return history_id
   else
	  return md5.sumhexa(namespace .. memory .. time .. history_id)
   end
end

-----------------------------------------------------------------------------
-- Sends email on Sputnik's behalf.
-----------------------------------------------------------------------------
function Sputnik:sendmail(args)
   return sputnik.util.sendmail(args, self)
end

-----------------------------------------------------------------------------
-- Pre-processes CGI parameters and does authentication.
-----------------------------------------------------------------------------
function Sputnik:translate_request (request)
   if request.method=="POST" then
      request.params = request.POST or {}
   else
      request.params = request.GET or {}
   end

   -- For a post action we'll need to unhash the parameters first.  Note that
   -- we don't care if the action was actually submitted via get or post: if
   -- an idempotent request was sent via POST, that's ok.  Instead, we divide
   -- actions into two types: those that were submitted with a post token and
   -- those that were submitted without.  Requests submitted with a post token
   -- are allowed to make changes to the state of the wiki.  They get their
   -- fields unhashed.  This means that if an action is submitted with a post
   -- token but its fields are not hashed, it will be processed as if
   -- submitted with no arguments.
   if request.params.post_token then
      assert(request.params.post_fields)
      self.logger:debug("handling post parameters")
      local new_params = {}
      for k,v in pairs(request.params) do
         if k:sub(0,7) == "action_" then
            new_params[k] = v
         end
      end
      for name in string.gmatch(request.params.post_fields, "[%a_]+") do 
         self.logger:debug(name)
         local field = self:hash_field_name(name, request.params.post_token)
         new_params[name] = request.params[field] or ""
         --self.logger:debug(new_params[name])
      end
      new_params.p = request.params.p
      new_params.post_token = request.params.post_token
      new_params.post_timestamp = request.params.post_timestamp
      request.params = new_params
   end

   -- break "p" parameter into node name and the action
   if request.params.p and request.params.p~="" then
      request.node_name, request.action = sputnik.util.split(request.params.p, "%.")
   else
      request.node_name = self.config.HOME_PAGE 
   end
   request.node_name = request.node_name:gsub("/$", "") -- remove the trailing slash
   request.action = request.action or "show"

   -- now login/logout/register the user
   if request.params.logout then 
      request.user = nil
   elseif (request.params.user or ""):len() > 0 then
      request.user, request.auth_token = self.auth:authenticate(
                                                      request.params.user, 
                                                      request.params.password)
      if not request.user then
         request.auth_message = "INCORRECT_PASSWORD"
         -- TODO: I am unsure what the behavior here should be.. 
         request.node_name = self.config.LOGIN_NODE
      else
         if request.params.next then
            request.redirect = self:make_url(request.params.next)
         end

         self.logger:debug(request.user..","..request.auth_token)
      end
   else
      local cookie = request.cookies[self.cookie_name] or ""
      local user_from_cookie, auth_token = sputnik.util.split(cookie, "|")
      if user_from_cookie then
         request.user = self.auth:validate_token(user_from_cookie, auth_token)
         if request.user then
            request.auth_token = auth_token
         end
      end
   end
   return request
end

-----------------------------------------------------------------------------
-- Handles a request.
--
-- @param request        a WSAPI request table.
-- @param response       a WSAPI response table.
-- @return               the response
-----------------------------------------------------------------------------
function Sputnik:handle_request(request, response)
   self.auth = self.auth_mod.new(self, self.config.AUTH_MODULE_PARAMS)

   self.cookie_name = self.config.COOKIE_NAME.."_"..md5.sumhexa(self.config.BASE_URL)
   request = self:translate_request(request)
   request.is_indexable = true

   local dirified = self:dirify(request.node_name)

   local node, stub = self:get_node(request.node_name, request.params.version)
   node.is_a_stub = stub
   self:decorate_node(node)

   if request.redirect then
      self.logger:debug("Sending redirect")
      -- Set the authentication cookie so it's not lost
      local cookie_value = (request.user or "").."|"..(request.auth_token or "")
      response:set_cookie(self.cookie_name, {value=cookie_value, path="/"})

      response.headers["Content-Type"] = "text/html"
      response.headers["Location"] = request.redirect
      response:write("redirect")
      return response
   end

   if dirified ~= request.node_name then
      response.headers["Content-Type"] = content_type or "text/html"
      response.headers["Location"] = self:make_url(dirified, request.action, request.params)
      response:write("redirect")
      return response
   end
  
   if stub and self.config.PROTOTYPE_PATTERNS then
      -- If an empty stub was returned, check the PROTOTYPE_PATTERNS table to
      -- see if we should apply a prototype.
      local node_name = request.node_name
      for pattern,prototype in pairs(self.config.PROTOTYPE_PATTERNS or {}) do
         if node_name:find(pattern) then
            request.params.prototype = prototype;
            break
         end
      end
   end

   if request.params.prototype then 
      self:update_node_with_params(node, {prototype = request.params.prototype})
   end

   node = self:activate_node(node, request)

   local action = request.action or "show"
   local action_function = node.actions[action]

   local content, content_type

   if not action_function then
      content, content_type = sputnik.actions.wiki.actions.action_not_found(node, request, self)
   elseif node:check_permissions(request.user, action) then
      -- Check permissions on the node, for the given action
      content, content_type = action_function(node, request, self)
   else
      -- The user did not have permission, so give a message stating this
      node:post_error("Sorry, that action is not allowed")
      node.inner_html = ""
      content, content_type = node.wrappers.default(node, request, self)
   end

   if request.redirect then
      self.logger:debug("Sending redirect")
      -- Set the authentication cookie so it's not lost
      local cookie_value = (request.user or "").."|"..(request.auth_token or "")
      response:set_cookie(self.cookie_name, {value=cookie_value, path="/"})

      response.headers["Content-Type"] = "text/html"
      response.headers["Location"] = request.redirect
      response:write("redirect")
      return response
   end

   assert(content)
   response.headers["Content-Type"] = content_type or "text/html"

   if node.http_cache_control and node.http_cache_control~="" then
      node.headers["Cache-Control"] = node.http_cache_control
   end
   if node.http_expires and node.http_expires~="" then
      node.headers["Expires"] = os.date("!%a, %d %b %Y %H:%M:%S GMT",
                                        os.time()+3600*1000*tonumber(node.http_expires))
   end

   -- If we have any custom HTML headers, add them to the response
   for header,value in pairs(node.headers) do
      response.headers[header] = value
   end

   local cookie_value = (request.user or "").."|"..(request.auth_token or "")
   response:set_cookie(self.cookie_name, {value=cookie_value, path="/"})

   -- gzip compression code borrowed from Ignacio Burgeno
   if self.config.USE_COMPRESSION and zlib_loaded
      and string.find(request.wsapi_env["HTTP_ACCEPT_ENCODING"], "gzip") then
      --zlib.compress(string buffer [, int level] [, int method] [, int windowBits] [, int memLevel] [, int strategy])
      --that magic came from http://lua-users.org/lists/lua-l/2005-03/msg00221.html
      local gz_content = zlib.compress(content, 9, nil, 15 + 16)
      response.headers["Content-Encoding"] = "gzip"
      response.headers["Content-Length"] = #gz_content
      response.headers["Vary"] = "accept-encoding"
      response:write(gz_content)
   else
      response:write(content)
   end

   if self.saci.reset_cache then self.saci:reset_cache() end
   return response
end

-- vim:ts=3 ss=3 sw=3 expandtab
