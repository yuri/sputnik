-----------------------------------------------------------------------------
-- Defines functions that create messages messages to be used by
-- Sputnik authentication modules.
--
-----------------------------------------------------------------------------

module(..., package.seeall)

function no_such_user(username)
   return "Authentication Error: No such user: "..username
end

function wrong_password(username)
   return "Authentication Error: Wrong password for user: "..username
end

function wrong_password_or_no_such_user(username)
   return "Authentication Error: Wrong password or user doesn't exist: "..username
end

function initialization_error(message)
   return "Authentication Error: Could not initialize authentication module: "..message
end

function module_specific_error(message)
   return "Authentication Error: Module-specific error: "..message
end

function user_already_exist(username)
   return "Authentication Error: Could not create new user: user '"..tostring(username).."' already exists"
end
