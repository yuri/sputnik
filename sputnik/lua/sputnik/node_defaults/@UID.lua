module(..., package.seeall)

NODE = {}
NODE.permissions = [[deny(Anonymous, "show")
allow(Admin, all_actions)]]
