require("mbox")
require("sputnik")

--function dirify(text)
--      return text:gsub("[^%a%d%:%%[%]-]+", "_")
--end

LIST_PREFIX_PATTERN = "%[Sputnik%-list%]"

NODE_TEMPLATE = [[
title=%q
proto=%q
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
   subject = subject:gsub(LIST_PREFIX_PATTERN, "") -- remove the list name
   subject = subject:gsub("%s+"," "):gsub("^%s+", ""):gsub("%s+$", "") -- trim whitespace
   local id = sputnik.util.dirify(subject):gsub("%[","_"):gsub("%]","_"):gsub("%.", "_")
   --local html_title = subject:gsub("%[", "&rsqb;"):gsub("%]", "&lsqb;")
   return id, subject  --, html_title 
end

function run(path, prototype, prefix)

   prototype = prototype or "@Mailing_List_Thread"
   prefix = prefix or "list/"
   local mb = mbox.new()
   mb.list_prefix = LIST_PREFIX_PATTERN.."%s*"
   mb:add_file(path)

   --require"versium.filedir"
   --local saci = saci.new("versium.filedir", {"/home/yuri/sputnik/wiki-data/"}, "@Root")
   local my_sputnik = sputnik.new{
                         VERSIUM_PARAMS = { '/home/yuri/sputnik/wiki-data/' },
                         BASE_URL = "",
                         TOKEN_SALT = ""
                      }
   local threads = mb:get_subject_threads()
   local index = ""

   for k, thread in pairs(threads) do
      local id, title = subject_to_id_and_title(thread[1].headers.subject)
      id = prefix..id
      print(id)
      local node = my_sputnik:get_node(id)
      --node = node or saci:make_node("", "foo")

      for i, m in ipairs(thread) do
         local new_content = node.content or ""
         if new_content ~= "" then new_content = new_content.."\n\n" end
         new_content = new_content..m.raw
         my_sputnik:update_node_with_params(
                    node, 
                    { content = new_content,
                      title = title,
                      prototype = prototype
                    }
         )
         node:save(m:get_sender_email():match("^%S*").."@...", "", {},
                   os.date("!%Y-%m-%d %H:%M:%S", m:get_from_line_date()))
      end
         
      --local stars = ""
      --for i,v in ipairs(thread) do stars=stars.."*" end
      --index = index.."\n"..os.date("!%Y-%m-%d", thread[1]:get_from_line_date())
      --             ..": ".."[[list/"..id.."|"..title:gsub("%]", "\\]").."]] "..stars.."<br/>"
   end
   --ver:save_version("list/recent", string.format(NODE_TEMPLATE_2, "list/Recent", index), "Robot", "test", {}, "2009-02-01 22:22:22")
end

run(arg[1])
