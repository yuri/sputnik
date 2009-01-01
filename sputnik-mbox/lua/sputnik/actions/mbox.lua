module(..., package.seeall)

require("mbox")

actions = {}

function set_name(message) 
   message.headers.email, message.headers.name 
      = string.match(message.headers.from, 
             "([^%(]*)%(([^%)]*)%)")
   if not message.headers.name then
      message.headers.name = message.headers.from
   end

   local enc = string.match(message.headers.name,
                "%=%?[^%?]*%?.%?(.*)%?%=")
   if enc then message.headers.name = enc end
end

ATTACHMENT_RE = "%-* next part %-*\n" 
   .. "A non%-text attachment was scrubbed...\n"
   .. "Name: ([^\n]*)\n"
   .. "Type: ([^\n]*)\n"
   .. "Size: ([^\n]*)\n"
   .. "Desc: ([^\n]*)\n"
   .. "Url : ([^\n]*)\n"

HTML_ATTACHMENT_RE = "%-* next part %-*\n" 
   .. "An HTML attachment was scrubbed...\n"
   .. "URL: ([^\n]*)\n"

function attachment_to_pre(name, type, size, desc, url)
   return "Attachment:" .. name .. size
end

function get_attachments(m)
   local attachments = {}
   for name, type, size, desc, url in string.gmatch(m.body, ATTACHMENT_RE) do
      attachments[#attachments+1] = {
          name = name, type = type, size = size, desc = desc, url  = url,
      }
   end
   if #attachments > 0 then
      m.body = string.gsub(m.body, ATTACHMENT_RE, 
      function() return "" end)
   end
   for url in string.gmatch(m.body, HTML_ATTACHMENT_RE) do
   attachments[#attachments+1] = {
      name = "attachment.html",
      type = "html",
      size = "unknown", 
      desc = "HTML attachment", 
      url  = url,
   }
   end
   if #attachments > 0 then
      m.body = string.gsub(m.body, HTML_ATTACHMENT_RE, function() return "" end)
   end
   return attachments
end

actions.show = function(node, request, sputnik)

   --node:add_javascript_link(sputnik:make_url("sputnik/js/editpage.js"))

   local messages = mbox.new(node.content)
   local counts_by_username = {}
   local closed = ""
   node.inner_html = cosmo.f(node.html_content){
                        do_messages = function() 
                           for i, m in ipairs(messages) do
                              m = mbox.new_message(m)
                              set_name(m)
                              local attachments = get_attachments(m)

                              local email = m.headers.email:gsub("%s*$", ""):gsub("^%s*", ""):gsub("@", " at ")
                              local username = email:match("^%S*"):lower()
                              local user_id = username:gsub("[^a-z]", "_")

                              counts_by_username[user_id] = 1 + (counts_by_username[user_id] or 0)

                              local body_lines = {}

                              local prev = ""
                              for line in m.body:gmatch("[^\n]*") do
                                 if line:sub(0,1) == ">" then
                                    line = "<span class='quote_in_email'>"..sputnik:escape(line).."</span>"
                                 else
                                    line = sputnik:escape(line)
                                 end
                                 if line~="" or prev=="" then
                                    table.insert(body_lines, line)
                                 end
                                 prev = line
                              end

                              cosmo.yield {
                                    name  = m.headers.name,
                                    email = email,
                                    closed = closed,
                                    message_id = string.format("%s_%d", user_id, counts_by_username[user_id]),
                                    username = username,
                                    date  = m.headers.date, --os.date("!%Y-%m-%d", m:get_from_line_date()),
                                    body  = table.concat(body_lines, "\n"),
                                    do_attachments = function()
                                       for j, a in ipairs(attachments) do
                                          cosmo.yield(a)
                                       end
                                    end
                              }
                              closed = "closed"
                           end
                        end
                     }
   return node.wrappers.default(node, request, sputnik)
end
   
