module(..., package.seeall)

require("md5")
require("cosmo")
require("saci")
require("sputnik.actions.wiki")
require("sputnik.i18n")
require("sputnik.util")

---------------------------------------------------------------------------------------------------
-- THE SPUTNIK CLASS  -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
---------------------------------------------------------------------------------------------------
local Sputnik = {}
local Sputnik_mt = {__metatable = {}, __index = Sputnik}

---------------------------------------------------------------------------------------------------
-- Creates a new instance of Sputnik.
---------------------------------------------------------------------------------------------------
function new(config)
   -- Set up default configuration variables
   config = config or {}
   config.ROOT_PROTOTYPE = config.ROOT_PROTOTYPE or "@Root"
   config.SECRET_CODE = config.SECRET_CODE or "23489701982370894172309847123"
   config.CONFIG_PAGE_NAME = config.CONFIG_PAGE_NAME or "_config"
   config.PASS_PAGE_NAME = config.PASS_PAGE_NAME or "_passwords"
   --config.LOGGER = config.LOGGER or "file"
   --config.LOGGER_PARAMS = config.LOGGER_PARAMS or {"/tmp/sputnik-log.log", "%Y-%m-%d"}

   -- Create and return the new initialized Sputnik instance
   local obj = setmetatable({}, Sputnik_mt)
   obj:init(config)
   return obj
end

function new_wsapi_run_fn(config)
   local my_sputnik = new(config)
   return  function (...)
     return my_sputnik:wsapi_run(...)
   end
end

---------------------------------------------------------------------------------------------------
-- Initializes a the new Sputnik instance.
---------------------------------------------------------------------------------------------------
function Sputnik:init(initial_config)
   -- setup the logger -- do this before loading user configuration
   if initial_config.LOGGER then
      require("logging."..initial_config.LOGGER)
      self.logger = logging[initial_config.LOGGER](unpack(initial_config.LOGGER_PARAMS))
   else
      self.logger = {
         debug = function(self, level, message) end, -- do nothing
         info = function(self, level, message) end,
         error = function(self, level, message) end,
      }
   end

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

   self.repo.get_fallback_node = function(repo, id, version)
      local status, page_module = pcall(require, "sputnik.node_defaults."..id)

      if not status then
         -- Attempt to escape the node_id using basic filesystem rules
         local esc_id = id:gsub("%%", "%%25"):gsub(":", "%%3A"):gsub("/", ".")
         status, page_module = pcall(require, "sputnik.node_defaults."..esc_id)
      end

      if status then
         local data = self.repo:deflate(page_module.NODE)
         local node = self.repo:make_node(data, id)
         assert(node)
         if page_module.CREATE_DEFAULT then
            node:save()
            node = self.repo:get_node(id)
         end
         return node
      else
         return self.repo:make_node("", id), true -- set stub=true
      end
   end

   assert(self.repo)
   self.repo.logger = self.logger 

   -- WARNING ------------------------------------------------------------------------
   -- Up to now we were using "initial_config" which is loaded from sputnik/config.lua
   -- We are now going to load values from the configuration node.  This means that
   -- the config values can no longer be trusted.
   
   self.config = initial_config
   initial_config = nil -- just to keep us honest

   local config_node = self:get_node(self.config.CONFIG_PAGE_NAME)
   assert(config_node, "Failed to retrieve the config node "..tostring(self.config.CONFIG_PAGE_NAME))
   assert(type(config_node)=="table")
   for k,v in pairs(config_node.content) do
      self.config[k] = v
   end

   -- setup markup

   self.markup_module = require(self.config.MARKUP_MODULE or "sputnik.markup.markdown")
   self.markup = self.markup_module.new(self)

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

   -- setup captcha

   if self.config.CAPTCHA_MODULE then
      local captcha_mod = require(self.config.CAPTCHA_MODULE)
      self.captcha = captcha_mod.new(self.config.CAPTCHA_PARAMS)
   end
      
   -- setup authentication
   local auth_mod = require(self.config.AUTH_MODULE or "sputnik.authentication.simple")
   self.auth = auth_mod.new(self, self.config.AUTH_MODULE_PARAMS)
   
   -- setup wrappers
   self.wrappers = sputnik.actions.wiki.wrappers -- same for "wiki" wrappers      
end


--- Returns a small icon for this user.
function Sputnik:get_user_icon(user)
   if not user or user:len()==0 then
      return self:make_url("icons/anon", "png")
   elseif user=="admin" or user=="Admin" then 
      return self:make_url("icons/admin", "png")
   elseif user=="Sputnik-UID" or user=="Sputnik" then
      return self:make_url("icons/system", "png") 
   elseif self.auth:user_exists(user) then
      local email = self.auth:get_metadata(user, "email")
      if email and self.config.USE_GRAVATAR then 
         return "http://www.gravatar.com/avatar/"..md5.sumhexa(email)
                .."?s=16&d=http://"
                ..self.config.DOMAIN..self:make_url("icons/user", "png")
      end
   end
   return self:make_url("icons/user", "png")
end

--- Escapes a text for using in a textarea.
function Sputnik.escape(self, text) return sputnik.util.escape(text) end
--- Escapes a URL.
function Sputnik.escape_url (self, text) return sputnik.util.escape_url(text) end

function Sputnik:node_exists(id)
   id = self:dirify(id)
   return self.repo:node_exists(id) or pcall(require, "sputnik.node_defaults."..id)
end

---------------------------------------------------------------------------------------------------
--- Makes a URL from a table of parameters.
---------------------------------------------------------------------------------------------------
function Sputnik:make_url(node_name, action, params, anchor)
   node_name = self:dirify(node_name)
   if action and action~="show" then 
      node_name = node_name.."."..action
   end
   if anchor then
      anchor = "#"..anchor
   else
      anchor = ""
   end
   if params and next(params) then
      local link = self.config.BASE_URL.."?p="..node_name
      for k, v in pairs(params or {}) do
         link = link.."&"..k.."="..(v or "")
      end
      return self:escape(link..anchor)
   else
      return self:escape(self.config.NICE_URL..node_name..anchor)
   end   
end

---------------------------------------------------------------------------------------------------
--- Makes a link from a table of parameters.
---------------------------------------------------------------------------------------------------
function Sputnik:make_link(node_name, action, params, anchor, options)
   assert(node_name)
   options=options or {}
   if node_name:find("%.") then -- allow for the action to be passed attached to the node name
      node_name, action = node_name:match("(.+)%.(.+)")
   end
   local css_class = "local"
   local url = self:make_url(node_name, action, params, anchor)
   self.logger:debug("Creating a link to "..node_name)
   if (not options.do_not_highlight_missing) and (not self:node_exists(node_name)) then
      css_class="no_such_node"
      url = self:make_url(node_name, action, params, anchor) --"edit", params, anchor)
      self.logger:debug("No such node, will link to .edit")
   end
   return string.format("href='%s' class='%s'", url, css_class)
end

---------------------------------------------------------------------------------------------------
--- Does a bit of extra activation beyond what SACI does.
---------------------------------------------------------------------------------------------------
function Sputnik:activate_node(node, params)

   -- setup the page-specific translator
   for i, translation_node in ipairs(node.translations) do
      local translations = self:get_node(translation_node).content
      assert(type(translations) == "table", "the translation node should load and evaluate into a table")
      for k, translation in pairs(translations) do
         node.translations[k] = translation
      end
    end
    node.translator = sputnik.i18n.make_translator(node.translations, self.config.INTERFACE_LANGUAGE)
    
   -- translate the templates
   for i, template_node in ipairs(node.templates) do
      local templates = self:get_node(template_node).content
      assert(type(templates) == "table", "the template node should load and evaluate into a table")
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
   
   for k, v in pairs(node.actions) do
      local mod_name, dot_action = sputnik.util.split(v, "%.")
      node.actions[k] = action_loader.load(mod_name)[dot_action]
   end
   
   -- create a function to check permissions ---------------------------
   node.check_permissions = function(node, user, action)
      local all_users = {}
      local all_actions = {}
      local has_permission = true

      -- This function handles toggling the actual allow state
      local function set(suser, saction, svalue)
         local is_user, is_action

         -- Resolve the user side of the permission
         if type(suser) == "function" then
            is_user = suser(user, self.auth)
         else
            is_user = (suser == user) or (suser == all_users)
         end

         -- Resolve the action
         if type(saction) == "function" then
            is_action = saction(action)
         else
            is_action = (saction == action) or (saction == all_actions)
         end

         if is_user and is_action then
            has_permission = svalue
         end
      end

      local function allow(suser, saction) 
         set(suser, saction, true)
      end
      local function deny(suser, saction)
         set(suser, saction, false)
      end
      if node.permissions then
         local sandbox = {
            all_users = all_users,
            all_actions = all_actions,
            allow = function(suser, saction)
               set(suser, saction, true)
            end,
            deny = function(suser, saction)
               set(suser, saction, false)
            end,
            Authenticated = function(user, auth)
               return user ~= nil
            end,
            Anonymous = function(user, auth)
               return not user
            end,
            Admin = function(user, auth)
               if user then
                  return auth:get_metadata(user, "is_admin") == "true"
               else
                  return false
               end
            end,
         }
         local func = assert(loadstring(node.permissions))
         setfenv(func, sandbox)
         local succ,err = assert(pcall(func))
      end

      return has_permission
   end     
   
   -- set wrappers -----------------------------------------------------
   node.wrappers = self.wrappers
   
   return node
end

---------------------------------------------------------------------------------------------------
-- Returns the node with this name (without additional activation).
---------------------------------------------------------------------------------------------------
function Sputnik:get_node(id, version, mode)
   local node, stub = self.repo:get_node(id, version)
   
   node.name = id
   if not node.title then
      local temp_title = string.gsub(node.name, "_", " ")
      node.title = temp_title
      node.raw_values.title = temp_title
   end
   if mode~="basic" then
      self:prime_node(node)
   end
   return node, stub
end

---------------------------------------------------------------------------------------------------
-- Adds extra sputnik-specific fields to a node.
---------------------------------------------------------------------------------------------------
function Sputnik:prime_node(node)
   node.markup = self.markup
   self:add_urls(node)
   self:add_links(node)
   node.messages = {}
   for i, class in ipairs{"error", "warning", "success", "notice"} do
      node["post_"..class] = function(self, message) table.insert(self.messages, {message=message, class=class}) end
   end
   -- Table/Function that allow the developer to add custom HTML response headers
   node.headers = {}
   node.add_header = function(self, header, value) self.headers[header] = value end
   node.redirect = function(self, url) self.headers["Location"] = url end

   node.stylesheets = {}
   node.javascript = {}
   function node:add_stylesheet(href, media, src)
      media = media or "screen"
      -- Scan the current table to ensure there are no duplicates
      for k,v in ipairs(self.stylesheets) do
         if href == v.href and media == v.media and src == v.src then
            return
         end
      end
      table.insert(self.stylesheets, {href = href, src = src, media = media})
   end
   function node:add_javascript(href, src)
      -- Scan the current table to ensure there are no duplicates
      for k,v in ipairs(self.stylesheets) do
         if href == v.href and src == v.src then
            return
         end
      end
      table.insert(self.javascript, {href = href, src = src})
   end
   return node
end  

---------------------------------------------------------------------------------------------------
-- Makes node.urls:foo(params) equivalent to sputnik:make_url(node.name, "foo", 
-- params) for ANY foo.
---------------------------------------------------------------------------------------------------
function Sputnik:add_urls(node)
   node.urls = { __index = function(table, key)
                              return function(inner_self, params)
                                 return self:make_url(node.name, key, params,
                                                      nil, {do_not_highlight_missing=true})
                              end
                           end
               }
   setmetatable(node.urls, node.urls)
   return node
end

---------------------------------------------------------------------------------------------------
-- Makes node.links:foo(params) equivalent to sputnik:make_link(node.name, "foo", params) for ANY 
-- foo.
---------------------------------------------------------------------------------------------------
function Sputnik:add_links(node)
   node.links = { __index = function(table, key)
                               return function(inner_self, params)
                                  return self:make_link(node.name, key, params,
                                                        nil, {do_not_highlight_missing=true})
                               end
                            end
                }
   setmetatable(node.links, node.links)
   return node
end

---------------------------------------------------------------------------------------------------
-- Generates a node-like table to make urls.
---------------------------------------------------------------------------------------------------
function Sputnik.pseudo_node(self, node_name)
   local node = {name = node_name }
   self:add_urls(node)
   self:add_links(node)
   return node
end

---------------------------------------------------------------------------------------------------
--- Updates node with values from params table.
---------------------------------------------------------------------------------------------------
function Sputnik:update_node_with_params(node, params)
   node:update(params, node.fields)
   --new_node.name = node.name
   self:prime_node(node)
   return node
end

---------------------------------------------------------------------------------------------------
-- Returns node's history.
---------------------------------------------------------------------------------------------------
function Sputnik:get_history(node_name, limit, date)
   local edits = self.repo:get_node_history(node_name, date)  -- limit discarded for now
   if limit then 
      for i=limit, #edits do
         table.remove(edits, i)
      end
   end
   return edits
end

---------------------------------------------------------------------------------------------------
-- Returns history for all nodes.
---------------------------------------------------------------------------------------------------
function Sputnik:get_complete_history(limit, date)
   local edits = {}
   for i, id in ipairs(self:get_node_names()) do
      local node = Sputnik.pseudo_node(self, id)
      node.id = id
      for i, edit in ipairs(self:get_history(id, limit, date)) do
         edit.id = id
         edit.node = node
         table.insert(edits, edit)
      end
   end
   table.sort(edits, function(e1, e2) return e1.timestamp > e2.timestamp end)
   if limit then
      local another_table = {}
      for i=1,limit do
         table.insert(another_table, edits[i])
      end
      edits = another_table
   end   
   return edits
end

---------------------------------------------------------------------------------------------------
-- Returns a list of all node ids.
---------------------------------------------------------------------------------------------------
function Sputnik.get_node_names(self, args)
   local prefix = args and args.prefix or nil
   local limit = args and args.limit or nil
   local node_ids = self.repo.versium:get_node_ids(prefix, limit) -- reaching deep
   return node_ids
end

---------------------------------------------------------------------------------------------------
-- Generates a hash for a POST field name.
---------------------------------------------------------------------------------------------------
function Sputnik:hash_field_name(field_name, token)
   return "field_"..md5.sumhexa(field_name..token..self.config.SECRET_CODE)
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
   node:save("Sputnik-UID", hash)

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

------------------------------------------------------------------
-- Generates a new node name by calling string.format on the 
-- given string with a UID as the argument.
--
-- @param sputnik the sputnik instance to use when generating
-- @param namespace a namespace idenfier string ["sputnik"]
-- @param type the type of uid to generate ("hash" or "number") ["number"]
-- @param format the format to be used when constructing the new name
-- @usage gen_name(sputnik, "forums", "number", "forums/general/%d")
-- could generate the string "forums/general/42" depending on the
-- state of the system.  This name will be unique to the namespace
-- "forums".
-- @return uid a unique identifier for the given namespace

function Sputnik:gen_name(namespace, type, format)
   local uid = self:get_uid(namespace, type)
   return format:format(uid)
end


-----------------------------------------------------------------------------
-- Sends email on Sputnik's behalf.
-----------------------------------------------------------------------------
function Sputnik:sendmail(args)
   return sputnik.util.sendmail(args, self)
end

---------------------------------------------------------------------------------------------------
-- Pre-processes CGI parameters and does authentication.
---------------------------------------------------------------------------------------------------
function Sputnik:translate_request (request)
   if request.method=="POST" then
      request.params = request.POST or {}
   else
      request.params = request.GET or {}
   end

   -- For a post action we'll need to unhash the parameters first.  Note that we don't care if the 
   -- action was actually submitted via get or post: if an idempotent request was sent via POST,
   -- that's ok.  Instead, we divide actions into two types: those that were submitted with a post
   -- token and those that were submitted without.  Requests submitted with a post token are
   -- allowed to make changes to the state of the wiki.  They get their fields unhashed.  This
   -- means that if an action is submitted with a post token but its fields are not hashed, it will
   -- be processed as if submitted with no arguments.
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
         new_params[name] = request.params[self:hash_field_name(name, request.params.post_token)] or ""
         --self.logger:debug(new_params[name])
      end
      new_params.p = request.params.p
      new_params.post_token = request.params.post_token
      new_params.post_timestamp = request.params.post_timestamp
      request.params = new_params
   end
   
   -- break "p" parameter into node name and the action
   if request.params.p then
      request.node_name, request.action = sputnik.util.split(request.params.p, "%.")
   else
      request.node_name = self.config.HOME_PAGE 
   end
   request.node_name = request.node_name:gsub("/$", "") -- remove the trailing slash
   request.action = request.action or "show"


   self.logger:debug("login")
   -- now login/logout/register the user
   if request.params.logout then 
      self.logger:debug("logout")
      request.user = nil
   elseif (request.params.user or ""):len() > 0 then
      self.logger:debug("knock knock: "..request.params.user)
      request.user, request.auth_token = self.auth:authenticate(request.params.user, request.params.password)
      if not request.user then
         request.auth_message = "INCORRECT_PASSWORD"
      else
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

---------------------------------------------------------------------------------------------------
-- Handles a request.
---------------------------------------------------------------------------------------------------
function Sputnik:run(request, response)
   self.cookie_name = "Sputnik_"..md5.sumhexa(self.config.BASE_URL)
   request = self:translate_request(request)

   local node, stub = self:get_node(request.node_name, request.params.version)
  
   if stub and self.config.PROTOTYPE_PATTERNS then
      -- If an empty stub was returned, check the PROTOTYPE_PATTERNS table to see
      -- if we should apply a prototype
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
      content,content_type = sputnik.actions.wiki.actions.action_not_found(node, request, self)
   else
      -- Check permissions on the node, for the given action
      if node:check_permissions(request.user, action) then
         -- Determine if there are any hooks to be called for this action, on this node
         -- by checking the node.action_hooks table
         if node.action_hooks and node.action_hooks[action] then
            local hooks = node.action_hooks[action].before
            if hooks then
               for idx, hook in ipairs(hooks) do
                  local mod_name, dot_action = sputnik.util.split(hook, "%.")
                  local mod = require("sputnik.actions." .. mod_name)
                  if mod and mod.actions and mod.actions[dot_action] then
                     pcall(mod.actions[dot_action], node, request, sputnik)
                  end
               end
            end
         end

         content, content_type = action_function(node, request, self)
         self.logger:info(self.cookie_name.."=".. ((request.user or "").."|"..(request.auth_token or "")))

         -- Handle any action hooks at this point, with no digging for post actions
         -- If you want to hook a post action, you need to iterate the parameters 
         -- to determine which action is actually being called
         if node.action_hooks and node.action_hooks[action] then
            local hooks = node.action_hooks[action].after
            if hooks then
               for idx, hook in ipairs(hooks) do
                  local mod_name, dot_action = sputnik.util.split(hook, "%.")
                  local mod = require("sputnik.actions." .. mod_name)
                  if mod and mod.actions and mod.actions[dot_action] then
                     pcall(mod.actions[dot_action], node, request, sputnik)
                  end
               end
            end
         end
      else
         -- The user did not have permission, so give a message stating this
         node:post_error("Sorry, that action is not allowed")
         node.inner_html = ""
         content, content_type = node.wrappers.default(node, request, self)
      end
   end

   assert(content)
   response.headers["Content-Type"] = content_type or "text/html"

   -- If we have any custom HTML headers, add them to the response
   for header,value in pairs(node.headers) do
      response.headers[header] = value
   end

   local cookie_value = (request.user or "").."|"..(request.auth_token or "")
   response:set_cookie(self.cookie_name, {value=cookie_value, path="/"})
   response:write(content)
   return response
end

---------------------------------------------------------------------------------------------------
-- Handles a request, throwing errors if something goes wrong.
---------------------------------------------------------------------------------------------------
function Sputnik:unprotected_run(request, response)
   return self:run(request, response)
end


---------------------------------------------------------------------------------------------------
-- Handles a request safely.
---------------------------------------------------------------------------------------------------
function Sputnik:protected_run(request, response)
   local function mypcall(fn, ...)
      local params = {...} -- this is to keep the inner function from being confused
      return xpcall(function()  return fn(unpack(params)) end,
                    function(err) return {err, require("debug").traceback()} end )
   end  

   local success, err = mypcall(self.unprotected_run, self, request, response)
   if success then
      return success
   else
      local message = "Sputnik ran but failed due to an unexpected error." -- ::LOCALIZE::

      -- catch some common errors
      local dummy, path = string.match(err[1], "Versium storage error: (.*) Can't open file: (.*) in mode w")
      local dir = self.config.VERSIUM_PARAMS.dir
      if path and path:sub(1, dir:len()) == dir then
         message = "Versium's data directory ("..dir
                   ..") is not writable.<br/> Please fix directory permissions." -- ::LOCALIZE::
      end

      return success, string.format([[
       <br/>
       <span style="color:red; font-size: 19pt;">%s</span></br><br/><br/>
       Error details: <b><code>%s</code></b><br/>
       <pre><code>%s</code></pre>
      ]], message, err[1], err[2])
   end
end

---------------------------------------------------------------------------------------------------
-- Handles a request coming from WSAPI
---------------------------------------------------------------------------------------------------

function Sputnik:wsapi_run(wsapi_env)

   _G.format = string.format -- to work around a bug in wsapi.response

   require("wsapi.request")
   local request = wsapi.request.new(wsapi_env)
   request.wsapi_env = wsapi_env
   require("wsapi.response")
   local response = wsapi.response.new()
   local success, error_message = self:protected_run(request, response)
   if not success then
      response = wsapi.response.new()
      response:write(error_message)
   end

   -- Change the HTTP status code to 302 is a location header is set
   if response.headers["Location"] then
      if response.status < 300 then
         response.status = 302
      end
   end

   return response:finish()
end

-- vim:ts=3 ss=3 sw=3 expandtab
