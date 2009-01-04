module(..., package.seeall)

local base64 = require("base64")
require"mime"
require"iconv"

local function parse_headers(headers_s)
   headers_s = "\n" .. headers_s .. "$$$:\n"
   local headers = {}
   local i, j = 1, 1
   local name, value, _
   while 1 do
      j = headers_s:find("\n%S-:", i+1)
      if not j then break end
      _, _, name, value = string.sub(headers_s, i+1, j-1):find("(%S-):(.*)")
      if value:sub(1,1) == " " then
         value = value:sub(2)
      end
      value = (value or ""):gsub("\r\n", "\n"):gsub("\n%s*", " ")
      name = name:lower()
      if headers[name] then
         headers[name] = headers[name]..", ".. value
      else
         headers[name] = value
      end
      i, j = j, i
   end
   headers["$$$"] = nil
   return headers
end

local Message = {}
local Message_mt = {__metatable = {}, __index = Message}

function Message:get_original_subject()
   if not self.original_subject then
      self.original_subject = self.headers.subject:gsub("[Rr][Ee][Ss]?%:", ""):gsub("%s", "")
   end
   return self.original_subject
end

FROM_LINE_DATE_PATTERN = "%s(%w*)%s+(%d+)%s+(%d%d):(%d%d):(%d%d)%s+(%d+)$" 

MONTHS = {
   Jan = "01", Feb = "02", Mar = "03", Apr = "04", May = "05", Jun = "06",
   Jul = "07", Aug = "08", Sep = "09", Oct = "10", Nov = "11", Dec = "12",
}

function Message:get_from_line_date()
   local month, day, hour, min, sec, year = self.from_line:match(FROM_LINE_DATE_PATTERN)
   return os.time{ year=year, month=MONTHS[month], day=day, hour=hour, min=min, sec=sec }
end

EMAIL_PATTERNS = {
   "%<(.-%@.-)%>",
   "%<(.-%s+at%s+.-)%>",
   "%<(.-)%>",
   "^(.-@.-)%s+",
   "^(.-%s+at%s+.-)%s+",
   "^(.-)%s+%(",
   "^(.-)%s+",
   "^(%S*)",
}

function Message:get_sender_email()
   local email
   --print("-------"..self.headers.from.."-----")
   for i, patt in ipairs(EMAIL_PATTERNS) do
      email = self.headers.from:match(patt)
      --print(patt, email)
      if email then
         local email_start, email_end = self.headers.from:find(email)
         local name = self.headers.from:sub(0, email_start-1)
         if name == "" then
            name = self.headers.from:sub(email_end+1)
         end
         name = name:gsub("^%s*", ""):gsub("%s*$", ""):gsub("^%(", ""):gsub("%)$", "")
         return email:lower(), name
      end
   end
end

function Message:get_sender_tld(email)
   local tld = (email or self:get_sender_email() or ""):match("%.([^%.]*)$")
   if tld and tld:match("^%d+$") then
      return "IP"
   else
      return tld
   end
end

GLOBAL_MAIL_PROVIDERS = {
   "gmail.com",
   "yahoo.com",
   "hotmail.com"
}

function Message:check_common_provider(email)
   email = email or self:get_sender_email()
   for i, provider in ipairs(GLOBAL_MAIL_PROVIDERS) do
      if email:match(provider.."$") then
         return provider
      end
   end
end

function new_message(message_t)
   return setmetatable(message_t, Message_mt)
end

local mime_decoders = {
   Q =  mime.decode("quoted-printable"),
   B =  mime.decode("base64")
}

local decode_to_utf8 = function(character_encoding, mime_decoder, text)
   local cd = iconv.new("UTF8", character_encoding)
   text = mime_decoders[mime_decoder](text)
   text = cd:iconv(text)
   return text
end

local function decode(text)
   text = text:gsub("%=%?([^%?]*)%?([BQ])%?([^%?]*)%?%=", decode_to_utf8)
   return text
end

local function parse_message(message_s)
   local from_line, headers, body = message_s:match("^(.-)\n(.-\n)\n(.*)")
   local message = {
            from_line = from_line,
            headers   = parse_headers(headers or ""),
            body      = body or "",
            raw       = message_s,
          }

   if message.headers["content-transfer-encoding"] == "base64" then
      --message.headers.subject = base64.decode(message.headers.subject)
      message.body = base64.decode(message.body)
   end

   local encoding = message.headers["content-type"]:match("charset%=(%S*)")
   if encoding then
      local cd = iconv.new("UTF8", encoding)
      message.body = cd:iconv(message.body)
   end


   -- "=?ISO-8859-1?Q?Re:_[Sputnik-list]_sputnik_n=E3o_?="

   message.headers.from = decode(message.headers.from)
   message.headers.subject = decode(message.headers.subject)
   return message
end

local MBox = {}
local MBox_mt = {__metatable = {}, __index = MBox}

function new(mbox_s)
   local mbox = setmetatable({}, MBox_mt)
   if mbox_s then
      mbox:add(mbox_s)
   end
   return mbox
end

function MBox:add(mbox_s)
   mbox_s = "\n"..mbox_s.."\nFrom "
   local i, j = 1, 1
   local message
   while 1 do
      j = mbox_s:find("\nFrom ", i + 1)
      if not j then break end
      table.insert(self, parse_message(mbox_s:sub(i+1, j-1)))
      i, j = j, i
   end
end

function MBox:add_file(filepath)
   local f = io.open(filepath)
   self:add(f:read("*all"))
   f:close()
end

function MBox:add_difference(filepath_new, filepath_old)
   local f_old = io.open(filepath_old)
   local old_count = 0
   print(filepath_old)
   for line in f_old:read("*all"):gmatch("\n") do
      old_count = old_count + 1
   end
   f_old:close()
   local f_new = io.open(filepath_new)
   local new_buffer = ""
   local new_count = 0
   for line in f_new:read("*all"):gmatch(".-\n") do
      new_count = new_count + 1
      if new_count >= old_count then
         new_buffer = new_buffer .. line
      end
   end
   f_new:close()
   print("["..new_buffer.."]")
   self:add(new_buffer)
end

function MBox:get_subject_threads()
   local thread_hash = {}
   for i, message in ipairs(self) do
      message = mbox.new_message(message)
      local subj = message:get_original_subject():gsub("%s", "") or "NO SUBJECT"
      message.date = message:get_from_line_date()
      if not thread_hash[subj] then
         thread_hash[subj] = {dates={}}
      end
      thread_hash[subj].dates[os.date("!%Y-%m-%d", message.date)] = true
      table.insert(thread_hash[subj], message)
   end
   local thread_list = {}
   for k,thread in pairs(thread_hash) do
      table.insert(thread_list, thread)
   end
   table.sort(thread_list, function(t1, t2) return t1[1].date < t2[1].date end)
   return thread_list
end

