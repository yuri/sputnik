require("luarocks.require")
require('sputnik')

local app = sputnik.wsapi_app.new{
   VERSIUM_PARAMS = { '/home/yuri/sputnik/wiki-data/' },
   --VERSIUM_STORAGE_MODULE = "versium.git",
   BASE_URL       = '/sputnik2.ws',
   PASSWORD_SALT  = 'Ex8JdVMzSyKayipfrSf4cwHdgGXmN2XhqWQtHtTq',
   TOKEN_SALT     = 'RuqgCFlUoqOqNluTSh6waUDrGkKdDutlOKrhfD1u',
   SHOW_STACK_TRACE = true,
   --[[INIT_FUNCTION  = function(my_sputnik)
                       my_sputnik.saci.permission_groups.not_friend = function(user)
                          return (not user) or (not my_sputnik.auth:get_metadata(user, "is_friend"))
                       end
                    end,]]
   --APP_CACHE_STORAGE_MODULE = "versium.sqlite3",
   --APP_CACHE_PARAMS = {"/tmp/sfoto_cache.db"},
   USE_GRAVATAR = true,
   USE_COMPRESSION = true,
}

local i = 0

local env = {
  QUERY_STRING = "p=index",
  CONTENT_TYPE = "foo",
  input = {
     read = function() end
  }
}

local status, headers, handler, content
while i < 1000 do
   status, headers, handler = app(env)
   content = handler()
   i = i + 1
end
print (content)
