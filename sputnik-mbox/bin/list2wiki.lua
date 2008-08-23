require("mbox")

function load_kepler_list_file(year, month, mb)
   prefix =  "/home/yuri/ac/2007/kepler/list/"
   mb:add_file(prefix..string.format("%04d-%02d.txt", year, month), mb)
end

require("sputnik.util")

--function dirify(text)
--      return text:gsub("[^%a%d%:%%[%]-]+", "_")
--end

NODE_TEMPLATE = [[
title=%q
actions="show='mbox.show'"
templates="_templates_for_mbox"
content = [=======[
%s
]=======]
]]

NODE_TEMPLATE_2 = [[
title=%q
content = [=======[
%s
]=======]
]]


-- Converts a message subject into an ID and a title
local function subject_to_id_and_title(subject)
   subject = subject:gsub("%[Kepler%-Project%]", "") -- remove the list name
   subject = subject:gsub("%s+"," "):gsub("^%s+", ""):gsub("%s+$", "") -- trim whitespace
   local id = sputnik.util.dirify(subject):gsub("%[","_"):gsub("%]","_"):gsub("%.", "_")
   --local html_title = subject:gsub("%[", "&rsqb;"):gsub("%]", "&lsqb;")
   print(subject, id)
   return id, subject  --, html_title 
end

function test()
   local mb = mbox.new()
   mb.list_prefix = "%[Kepler%-Project%]%s*"
   for i=2,12 do
      load_kepler_list_file(2006, i, mb)
   end
   for i=1,3 do
      load_kepler_list_file(2007, i, mb)
   end

   require"versium.filedir"
   local ver = versium.filedir.new{"/home/yuri/sputnik/wiki-data/"}

   local threads = mb:get_subject_threads()

   local index = ""

   for k, thread in pairs(threads) do
      local id, title = subject_to_id_and_title(thread[1].headers.subject)
      print(">", id, title)
      local buffer = ""      
      for i, m in ipairs(thread) do
         buffer = buffer..m.raw.."\n\n"
      end
      ver:save_version("list/"..id, string.format(NODE_TEMPLATE, title, buffer), "Robot", "test")
   
      local stars = ""
      for i,v in ipairs(thread) do stars=stars.."*" end

      index = index.."\n"..os.date("!%Y-%m-%d", thread[1]:get_from_line_date())
                   ..": ".."[[list/"..id.."|"..title:gsub("%]", "\\]").."]] "..stars.."<br/>"
   end
   ver:save_version("list/recent", string.format(NODE_TEMPLATE_2, "list/Recent", index), "Robot", "test")
end

test()
