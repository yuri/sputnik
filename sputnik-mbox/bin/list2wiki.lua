require("mbox")
require("sputnik")

LIST_PREFIX_PATTERN = "%[Sputnik%-list%]"

NODE_TEMPLATE = [[
title=%q
proto=%q
content = [=======[
%s
]=======]
]]


-- Converts a message subject into an ID and a title
local function subject_to_id_and_title(subject)
   subject = subject:gsub(LIST_PREFIX_PATTERN, "") -- remove the list name
   subject = subject:gsub("%s+"," "):gsub("^%s+", ""):gsub("%s+$", "") -- trim whitespace
   local id = sputnik.util.dirify(subject):gsub("%[","_"):gsub("%]","_"):gsub("%.", "_")
   return id, subject
end

function run(wiki_data, path, old_path, prototype, prefix)
   prototype = prototype or "@Mailing_List_Thread"
   prefix = prefix or "list/"
   local mb = mbox.new()
   mb.list_prefix = LIST_PREFIX_PATTERN.."%s*"

   if old_path then
      mb:add_difference(path, old_path)
   else
      mb:add_file(path)      
   end

   local my_sputnik = sputnik.new{
                         VERSIUM_PARAMS = { wiki_data },
                         BASE_URL = "",
                         TOKEN_SALT = ""
                      }
   local threads = mb:get_subject_threads()
   local index = ""

   for k, thread in pairs(threads) do
      local id, title = subject_to_id_and_title(thread[1]:get_original_subject())
      id = prefix..id
      print(id)
      local node = my_sputnik:get_node(id)

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
         node:save(m:get_sender_email():gsub(" at ","@"), "", {},
                   os.date("!%Y-%m-%d %H:%M:%S", m:get_from_line_date()))
      end         
   end
end

run(arg[1], arg[2], arg[3])
