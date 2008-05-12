module(..., package.seeall)

require"lfs"
require"versium.filedir"
local wikistorage = require"versium.importers.wikistorage"

template = [[
title = %q
content = %q
]]

function import(source_dir, dest_dir, password_file)

   -- if password_file is supplied then we'll only import edits from users in it
   local approved_users  
   if password_file then 
      approved_users = dofile(password_file)
   end

   local wikifilestorage = require("versium.importers.wikifilestorage").open(source_dir)
   local storage  = wikistorage.open(wikifilestorage)
   
   local vers = versium.filedir.new{dir=dest_dir}

   for node in lfs.dir(source_dir) do
      print("============= "..node.." =========================")
      if node~="_passwords" then
         print("::")
         local versions = storage:get_history(node,1000000)
         local inverse_versions = {}
         for i, v in ipairs(versions) do
            if (not approved_users) or approved_users[v.author] then       
               table.insert(inverse_versions, v)
            end
         end
         for i, v in ipairs(inverse_versions) do
            vi = inverse_versions[#inverse_versions-i+1]
            print(vi.version, "by", vi.author)
            local ts = vi.version
            ts = ts:sub(1,10).." "..ts:sub(12,13)..":"..ts:sub(15,16)..":"..ts:sub(18,19)
            vers:save_version(node, string.format(template, vi.title or "", vi.content or ""), vi.author, vi.summary, {}, ts)
         end
      end
   end
end

--import("sputnik-site.bak/wiki-data/", {dir="/tmp/foo"}, users)
