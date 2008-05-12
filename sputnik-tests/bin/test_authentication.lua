require"sputnik"

SPUTNIK_DIR = "/home/yuri/sputnik/"

function test_auth(args)
   print("Testing module "..args.module)

   -- Create a simple Sputnik instance
   local my_sputnik = sputnik.new{
      VERSIUM_PARAMS = { dir = SPUTNIK_DIR..'wiki-data/' },
      BASE_URL = "/"
   }
   assert(my_sputnik, "Couldn't create a Sputnik instance with those configurations")

   -- Load the authentication module
   local mod = require(args.module)
   assert(mod, "Couldn't require auth module "..args.module)

   -- Create an auth instance
   local auth, err = mod.new(my_sputnik, args.params)
   assert(auth, "Couldn't create an auth instance: "..(err or ""))

   math.randomseed( os.time() )
   local username = "Dude"..math.random()
   local username2 = "Иван Иваныч "..math.random()
   local admin_username = "FooMan"..math.random()
   local display_name = "Some Dude"

   -- Check for a non-existent user (we are assuming that the user db is empty
   assert(auth:user_exists(username)==false, "The user database should be empty")

   -- Create a user
   auth:add_user(username, "letmein", {foo="bar"})
   assert(auth:user_exists(username), "The user should be created successfully")

   -- Also one with a non-western name
   auth:add_user(username2, "letmein")
   assert(auth:user_exists(username2), "The user should be created successfully")

   -- Try to authenticate this user with the wrong password
   assert(auth:authenticate(username, "wrong pass")==nil, "Wrong pass shouldn't work")

   -- Now the right password
   local display, token = auth:authenticate(username, "letmein")
   assert(display, "Couldn't login user "..username..": "..(token or ""))
   assert(token)
   assert(auth:get_metadata(username, "foo")=="bar")
   -- Check adminness
   assert(auth:get_metadata(username, "is_admin")==nil)

   -- Now create an admin
   auth:add_user(admin_username, "admin_pw", {is_admin="true"})
   assert(auth:user_exists(admin_username))
   local display, admin_token = auth:authenticate(admin_username, "admin_pw")
   assert(display==admin_username)
   assert(auth:get_metadata(admin_username, "is_admin")=="true")

end

test_auth{
   module = 'sputnik.authentication.mysql',
   params = {"sputnik_auth", "sputnik", "letmein", "localhost"},
}

test_auth{
   module = 'sputnik.authentication.simple',
   --params = {"sputnik_auth", "sputnik", "letmein", "localhost"},
}
