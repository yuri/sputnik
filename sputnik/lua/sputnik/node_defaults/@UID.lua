module(..., package.seeall)

NODE = {}
NODE.permissions = [[deny(all_users, all_actions)
allow(Admin, all_actions)]]
