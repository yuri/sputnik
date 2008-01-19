require("mbox")

function load_mbox_file(filepath, mb) 
    local f = io.open(filepath)
    local mbtext = f:read("*all")
    f:close()
    return mbox.parse(mbtext, mb)
end

function load_kepler_list_file(year, month, mb)
   prefix =  "/home/yuri/ac/kepler/list/"
   return load_mbox_file(prefix..string.format("%04d-%02d.txt", year, month),
			 mb)
end
		    
function rstrip(text)
   return string.match(text, "%s*(.*)")
end


month_to_num = { 
   Jan = 1,
   Feb = 2,
   Mar = 3,
   Apr = 4,
   May = 5,
   Jun = 6,
   Jul = 7,
   Aug = 8,
   Sep = 9,
   Oct = 10,
   Nov = 11,
   Dec = 12
}


function dirify(text)
      return text:gsub("[^%a%d%:%-]+", "_")
end

function thread_less_than (t1, t2) 
   return t1.last_mod_date > t2.last_mod_date
end

function test()

   mb = {}

   for i=2,12 do
      mb = load_kepler_list_file(2006, i, mb)
   end

   for i=1,3 do
      mb = load_kepler_list_file(2007, i, mb)
   end

   threads = {}
   for i, message in ipairs(mb) do
      local _
      local subj = message.headers.subject

      for j = 1,2 do
	 _, subj = string.match(subj, "([^%:^[]*):(.*)")
	 if not subj then subj = message.headers.subject end
      end

      subj = rstrip(subj)

      local re = string.match(subj, "Re:%s*(.*)")
      if not re then 
	 re = string.match(subj, "RE:%s*(.*)")
      end
      if re then subj = re end

      if string.sub(subj, 1,16) == "[Kepler-Project]" then
	 subj = string.sub(subj, 17)
      end

      subj = rstrip(subj)
      message.headers.subject = subj

      if not threads[subj] then
	 threads[subj] = {}
      end

      table.insert(threads[subj], message)
   end

   require("wikifilestorage")
   storage = wikifilestorage.WikiFileStorage:new("/home/yuri/gk/sputnik/data/")

   for k, thread in pairs(threads) do

      local id = dirify(thread[1].headers.subject)

      local buffer = ""
      thread.last_mod_date = "0000"
      for i, m in ipairs(thread) do
	 --Sun Jan 14 06:31:13 2007
	 local _, month, day, time, year = string.match(m.headers.date,
		"(%w*)%s*(%w*)%s*(%d*)%s*(%d%d%:%d%d%:%d%d)%s*(%d*)")
	 local date = string.format("%04d-%02d-%02d-%s",
				    year, month_to_num[month], day, time)
	 if date > thread.last_mod_date then
	    thread.last_mod_date = date
	 end
	 buffer = buffer .. m.raw .. "\n"
      end

      local page = {
	 title = "[Kepler-List] " .. thread[1].headers.subject,
	 author = "Mail Robot",
	 category = "Mailing List",
	 summary = "",
	 minor = "none",
	 content = buffer,
	 templates = "Templates:MBox",
	 actions = "{show='mbox.show'}",
      }

      storage:save_page("Kepler-List:" .. id, page)

   end

   local thread_array = {}
   for k,t in pairs(threads) do
      table.insert(thread_array, t)
   end

   table.sort(thread_array, thread_less_than)
   
   buffer = "<ul>"
   for i, t in ipairs(thread_array) do
      buffer = buffer .. "<li>[[Kepler-List:" .. t[1].headers.subject 
	 .. "]] (" .. t.last_mod_date .. ")</li>\n" 
   end
   buffer = buffer .. "</ul>"
   storage:save_page("Kepler-List:Recent", 
		     {  title = "Kepler-List: Recent Messages",
			author = "Mail Robot",
			category = "Mailing List",
			summary = "",
			minor = "none",
			actions = '{}',
			content = buffer,
		     }
		  )
end

test()
