module(..., package.seeall)
-------------------------------------------------------------------------------
-- Authentication -------------------------------------------------------------
-------------------------------------------------------------------------------

PASSWORD_TEMPLATE = [=[USERS = {}
$do_users[[USERS["$user"]={hash="$hash", time="$time"}
]]]=]

function make_authenticator (sputnik, params)
   params = params or {}

   local password_node = sputnik:get_node(sputnik.config.PASS_PAGE_NAME)
   local users = password_node.content
   users = users.USERS or {}

   local function get_token(username) 
      return md5.sumhexa(username..sputnik.config.SECRET_CODE.."Sputn!k") 
   end
   
   local function get_token_for_timestamp(timestamp)
      return md5.sumhexa(timestamp..sputnik.config.SECRET_CODE)
   end

   local function user_exists(username) 
      return users[username]
   end

   local function get_salted_hash(time, password)
      return md5.sumhexa(time..sputnik.config.SECRET_CODE..password)
   end
  
   local function now() 
      local d = os.date("*t")
      return string.format("%04d-%02d-%02dT%02d-%02d-%02d", d.year, d.month, d.day, d.hour, d.min, d.sec)
   end

   local function days_since_ce(date)
      return 365*tonumber(date:sub(0,4))+31*tonumber(date:sub(6,7))+tonumber(date:sub(9,10))
   end
   
   local function hours_since_ce(timestamp)
      return days_since_ce(timestamp)*24+tonumber(timestamp:sub(12,13))
   end   
   
   local function is_recent(username)
      if username and users[username] and users[username].time then
         return (days_since_ce(now()) -days_since_ce(users[username].time)) < 14
      else
         --sputnik.logger:debug(username.." not known, will return false")
         return false
      end
   end
    
   local function add_user(username, password) 
      sputnik.logger:debug("adding a new user: "..username..","..password)
      local time = now()
      users[username] = {
         hash  = get_salted_hash(time, password), 
         time = time
      }
   end

   local function save(user)
      sputnik.logger:debug("current users:")
      for k,v in pairs(users) do
         sputnik.logger:debug(k)
      end
      local new_values = {
         content = cosmo.f(PASSWORD_TEMPLATE){ 
                      do_users = function()
                         for user, value in pairs(users) do
                            cosmo.yield{
                               user=user, 
                               hash=value.hash,
                               time=value.time}
                         end
                      end
                   },
      }
      password_node = sputnik:update_node_with_params(password_node, new_values)
      password_node:save(user, "Added new user: "..user, {minor="yes"})
   end

   local function check_password(user, password) 
      if users[user] and users[user].hash == get_salted_hash(users[user].time, password) then
         return user, get_token(user)
      elseif user_exists(user) or (params.NO_AUTO_REGISTRATION and user~="Admin") then
          return nil
      else
	      add_user(user, password)
	      save(user)
	      return user, get_token(user)
      end
   end

   local function check_token(user, token)
      if ((user or ""):len() > 0) and (get_token(user) == token) then
	      return user
      else
	      return nil
      end
   end

   return { 
      check_password = check_password,
      check_token    = check_token,
      is_recent      = is_recent,
      get_token_for_timestamp = get_token_for_timestamp,
      now            = now,
      hours_since_ce = hours_since_ce,
   }
end
