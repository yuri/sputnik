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

   local messages = mbox.new(node.content)
   node.inner_html = cosmo.f(node.templates.THREAD){
                        do_messages = function() 
                           for i, m in ipairs(messages) do
                              m = mbox.new_message(m)
                              set_name(m)
                              local attachments = get_attachments(m)
                              cosmo.yield {
                                    name  = m.headers.name,
                                    email = m.headers.email:gsub("%s*$", ""):gsub("^%s*", ""),
                                    date  = m.headers.date, --os.date("!%Y-%m-%d", m:get_from_line_date()),
                                    body  = sputnik:escape(m.body),
                                    raw_body = m.body,
                                    do_attachments = function()
                                       for j, a in ipairs(attachments) do
                                          cosmo.yield(a)
                                       end
                                    end
                              }
                           end
                        end
                     }
   return node.wrappers.default(node, request, sputnik)
end
   
