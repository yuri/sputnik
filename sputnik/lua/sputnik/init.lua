-----------------------------------------------------------------------------
-- Defines the main class for Sputnik - an extensible wiki implemented in Lua.
--
-- The main function exported by the module is new(), which creates an
-- instance of Sputnik. Most of the code in the module is defining method of
-- Sputnik, but Sputnik prototype is itself not exported - use new() to
-- instantiate it.
--
-- For an example of how to use an instance of Sputnik, see spuntnik.wsapi_app,
-- which is an adapter for WSAPI. The basic usage is:
--
--     require("sputnik")
--     local my_sputnik = sputnik.new()
--     local response = my_sputnik:handle_request(request)
--
-- handle_requests() can be called multiple times.
--
-- The main method of Sputnik is handle_request(). If you want to read the
-- code, handle_request() is the place to start.
--
-- (c) 2007 - 2009  Yuri Takhteyev (yuri@freewisdom.org)
-- License: MIT/X, see http://sputnik.freewisdom.org/en/License
-----------------------------------------------------------------------------

module(..., package.seeall)

require("md5")
require("wsapi.util")
require('wsapi.request')
require("cosmo")
require("saci")
require("sputnik.actions.wiki")
require("sputnik.i18n")
require("sputnik.util")
require("sputnik.wsapi_app")
local html_forms = require("sputnik.util.html_forms")
local zlib_loaded, zlib = pcall(require, "zlib")

new_wsapi_run_fn = sputnik.wsapi_app.new  -- for backwards compatibility

DEFAULT_STORAGE_MODULE = "versium.filedir"
DEFAULT_PROTOTYPE_NODE = "@Root"
DEFAULT_CONFIG_NODE = "sputnik/config"
NODE_DEFAULTS = "sputnik.node_defaults"
DEFAULT_MARKUP_MODULE = "sputnik.markup.markdown"
-----------------------------------------------------------------------------
-- THE SPUTNIK CLASS
--
-- Sputnik is a table that stores the methods. Sputnik_mt is a table that
-- we use as a metatable for instances of Sputnik.
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
   -- Create new Sputnik instance (a table with Sputnik_mt as the metatable)
   local obj = setmetatable({logger=logger or util.make_logger()}, Sputnik_mt)
   -- Initialize it
   obj:init(config) -- this function does all the heavy lifting
   return obj
end




--=========================================================================--
--   INITIALIZING SPUTNIK
--=========================================================================--


-----------------------------------------------------------------------------
-- Initializes a the new Sputnik instance.
--
-- @param initial_config a table representing bootrastrap configurations.
-----------------------------------------------------------------------------
function Sputnik:init(initial_config)

   self.config = initial_config or {} -- temporarily
   self.initial_config = initial_config -- for reloading

   -- Initialize default storage configuration options. If the configuration
   -- node overwrites these values, they won't actually be used as storage
   -- will have already been initialized using these values
   if not self.config.ROOT_PROTOTYPE then
      self.config.ROOT_PROTOTYPE = DEFAULT_PROTOTYPE_NODE
   end
   if not self.config.VERSIUM_STORAGE_MODULE then
      self.config.VERSIUM_STORAGE_MODULE = DEFAULT_STORAGE_MODULE
   end

   -- Initialize storage - do this before loading stored configurations.
   self:initialize_storage()

   -- Load configurations from a config node.
   local config_node_id = self.config.CONFIG_PAGE_NAME or DEFAULT_CONFIG_NODE
   local config_node = self:get_node(config_node_id)
   local new_config = config_node.content
   assert(new_config and type(new_config)=="table",
          "Config node's content should evaluate to a table")
   self.config = setmetatable(new_config, {__index=self.config})

   -- Initialize authentication and permissions
   self.auth_mod = require(self.config.AUTH_MODULE or "sputnik.auth.simple")
   self.auth = self.auth_mod.new(self, self.config.AUTH_MODULE_PARAMS)
   self:initialize_permissions()

   -- Initialize caching
   self:initialize_caching()

   -- Setup captcha
   if self.config.CAPTCHA_MODULE then
      local captcha_mod = require(self.config.CAPTCHA_MODULE)
      self.captcha = captcha_mod.new(self.config.CAPTCHA_PARAMS)
   end

   -- setup wrappers
   self.wrappers = sputnik.actions.wiki.wrappers -- same for "wiki" wrappers      
end


-----------------------------------------------------------------------------
-- Initializes storage for a new Sputnik instance.
--
-- Sputnik uses Saci for storage. (See Saci documentation.) This methods
-- creates a Saci instance based on supplied parameters and adds a few hooks
-- to it.
-----------------------------------------------------------------------------
function Sputnik:initialize_storage()
   -- create an instance of Saci
   self:assert_config("VERSIUM_PARAMS", " to initialize storage.")
   self.saci = saci.new(self.config.VERSIUM_STORAGE_MODULE,
                        self.config.VERSIUM_PARAMS,
                        self.config.ROOT_PROTOTYPE)
   -- put config values into Saci's sandbox so that they would be available
   -- to all code run in a sandbox.
   self.saci.sandbox_values = setmetatable({}, {__index = self.config})
   assert(self.saci)
   assert(self.saci.root_prototype_id)
   self.repo = self.saci -- for backwards compatibility

   -- provide a function that would tell saci what to do when asked for a non-
   -- existent node
   self.saci.get_fallback_node = function(repo, id, version)
       local node_from_module = self:get_node_from_module(id)
       if node_from_module then
          return node_from_module
       else
          return self.saci:make_node("", id), true -- set stub=true
       end
   end
   assert(self.saci)
   self.saci.logger = self.logger  
end


-----------------------------------------------------------------------------
-- Initializes caching modules.
-----------------------------------------------------------------------------
function Sputnik:initialize_caching()
   -- Setup the basic cache -- used by handle_request()
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

   -- Setup application cache -- used by action function
   if self.config.APP_CACHE_STORAGE_MODULE then
      local cache_mod = require(self.config.APP_CACHE_STORAGE_MODULE)
      self.app_cache = cache_mod.new(self.config.APP_CACHE_PARAMS)
   end
end

-----------------------------------------------------------------------------
-- Defines additional groups for permission
-----------------------------------------------------------------------------
function Sputnik:initialize_permissions()
   local groups = self.saci.permission_groups -- just a local alias
   -- Define group "admin" as any user that has is_admin set to true
   groups.Admin = function(user)
      return user and self.auth:get_metadata(user, "is_admin") == "true"
   end

   -- Define "owner" as any user who is included in node.owners
   groups.owners = function(user, node)
      local s1 = ","..(node.owners or ""):gsub("%s","")..","
      local s2 = ","..user..","
      return s1:match(s2)
   end
   
   -- Define any group that starts with "is.<group>" as including all users
   -- for whom "is_<group>" is set to true. For example, if is_clown is set
   -- to true than user is a member of group "is.clown" and we can set:
   --
   --     allow(is.clown, "show")
   --
   local groups_mt = {
      __index = function(table, key)
         return function (user)
                   return user and self.auth:get_metadata(user, "is_"..key) == "true"
                end
      end
   }
   groups.is = setmetatable({}, groups_mt)

   -- Some additional groups for actions, to make it easier to set permissions
   -- for related actions.
   groups.edit_and_save = {"save", "edit", "preview"}
   groups.show = {"show", "show_content", "cancel"}
   groups.history_and_diff = {"history", "diff"}
   groups.show_etc = {"show", "show_content", "cancel", "history", "diff"}
end



--=========================================================================--
--   HANDLING A REQUEST
--=========================================================================--


-----------------------------------------------------------------------------
-- Handles a request. This is the main method offered by the Sputnik
-- prototype.
--
-- @param request        a WSAPI request table.
-- @param response       a WSAPI response table.
-- @return               the response
-----------------------------------------------------------------------------
function Sputnik:handle_request(request, response)

   -- Get some basic things out of the way
   self:assert_config("BASE_URL", " to handle requests.")
   if not self.cookie_name then
      local base_url_hash = md5.sumhexa(self.config.BASE_URL)
      self.cookie_name = self.config.COOKIE_NAME.."_"..base_url_hash
   end
   self.auth = self.auth_mod.new(self, self.config.AUTH_MODULE_PARAMS)

   -- Turn the raw request into a more convenient form. This will basically
   -- add new fields to the request which we can then use.
   request = self:translate_request(request)
   request.is_indexable = true

   -- Now that we know who the user is, set the authentication cookie.
   local cookie_value = (request.user or "").."|"..(request.auth_token or "")
   response:set_cookie(self.cookie_name, {value=cookie_value, path="/"})

   -- If a GET request uses a non-canonical node id, redirect to the right one.
   local canonical_id = self:dirify(request.node_name)
   if request.method=="GET" and request.node_name ~= canonical_id then          
      local new_url = self:make_url(canonical_id, request.action, request.params)
      response.headers["Location"] = new_url
      response.status = 301 -- permanent redirect
      response.headers["Content-Type"] = "text/html"
      response:write(new_url)
      return response
   end

   -- Load the node we need
   local node, stub = self:get_node(request.node_name, request.params.version)
   node.is_a_stub = stub
   self:decorate_node(node)
  
   -- If the node is just a stub (i.e., wasn't found in storage), check if it
   -- should be assigned a prototype
   if stub then
      local prototype
      -- One possibility is that the prototype was specified in the request
      if request.params.prototype then
         prototype = request.params.prototype
      else
         -- Another possibility is that the node matches a pattern in
         -- PROTOTYPE_PATTERNS
         local patterns = self.config.PROTOTYPE_PATTERNS or {}
         for pattern, pattern_prototype in pairs(patterns) do
            if request.node_name:find(pattern) then
               prototype = pattern_prototype;
               break
            end
         end
      end
      if prototype then
         self:update_node_with_params(node, {prototype = prototype})
      end
   end

   -- Activate the node.
   node = self:activate_node(node, request)

   -- Figure out what action we need to call and call it. 
   local action = request.action or "show"
   local action_function = node.actions[action]

   if not action_function then
      action_function = sputnik.actions.wiki.actions.action_not_found
   elseif not node:check_permissions(request.user, action) then
      action_function = sputnik.actions.wiki.actions.access_denied
   end

   -- Call the action function. This gives us content and content_type.
   local content, content_type = action_function(node, request, self)

   -- Check if the action logged out the user.
   if not request.user then
      response:set_cookie(self.cookie_name, {value="", path="/"})
   end

   -- If we have any custom HTML headers, add them to the response
   for header,value in pairs(node.headers) do
      response.headers[header] = value
   end

   -- If the action altered the status code, set that in the response
   if type(node.status) == "number" then
      response.status = node.status
   end

   -- If we ave any cookie values, add them to the response
   for name,value in pairs(node.cookies) do
      if value == false then
         response:delete_cookie(name)
      else
         response:set_cookie(name, {value = value, path = "/"})
      end
   end

   -- Reset the node cache.
   if self.saci.reset_cache then self.saci:reset_cache() end

   -- Check if the action function requested a redirect.
   if request.redirect then
      response.headers["Content-Type"] = content_type or "text/html"
      response.headers["Location"] = request.redirect
      response:write(content or request.redirect)
      return response
   end

   -- If we didn't redirect, let's prepare to return the content.
   assert(content)
   response.headers["Content-Type"] = content_type or "text/html"

   -- Set headers for caching.
   if node.http_cache_control and node.http_cache_control~="" then
      node.headers["Cache-Control"] = node.http_cache_control
   end
   if node.http_expires and node.http_expires~="" then
      node.headers["Expires"] = os.date("!%a, %d %b %Y %H:%M:%S GMT",
                                        os.time()+3600*1000*tonumber(node.http_expires))
   end

   -- Gzip the content if we have a gzip module and the user-agent accepts.
   -- (Gzip compression code borrowed from Ignacio Burgeno)
   if self.config.USE_COMPRESSION and zlib_loaded
      and string.find(request.wsapi_env["HTTP_ACCEPT_ENCODING"], "gzip") then
      --zlib.compress(string buffer [, int level] [, int method] [, int windowBits] [, int memLevel] [, int strategy])
      --that magic came from http://lua-users.org/lists/lua-l/2005-03/msg00221.html
      local gz_content = zlib.compress(content, 9, nil, 15 + 16)
      response.headers["Content-Encoding"] = "gzip"
      response.headers["Content-Length"] = #gz_content
      response.headers["Vary"] = "accept-encoding"
      response:write(gz_content)
   else -- Otherwise just write the content.
      response:write(content)
   end

   return response
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
-- Generates a hash for a POST field name.
-----------------------------------------------------------------------------
function Sputnik:hash_field_name(field_name, token)
   assert(self.config.TOKEN_SALT, "TOKEN_SALT must be set")
   return "field_"..md5.sumhexa(field_name..token..self.config.TOKEN_SALT)
end




--=========================================================================--
--   RETRIEVING AND MANIPULATING NODES
--=========================================================================--


-----------------------------------------------------------------------------
-- Gets a node from Saci and returns it as is, without any embelishments.
--
-- Nodes returned by get_node() can be used for getting information
-- programmatically. For the main node (the one being displayed to the user),
-- we need more, however. Hence, decorate_node() and activate_node().
-----------------------------------------------------------------------------
function Sputnik:get_node(id, version)
   local node, stub = self.saci:get_node(id, version)
   node.name = id -- for backwards compatibility
   if not node.title then
      local temp_title = string.gsub(node.name, "_", " ")
      node.title = temp_title
      node.raw_values.title = temp_title
   end
   return node, stub
end


-----------------------------------------------------------------------------
-- Attempts to retrieve a node from a module.
--
-- This allows us to ship default nodes as modules through LuaRocks. Note
-- this method is essentially a call back for saci. See initialize_storage().
-----------------------------------------------------------------------------
function Sputnik:get_node_from_module(id)
   -- See if we have a module in sputnik.node_defaults that would correspond
   -- to this node id.
   local node_module_name = NODE_DEFAULTS.."."..id:gsub("/", ".")
   local ok, node_module = pcall(require, node_module_name)
   if not ok then -- Try again with escaping special characters in the node id
      local escaped_id = id:gsub("%%", "%%25"):gsub(":", "%%3A")
      node_module_name = NODE_DEFAULTS.."."..escaped_id:gsub("/", ".")
      ok, node_module = pcall(require, node_module_name)
   end
   if ok then -- managed to load a module for this node
      -- The NODE field in node_module has the node as a table, so we need to
      -- deflate it into a string before using it.
      local data = self.saci:deflate(node_module.NODE)
      local node = self.saci:make_node(data, id)
      assert(node)
      -- For some nodes, we want to immediately save a copy to saci.
      if node_module.CREATE_DEFAULT then
         node = self:save_node(node, nil)
         node = self.saci:get_node(id)
      end
      return node
   else
      return nil
   end
end


-----------------------------------------------------------------------------
-- Decorates a node with a bunch of Sputnik-specific utility functions. Most
-- of those are convenient accessors and setters. See also activate_node().
-----------------------------------------------------------------------------
function Sputnik:decorate_node(node)
   -- Set the markup module for the node. If node's "markup_module" field is
   -- set, use that. (This way different modules can use different markup
   -- modules, inheriting them from prototypes.) Otherwise use the default.
   local markup_module_name
   if node.markup_module and node.markup_module:len() > 0 then
      markup_module_name = "sputnik.markup."..node.markup_module
   else
      markup_module_name = self.config.MARKUP_MODULE or DEFAULT_MARKUP_MODULE
   end
   local markup_module = require(markup_module_name)
   node.markup = markup_module.new(self)

   -- Add methods to post error messages, notices, etc. Those become
   -- post_error(), post_warning(), etc.
   node.messages = {}
   for i, class in ipairs{"error", "warning", "success", "notice"} do
      node["post_"..class] = function(self, message) 
         table.insert(self.messages, {message=message, class=class})
      end
      node["post_translated_"..class] = function(self, key, details) 
         local message = self.translator.translate_key(key)
         if details then
            message = message.." ("..details..")"
         end
         table.insert(self.messages, {message=message, class=class})
      end
   end

   -- Create a table for storing headers and add a function to add headers to it.
   node.headers = {}
   node.add_header = function(self, header, value) self.headers[header] = value end

   -- Create a table for storing cookies and add a function to add cookies to it.
   -- The key of the cookie table should be the name of the cookie, while the
   -- value should be the value of the cookie, or the value false, in which
   -- case the cookie is deleted.

   node.cookies = {}
   node.set_cookie = function(self, name, value) self.cookies[name] = value end

   -- Add a function for redirecting. ::TODO:: check if this is used.
   node.redirect = function(node_self, url)
      node_self.headers["Location"] = url
   end

   -- Add a function allowing for custom status codes (such as 404)
   node.setstatus = function(node_self, status)
      node_self.status = status
   end
   
   -- Add tables and functions for CSS and Javascript.
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
   local sputnik = self
   function node:make_post_form(args, cfields, cfield_names)
      local post_timestamp = os.time()
      local post_token = sputnik.auth:timestamp_token(post_timestamp)
      local args = { 
               field_spec = args.field_spec,
               templates  = self.templates, 
               translator = self.translator,
               values     = args.values,
               insert_hidden_fields = args.insert_hidden_fields,
               extra_fields = args.extra_fields,
               post_token = post_token,
               post_timestamp = post_timestamp,
               hash_fn    = function(field_name)
                               return sputnik:hash_field_name(field_name, post_token)
                            end
            }
      local html_for_fields, field_list = html_forms.make_html_form(args, cfields, cfield_names)

      return {
               post_timestamp = post_timestamp,
               post_token = post_token,
               html_for_fields = html_for_fields,
               field_list = field_list
      }
   end

   return node
end  

-----------------------------------------------------------------------------
-- Decorates the node with yet more fuction. This is similar to
-- decorate_node() in spirit and the two perhaps should be merged. ::TODO::
-- (The main difference between the two is that activate_node() is more
-- expensive.)
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
      if type(action_function) == "function" then
         node.actions[command] =  action_function
      elseif type(action_function) == "string" then
         local mod_name, dot_action = action_function:match("^(.+)%.([^%.]+)$")
         node.actions[command] = action_loader.load(mod_name)[dot_action]
      end
   end

   -- set wrappers -----------------------------------------------------
   node.wrappers = self.wrappers
   
   return node
end


-----------------------------------------------------------------------------
--- Updates a node with values from a table.
-----------------------------------------------------------------------------
function Sputnik:update_node_with_params(node, params)
   node:update(params, node.fields)
   --new_node.name = node.name
   self:decorate_node(node)
   return node
end


-----------------------------------------------------------------------------
-- Saves the node. This is a wrapper for node:save(...) that respects node's
-- save_hook field. This field defines a module and function name that are
-- called when the node is being saved, allowing for last minute changes
-- to the node parameters, or for other actions to be taken alongside
-- the save.
--
-- NODE: A save hook is passed the node, the request object and the sputnik
-- instance, although request and sputnik are not guaranteed to be available
-- for certain types of nodes.
-----------------------------------------------------------------------------
function Sputnik:save_node(node, request, ...)
   local new_node = node
   if type(node.save_hook) == "string" and #node.save_hook > 0 then
      local mod_name, func_name = node.save_hook:match("^(.+)%.([^%.]+)$")
      local module = require("sputnik.hooks." .. mod_name)
      local save_hook = module[func_name]
      new_node = save_hook(node, request, self)
   end
   -- Actually perform the save at the saci layer
   new_node:save(...)
   return new_node
end


-----------------------------------------------------------------------------
-- Returns the history of a node.
--
-- This needs to be refactored. ::TODO::
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
--
-- This needs to be refactored. ::TODO::
-----------------------------------------------------------------------------
function Sputnik:get_complete_history(limit, date_prefix, id_prefix)
   local history = self.saci:get_complete_history(id_prefix, date_prefix, limit)
   local new_history = {}
   for i, v in ipairs(history) do
      local id = v.id:sub(0,8)
      if id~="sputnik/" then
         table.insert(new_history, v)
      end
   end
   return new_history
end

-----------------------------------------------------------------------------
-- Returns a list of all node ids.
--
-- This needs to be rethought. ::TODO::
-----------------------------------------------------------------------------
function Sputnik.get_node_names(self, args)
   return self.saci.versium:get_node_ids(args and args.prefix or nil,
                                         args and args.limit or nil)
end


-----------------------------------------------------------------------------
-- Checks if a node with the given ID exists.
--
-- "Exists" is not a well defined concept for Sputnik nodes, however, because
-- there are several layers of fallbacks. Perhaps we should just get rid of
-- this method. ::TODO::
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
   local node_name = self.config.ADMIN_NODE_PREFIX .. "_uid:" .. namespace
   local node = self:get_node(node_name)
   node = self:update_node_with_params(node, {content=hash, prototype="@UID"})
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




--=========================================================================--
--   GENERATING URLS
--=========================================================================--


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
   local url, node
   local params = params or {}

   -- interwiki urls
   if interwiki_handler then
      -- first the node name
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

      -- then the action
      if action and action~="show" then
         url = url.."."..action
      elseif dirified == self.config.HOME_PAGE then
         url = self.config.HOME_PAGE_URL
      end

   else
      -- concatenate the action to the node_name
      if action and action ~= "show" then
         node = dirified.."."..action
      else
         node = dirified
      end

      -- url without query string
      if self.config.USE_NICE_URL then
         url = self.config.BASE_URL..node
      else
         url = self.config.BASE_URL
         params["p"] = node
      end

      -- encode query string and create url
      url = url .. wsapi.request.methods:qs_encode(params)
   end


   -- finally add the anchor
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
   local url = self:make_url(node_name, action, params, anchor)
   self.logger:debug("Creating a link to "..node_name)
   if options.mark_missing and not self:node_exists(node_name) then
      return string.format('href="%s" class="no_such_node"', url)
   else
      return string.format('href="%s"', url, css_class)
   end
end


-----------------------------------------------------------------------------
-- Returns a small icon to represent a given user.
--
-- @param user           username
-- @return               a url of an icon
-----------------------------------------------------------------------------
function Sputnik:get_user_icon(user)
   -- First, check if already have an icon for this user
   self.user_icon_hash = self.user_icon_hash or {}
   if self.user_icon_hash[user] then
      return self.user_icon_hash[user]
   end
   
   -- Start with a generic icon
   local icon = self:make_url("icons/user", "png")

   -- See if we can be more specific than that
   if not user or user:len()==0 then -- the anonymous user case
      icon = self:make_url("icons/anon", "png")
   elseif user=="admin" or user=="Admin" then -- the anonymous user case
      icon = self:make_url("icons/admin", "png")
   elseif user=="Sputnik-UID" or user=="Sputnik" then
      icon = self:make_url("icons/system", "png") 
   elseif self.config.USE_GRAVATAR then -- map email to gravatar?
      local email
      if self.auth:user_exists(user) then
         email = self.auth:get_metadata(user, "email")
      end
      if not email and user:match("@") then
         email = user
      end
      if email then
         icon = "http://www.gravatar.com/avatar/"..md5.sumhexa(email)
                .."?s=22&d="..sputnik.util.escape_url(icon)
      end
   end
   icon = self:escape(icon)
   self.user_icon_hash[user] = icon
   return icon
end




--=========================================================================--
--   MISCELLANEA
--=========================================================================--


-----------------------------------------------------------------------------
-- Asserts that a specific configuration parameter is set, throws a message
-- if it's not.
-----------------------------------------------------------------------------
function Sputnik:assert_config(param, message)
   assert(self.config[param], "Config parameter "..param.." must be set"
                              ..(message or "."))
end


-----------------------------------------------------------------------------
-- Turns text into something that can be used as a node name.
-----------------------------------------------------------------------------
function Sputnik:dirify(text)
   -- Turns a string into something that can be used as a node name.
   return (self.config.DIRIFY_FN or sputnik.util.dirify)(text)
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
-- Returns a url of the user's profile node or nil
-----------------------------------------------------------------------------
function Sputnik:make_link_to_user(user)
   if self.config.USE_USER_NODES and user then
      local prefix = self.config.USER_NODE_PREFIX or "people/"
      return self:make_link(prefix..user)
   end
end

-----------------------------------------------------------------------------
-- Sends email on Sputnik's behalf.
-----------------------------------------------------------------------------
function Sputnik:sendmail(args)
   if self.config.EMAIL_TEST_MODE then
      print("\nTo: "..args.to.."\nFrom: "..args.from.."\nSubject: "..args.subject)
      print("\n"..(args.body or "").."\n")
      return 1
   else
      return sputnik.util.sendmail(args, self)
   end
end


-- vim:ts=3 ss=3 sw=3 expandtab
