module(..., package.seeall)

--[[--------------------------------------------------------------
--  sputnik.authentication.simple
--
--  This is the reference implementation for an authentication
--  module.  It implements all of the core functionality that
--  sputnik will expect from a drop-in-replacement
--------------------------------------------------------------]]--

local PASSWORD_TEMPLATE = [=[USERS = {}
$do_users[[USERS["$user"]={hash="$hash", time="$time"}
]]]=]

local Simple = {}
local Simple_mt = {__metatable = {}, __index = Simple}

-- Utility functions
local function load_users(sputnik, name)
   local node = sputnik:get_node(name)
   return node.content.USERS
end

local function get_salted_hash(time, salt, password)
   return md5.sumhexa(time .. salt .. password)
end

local function user_token(user, salt, hash)
   return md5.sumhexa(user .. salt .. "Sputnik")
end

------------------------------------------------------------------
-- Creates a new instance of the authentication module for use
-- in sputnik
--
-- @param sputnik the sputnik instance to use for storage
-- @param params a table of configuration paramaters.  The
-- requirements of this table depend on the specific module
-- implementation.
function new(sputnik, params)
   -- Set up default parameters
   params = params or {}
   params.node = params.node or "_passwords"
   params.salt = params.salt or sputnik.config.SECRET_CODE
   params.recent = params.recent or (14 * 24 * 60 * 60)

   local obj = setmetatable({}, Simple_mt)
   obj.sputnik = sputnik
   obj.node = params.node
   obj.salt = params.salt
   obj.noauto = params.NO_AUTO_REGISTRATION
   obj.recent = params.recent

   return obj
end

------------------------------------------------------------------
-- Returns whether or not a given username exists in the 
-- authentication system, without any further information
--
-- @param username the username to query
-- @return exists whether or not the username exists in the system

function Simple:user_exists(username)
   local users = load_users(self.sputnik, self.node)
   return type(users[username]) == "table"
end

------------------------------------------------------------------
-- Returns a token for the specified timestamp.  This is provided
-- for use outside the authentication system
--
-- @param timestamp - the timestamp to use when generating token
-- @return token a hashed token representing the given timestamp

function Simple:timestamp_token(timestamp)
   return md5.sumhexa(timestamp .. self.salt)
end

------------------------------------------------------------------
-- Attempt to authenticate a given user with a given password
--
-- @param user the username to authenticate
-- @param password the raw password to authenticate with
-- @return user the name of the authenticated user
-- @return token a hashed token for the user

function Simple:authenticate(user, password)
   local users = load_users(self.sputnik, self.node)
   local entry = users[user]

   if entry and entry.hash == get_salted_hash(entry.time, self.salt, password) then
      return user, user_token(user, self.salt, entry.hash)
   elseif self:user_exists(user) or (self.noauto and user ~= "Admin") then
      return nil
   else
      self:add_user(user, password)
      users = load_users(self.sputnik, self.node)
      return user, user_token(user, self.salt, users[user].hash)
   end
end

------------------------------------------------------------------
-- Validate an existing authentication token.  This is used for 
-- allowing authentication via cookies
--
-- @param user the username the token belong to
-- @param token the actual token hash
-- @return user the name of the authenticated user

function Simple:validate_token(user, token)
   local users = load_users(self.sputnik, self.node)
   local entry = users[user]

   if self:user_exists(user) and user_token(user, self.salt, entry.hash) == token then
      return user
   else
      return nil
   end
end

------------------------------------------------------------------
-- Returns whether or not a given user is a new user, defined
-- by the "recent" configuration parameter.
-- @param user the username to query
-- @return isRecent a boolean value indicating if the user's 
-- account was created in the specified time frame

function Simple:user_is_recent(user)
   local users = load_users(self.sputnik, self.node)
   local entry = users[user]

   if entry then
      local now = os.time()
      local min = now - self.recent

      return (tonumber(entry.time) > min)
   else
      return false
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
function Simple:add_user(user, password)
   local now = os.time()
   local users = load_users(self.sputnik, self.node)
  
   if self:user_exists(user) then
      return false, "That user already exists"
   end

   users[user] = {
      hash = get_salted_hash(now, self.salt, password),
      time = now,
   }

   local password_node = self.sputnik:get_node(self.node)
   local params = {
      content = cosmo.f(PASSWORD_TEMPLATE){
         do_users = function()
            for user,entry in pairs(users) do
               cosmo.yield{
                  user = user,
                  hash = entry.hash,
                  time = entry.time,
               }
            end
         end
      }
   }
   password_node = self.sputnik:update_node_with_params(password_node, params)
   password_node:save(user, "Added new user: " .. user, {minor="yes"})
   return true
end
  
-- vim:ts=3 ss=3 sw=3 expandtab
