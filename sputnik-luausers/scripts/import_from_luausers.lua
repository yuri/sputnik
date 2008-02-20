require"luarocks.require"

--wikistorage = require"versium.importer.wikistorage"
require"lfs"
require"versium"

template = [[
title = [===[%s]===]
content = [=======================================================================================[%s]=======================================================================================]


]]

month_to_num = {
Jan = "01",
Feb = "02",
Mar = "03",
Apr = "04",
May = "05",
Jun = "06",
Jul = "07",
Aug = "08",
Sep = "09",
Oct = "10",
Nov = "11",
Dec = "12",
}

function import(source_dir, --decameled, 
                versium_params)

   local users = {}
   
   vers = versium.open{params=versium_params}

   for node in lfs.dir(source_dir) do

      if not (node=="." or node=="..") then

         print("============= "..node.." =========================")

         print(source_dir..node.."/index")
         hist = io.open(source_dir..node.."/index")
         revs = {}
         while true do
            local line = hist:read("*line")
            if not line then break end
            local rev_id, time, user, comment = string.match(line, "([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*)")
            local minor
            if time:sub(1,3)=="<i>" then 
               minor = true
               time = time:sub(21)
            end

            print(time, minor) --rev_id.."\n"..time.."\n"..user.."\n"..content)

            --January 26, 2008 10:32 pm GMT
            local month, date, year, hh, mm, ampm = string.match(time, "(%w*) (%d*), (%d*) (%d*):(%d*) (%w%w) GMT")

            local hours = tonumber(hh)
            if ampm == "pm" then hours=hours+12 end
            if hh=="12" then hours=hours-1 end
            timestamp = string.format("%s-%s-%02d %02d:%s:00", year, month_to_num[month:sub(1,3)], tonumber(date), hours, mm)

            table.insert(revs, {rev_id, user, comment, timestamp})
         end


         for i,rev in ipairs(revs) do
            rev_id, user, comment, timestamp = unpack(revs[#revs-i+1])
            f = io.open(source_dir..node.."/"..rev_id)  --used to be "decameled"
            vers:save_version(node, string.format(template, string.gsub(node, "([a-z])([A-Z])", "%1 %2"), 
                                                                        string.gsub(f:read("*all"), '&#39;', "'")), user, comment, {}, timestamp)

         end
               
         --local versions = storage:get_history(node,1000000)
         --[[local inverse_versions = {}
         for i, v in ipairs(versions) do
            if approved_users[v.author] then       
               table.insert(inverse_versions, v)
            end
         end
         for i, v in ipairs(inverse_versions) do
            vi = inverse_versions[#inverse_versions-i+1]
            print(vi.version, "by", vi.author)
            local ts = vi.version
            ts = ts:sub(1,10).." "..ts:sub(12,13)..":"..ts:sub(15,16)..":"..ts:sub(18,19)
            vers:save_version(node, string.format(template, vi.title, vi.content), vi.author, vi.summary, {}, ts)
         end]]
      end
   end
end

--for u,v in pairs(users) do
-- if (u:len() < 16 or u:len() > 16 or u:sub(7,7)~=" ") then print("USER[[["..u.."]]]=1") end
--print(u:len(), u)
--end


--import("/home/yuri/gk/sputnik/luausrs/nodes/", "/home/yuri/gk/sputnik/luausrs/decameled/", {dir="/home/yuri/sputnik/wiki-data"})

import(arg[1], {dir=arg[2]})
