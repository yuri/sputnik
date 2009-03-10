module(..., package.seeall) --sputnik.authentication.simple

-----------------------------------------------------------------------------
-- This is the reference implementation for an authentication module,
-- implementing all of the core functionality that Sputnik will expect from
-- a drop-in-replacement
-----------------------------------------------------------------------------

local errors = require("sputnik.auth.errors")

local Simple = {}
local Simple_mt = {__metatable = {}, __index = Simple}

-- Utility functions
local function load_users(sputnik, name)
   local node = sputnik:get_node(name)
   return node.content.USERS, node.raw_values.content
end

local function get_salted_hash(time, salt, password)
   return md5.sumhexa(time .. salt .. password)
end

local function user_token(user, salt, hash)
   return md5.sumhexa(user .. salt .. "Sputnik")
end

-----------------------------------------------------------------------------
-- Creates a new instance of the authentication module for use in Sputnik
--
-- @param sputnik        a sputnik instance to use for storage .
-- @param params         a table of configuration paramaters (the actual set
--                       of parameters is implementation-specific.
-----------------------------------------------------------------------------
function new(sputnik, params)
   -- Set up default parameters
   params = params or {}
   params.node = params.node or "sputnik/passwords"
   params.password_salt = params.password_salt or sputnik.config.PASSWORD_SALT
   params.token_salt = params.token_salt or sputnik.config.TOKEN_SALT
   params.recent = params.recent or (14 * 24 * 60 * 60)

   local obj = setmetatable({}, Simple_mt)
   obj.sputnik = sputnik
   obj.node = params.node
   obj.password_salt = params.password_salt
   obj.token_salt = params.token_salt
   obj.noauto = params.NO_AUTO_REGISTRATION
   obj.recent = params.recent
   obj.users = load_users(obj.sputnik, obj.node)
   return obj
end

------------------------------------------------------------------
-- Returns whether or not a given username exists in the 
-- authentication system, without any further information
--
-- @param username the username to query
-- @return exists whether or not the username exists in the system

function Simple:user_exists(username)
   if type(username) ~= "string" then return false end
   username=username:lower()
   return type(self.users[username]) == "table"
end

------------------------------------------------------------------
-- Returns a token for the specified timestamp.  This is provided
-- for use outside the authentication system
--
-- @param timestamp - the timestamp to use when generating token
-- @return token a hashed token representing the given timestamp

function Simple:timestamp_token(timestamp)
   return md5.sumhexa(timestamp .. self.token_salt)
end

------------------------------------------------------------------
-- Attempt to authenticate a given user with a given password
--
-- @param user the username to authenticate
-- @param password the raw password to authenticate with
-- @return user the name of the authenticated user
-- @return token a hashed token for the user

function Simple:authenticate(username, password)
   username = username:lower()
   local entry = self.users[username]

   if entry then
      local hash = get_salted_hash(entry.creation_time, self.password_salt, password)
      if hash == entry.hash then 
         return entry.display, user_token(username, self.token_salt, entry.hash)
      else
         return nil, errors.wrong_password(username)
      end
   else
      return nil, errors.no_such_user(username)
   end
end

------------------------------------------------------------------
-- Validate an existing authentication token.  This is used for 
-- allowing authentication via cookies
--
-- @param user the username the token belong to
-- @param token the actual token hash
-- @return user the name of the authenticated user

function Simple:validate_token(username, token)
   username = username:lower()
   local entry = self.users[username]

   if self:user_exists(username) then
      if user_token(username, self.token_salt, entry.hash) == token then
         return entry.display
      else
         return false, errors.wrong_password(username)
      end
   else
      return false, errors.no_such_user(username)
   end
end

------------------------------------------------------------------
-- Returns whether or not a given user is a new user, defined
-- by the "recent" configuration parameter.
-- @param user the username to query
-- @return isRecent a boolean value indicating if the user's 
-- account was created in the specified time frame

function Simple:user_is_recent(username)
   username = username:lower()
   local entry = self.users[username]

   if entry then
      local now = os.time()
      local min = now - self.recent

      return (tonumber(entry.creation_time) > min)
   else
      return nil, errors.no_such_user(username)
   end
end

------------------------------------------------------------------
-- Adds a user/password pair to the password file
--
-- @param user the username to add
-- @param password the raw password
-- @return success a boolean value indicating if the add was 
-- successful.
-- @return err an error message if the add was not successful
function Simple:add_user(username, password, metadata)

   local now = os.time()
   local users, raw_users = load_users(self.sputnik, self.node)
  
   if self:user_exists(username) then
      return nil, user_already_exist(username)
   end

   metadata = metadata or {}
   metadata.creation_time = now
   metadata.display = username
   metadata.hash = get_salted_hash(now, self.password_salt, password)
   username = username:lower()
   if username == "admin" then
      metadata.is_admin = "true"
   end

   users[username] = metadata

   local user_as_string = string.format("USERS[%q]={", username)
   for k,v in pairs(metadata) do
      user_as_string = user_as_string..string.format(" %s=%q,", k, v)
   end
   user_as_string = user_as_string.."}"

   local password_node = self.sputnik:get_node(self.node)

   local params = {
      content = (raw_users or "USERS={}\n").."\n"..user_as_string,
   }
   password_node = self.sputnik:update_node_with_params(password_node, params)
   password_node = self.sputnik:save_node(password_node, nil, username,
      "Added new user: " .. username, {minor="yes"})
   self.users = load_users(self.sputnik, self.node)
   return true
end

-----------------------------------------------------------------------------
-- Retrieves a piece of metadata for a specific user
--
-- @param username       the username to query
-- @param key            the metadata key to query
-- @return data          the value of the metadata or nil
function Simple:get_metadata(username, key)
   if not username or username=="" then return nil end
   username=username:lower()
   if self.users[username] then 
      return self.users[username][key]
   else
      return errors.no_such_user(username)
   end
end
  
-- vim:ts=3 ss=3 sw=3 expandtab
