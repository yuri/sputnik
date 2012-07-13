module(..., package.seeall)

-----------------------------------------------------------------------------
-- Implements Sputnik's authentication API using a LuaSQL database database
-- connection.
-----------------------------------------------------------------------------

local errors = require("sputnik.auth.errors")

local Auth = {}
local Auth_mt = {__metatable = {}, __index = Auth}

local schemas = {}
schemas.user = [[
CREATE TABLE IF NOT EXISTS %s ( 
   username VARCHAR(255) NOT NULL,
   password VARCHAR(255) NOT NULL,
   PRIMARY KEY(username)
);]]
schemas.metadata = [[
CREATE TABLE IF NOT EXISTS %s (
   username VARCHAR(255) NOT NULL,
   name VARCHAR(255) NOT NULL,
   value VARCHAR(255) NOT NULL,
   PRIMARY KEY(username, name)
);]]

-----------------------------------------------------------------------------
-- Creates a new instance of the authentication module for use in sputnik
--
-- @param sputnik        the sputnik instance ties to this specific instance
-- @param params         a table of configuration paramaters.  The below code
--                       shows the possible accepted parameters
-----------------------------------------------------------------------------
function new(sputnik, params)
  	-- Params table accepts the following:
	-- prefix - A string that will be prepended to table names
   -- recent - A time in seconds for which a user is considered recent
	-- connect - A list that is passed to the luasql connection function

   local db_module = params[1]
   local db = require("luasql."..db_module)

   -- Try to connect to the given database
  	local env = db[db_module]()
  	local remaining_params = {}
  	for i = 2, #params do
  	   remaining_params[i-1]=params[i]
  	end
	local con = env:connect(unpack(remaining_params))

	assert(con, errors.initialization_error("Could not connect to the database"))

   params.prefix = params.prefix or "auth_"
   params.recent = params.recent or (14 * 24 * 60 * 60)

   -- Create the new object
	local obj = {
      con = con,
      recent = params.recent,
      db_module = db_module,
      sputnik = sputnik,
   }
	setmetatable(obj, Auth_mt)

	obj.tables = {}

	-- Create the two data tables, if they don't already exist
	local tables = {"user", "metadata"}

	for idx,tbl in ipairs(tables) do
		obj.tables.user = string.format("%suser", params.prefix or "")
		obj.tables.metadata = string.format("%smetadata", params.prefix or "")

      local cmd = obj:prepare(schemas[tbl]:format(obj.tables[tbl]))
      assert(con:execute(cmd))
	end

	-- Pre-build our queries
	obj.queries = {
      USER_EXISTS = string.format("SELECT count(username) FROM %s WHERE username = %%s;", obj.tables.user),
      USER_AUTH = string.format("SELECT count(username) FROM %s WHERE username = %%s and password = %%s;", obj.tables.user),
      USER_PWHASH = string.format("SELECT password from %s WHERE username = %%s;", obj.tables.user),
      GET_META = string.format("SELECT value from %s WHERE username = %%s and name = %%s;", obj.tables.metadata),
      ADD_USER = string.format("INSERT INTO %s (username, password) VALUES (%%s, %%s);", obj.tables.user),
      SET_PASSWORD = string.format("UPDATE %s SET password = %%s where username = %%s;", obj.tables.user),
      ADD_META = string.format("INSERT INTO %s (username, name, value) VALUES (%%s, %%s, %%s);", obj.tables.metadata),
      SET_META = string.format("INSERT INTO %s (username, name, value) VALUES (%%s, %%s, %%s) ON DUPLICATE KEY UPDATE value = %%s;", obj.tables.metadata),
	}

	return obj 
end

-----------------------------------------------------------------------------
-- Prepares a SQL statement using placeholders.
-- 
-- @param statement      the statement to be prepared
-- @param ...            a list of parameters  
-- @return               the prepared statement.
-----------------------------------------------------------------------------
function Auth:prepare(statement, ...)
   local count = select('#', ...)

   if count > 0 then
      local someBindings = {}

      for index = 1, count do
         local value = select(index, ...)
         local type = type(value)

         if type == 'string' then
            if self.db_module=="sqlite3" and value:find("%z") then
               error("sqlite3 cannot store embedded zeros")
            end
            value = "'" .. self.con:escape(value) .. "'"
         elseif type == 'nil' then
            value = 'null'
         else
            value = tostring(value)
         end 

         someBindings[index] = value
      end

      statement = statement:format(unpack(someBindings))
   end

   return statement
end

------------------------------------------------------------------
-- Returns whether or not a given username exists in the 
-- authentication system, without any further information
--
-- @param username the username to query
-- @return exists whether or not the username exists in the system

function Auth:user_exists(username)
   username = username:lower()
   local cmd = self:prepare(self.queries.USER_EXISTS, username)
   local cur = self.con:execute(cmd)
   local row = cur:fetch()
   cur:close()

   return row and (tonumber(row) == 1)
end

------------------------------------------------------------------
-- Attempt to authenticate a given user with a given password
--
-- @param username the username to authenticate
-- @param password the raw password to authenticate with
-- @return user the name of the authenticated user
-- @return token a hashed token for the user
function Auth:authenticate(username, password)
   username = username:lower()
   local cmd = self:prepare(self.queries.USER_PWHASH, username)
   local cur = assert(self.con:execute(cmd))
   local stored_hash = cur:fetch()
   
   if not stored_hash then
      return nil, errors.no_such_user(username)
   end
   
   local cmd = self:prepare(self.queries.GET_META, username, "creation_time")
   local cur = self.con:execute(cmd)
   local time = cur:fetch()
   cur:close()

   local hash = self.sputnik:hash_password(password, time, stored_hash)
   if hash~=stored_hash then
      return nil, errors.wrong_password(username)
   end

   -- Get the display name for this user
   local cmd = self:prepare(self.queries.GET_META, username, "display")
   local cur = self.con:execute(cmd)
   local display = cur:fetch()
   cur:close()

   return display, self.sputnik:make_token(username..hash)
end

------------------------------------------------------------------
-- Validate an existing authentication token.  This is used for 
-- allowing authentication via cookies
--
-- @param username the username the token belong to
-- @param token the actual token hash
-- @return user the name of the authenticated user

function Auth:validate_token(username, correct_token)
   username = username:lower()
   local cmd = self:prepare(self.queries.USER_PWHASH, username)
   local cur = assert(self.con:execute(cmd))
   local password = cur:fetch()
   cur:close()
   
   if password then
      local token = self.sputnik:make_token(username..password)
      if token == correct_token then
         -- Get the display name for this user
         local cmd = self:prepare(self.queries.GET_META, username, "display")
         local cur = self.con:execute(cmd)
         local display = cur:fetch()
         cur:close()

         return display
      end
   end

   return nil, "Invalid token or no such user"
end

------------------------------------------------------------------
-- Returns whether or not a given user is a new user, defined
-- by the "recent" configuration parameter.
-- @param username the username to query
-- @return isRecent a boolean value indicating if the user's 
-- account was created in the specified time frame

function Auth:user_is_recent(username)
   username = username:lower()
   local cmd = self:prepare(self.queries.GET_META, username, "creation_time")
   local cur = self.con:execute(cmd)
   local time = cur:fetch()
   cur:close()

   if time then
      local now = os.time()
      local min = now - self.recent

      return (tonumber(time) > min)
   else
      return false
   end
end

------------------------------------------------------------------
-- Sets a password for the user. (An optional function.)
--
-- @param username the username to add
-- @param password the raw password
-- @return success a boolean value indicating if the add was
-- successful.
-- @return err an error message if the add was not successful

function Auth:set_password(username, password)
   if not self:user_exists(username) then
      return nil,  errors.no_such_user(username)
   end

   local cmd = self:prepare(self.queries.GET_META, username, "creation_time")
   local cur = self.con:execute(cmd)
   local creation_time = cur:fetch()
   cur:close()

   local pwhash = self.sputnik:hash_password(password, creation_time)

   username = username:lower()

   -- Update the user table
   local cmd = self:prepare(self.queries.SET_PASSWORD, pwhash, username)
   local res = self.con:execute(cmd)
   assert(res == 1)

   return true
end

------------------------------------------------------------------
-- Adds a user/password pair to the password file
--
-- @param username the username to add
-- @param password the raw password
-- @param metadata any metadata to be stored
-- @return success a boolean value indicating if the add was 
-- successful.
-- @return err an error message if the add was not successful
function Auth:add_user(username, password, metadata)
   local now = os.time()
  
   if self:user_exists(username) then
      return nil, errors.user_already_exists(username)
   end

   local pwhash = self.sputnik:hash_password(password, now)
   metadata = metadata or {}
   metadata.creation_time = now
   metadata.display = username

   -- Store the username as lowercase in the auth table
   username = username:lower()

   -- Add the user to the user table
   local cmd = self:prepare(self.queries.ADD_USER, username, pwhash)
   local res = self.con:execute(cmd)
   assert(res == 1)

   -- Add any metadata to the table
   for key,value in pairs(metadata) do
      local cmd = self:prepare(self.queries.ADD_META, username, key, value)
      local res = self.con:execute(cmd)
      assert(res == 1)
   end
   return true
end

-----------------------------------------------------------------------------
-- Retrieves a piece of metadata for a specific user
--
-- @param username       the username to query
-- @param key            the metadata key to query
-- @return data          the value of the metadata or nil
function Auth:get_metadata(username, key)
   if type(username) ~= "string" then return nil end

   local cmd = self:prepare(self.queries.GET_META, username, key)
   local cur = assert(self.con:execute(cmd))
   local data = cur:fetch()
   cur:close()

   return data
end

-----------------------------------------------------------------------------
-- Sets a piece of metadata for a specific user
--
-- @param username       the username to alter
-- @param key            the metadata key to set
-- @param value          the value to set
function Auth:set_metadata(username, key, value)
   if type(username) ~= "string" then return nil end

   -- Determine if the metadata currently exists
   local cmd = self:prepare(self.queries.SET_META, username, key, value, value)
   assert(self.con:execute(cmd))
end

-- vim:ts=3 ss=3 sw=3 expandtab
