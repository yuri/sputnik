module(..., package.seeall)

NODE = {
 actions = [[
  get_auth_token = "bots.get_auth_token"
 ]],
 permissions = [[
allow(all_users, "get_auth_token")
]]
}

