
module(..., package.seeall)

require("cosmo")

SAVE_TEMPLATE = [=[
$dofields[[$field=[$eq[$value]$eq]
]]
]=]

SIMPLE_FIELDS = { 
   title     = true,
   fields    = true,
   config    = true,
   author    = true,
   category  = true,
   summary   = true,
   minor     = true,
   content   = true,
   prototype = true,
   metapage  = true,
   permissions = true,
   page_name = true,
   actions   = true,
   templates = true,
   version   = true,
   prev_version = true,
   raw       = true,
   history   = true,
   name      = true,
}


WikiStorage = {
   storage = nil,     -- The storage module
   environment = {},  -- The environment for loading pages
}


--- Creates a new instance of WikiStorage.
--
--  @param  storage      A storage module.
--  @return              An instance of WikiStorage.

function WikiStorage.new(self, storage)
   obj = {}
   obj.storage = storage
   setmetatable(obj, self)
   self.__index = self
   return obj         
end



--- Checks if the field can be handled by the standard 'save' action.
--
--  @param  field        A field name.
--  @return              True or false.

function WikiStorage.is_extra_field (self, field) 
   return not SIMPLE_FIELDS[field]
end


--- Creates a page from its string representation.
--
--  @param raw           The string representation of the page.
--  @return              A table representing the page.

function WikiStorage.string_to_page(self, page_name, raw) 
   local new_env = {}
   for i,v in ipairs(self.environment) do
      new_env[i] = v
   end
   local page = self:load_config(raw, new_env)
   page.name = page_name
   page.raw = raw
   return page
end      


--- Loads a page from the storage.
--
--  @param page_name     Page name / id.
--  @param version       The version of the page to be loaded (OPTIONAL).
--  @return              A table representing the page.

function WikiStorage.load_page (self, page_name, version)
   local raw = self.storage:load_object(page_name, version)
   page = self:string_to_page(page_name, raw)
   page.version = version
   return page
end

--- Checks if a page exists.
--
--  @param page_name     Page name / id.
--  @return              True or false.

function WikiStorage.page_exists(self, page_name) 
   return self.storage:object_exists(page_name)
end

--- Converts a page to its string representation.
--
--  @param page          The page table
--  @return              A string

function WikiStorage.page_to_string (self, page, fields)
   return cosmo.fill(SAVE_TEMPLATE, 
      { dofields = function ()
		      for field, field_params in pairs(fields) do
			 local value = page.as_is[field] or ""
			 if not field_params.virtual then
			    cosmo.yield { 
			       field= field,
			       eq = cosmo.max_equals(value).."=",
			       value = value
			    }
			 end
		      end
		   end 
      }
   )
end

--- Saves the page
--
--  @param page_name     Page name / id
--  @param page          The page table
--  @return              nil

function WikiStorage.save_page (self, page_name, page)

      -- page could be a table or a string
      local raw_page
      if not page then
	 error("WikiPage: trying to save a nil page") 
      elseif type(page) == "table" then
	 raw_page = self:page_to_string(page, page.fields)
      elseif type(page) == "string" then 
	 raw_page = page
      end
      self.storage:save_object(page_name, raw_page)
   end

--- Returns a list of changes for a specific page
--  
--  @param page_name     Page name / id.
--  @param date_prefix   A prefix representing a year, a year and a
--                       month or a year, a month and a date, which 
--                       will be used to filter the changes (OPTIONAL).
--  @return              A list of tables.

function WikiStorage.get_page_history(self, page_name, date_prefix)

   local history = self.storage:get_object_history(page_name, date_prefix)
   
   local cur_version = history[#history]
   local prev_version = nil
   
   if #history > 1 then
      prev_version = history[#history-1]
   end

   result = { 
      all = history, 
      current = cur_version, 
      previous = prev_version,
      page_name = page_name,
      class = self,
      load = function(hist, version) 
		local obj = self:load_page(hist.page_name, version)
		obj.history = hist
		return obj
	     end,
      load_latest = function(hist) 
		       return result.load(hist, result.current)
		    end,
   }
   
   return result
end



--- Returns a DECORATED list of changes for a single page or a list of pages.
--  
--  @param page_name     Page name / id (OPTIONAL).
--  @param num_items     A maximum number of items to be returned (OPTIONAL).
--  @param date_prefix   A prefix representing a year, a year and a
--                       month or a year, a month and a date, which 
--                       will be used to filter the changes (OPTIONAL).
--  @return              A list of tables.

function WikiStorage.get_history(self, page_name, num_items, date_prefix)
      local all_history = {}
      local page_table = {}
      if page_name then
         pages = {page_name}
      else
         pages = self.storage:list_object_ids()
      end

      for i, p in ipairs(pages) do
         if p:len() > 2 then
            for j, v in ipairs(self:get_page_history(p, date_prefix).all) do 
	       all_history[#all_history+1] = {v, p}
            end
         end
      end

      local function lessthan(a,b)
         return a[1] > b[1]
      end
      table.sort(all_history, lessthan)
      
      local short_history = {}
      for i=1, num_items do
         if not all_history[i] then break end
         local v, p = unpack(all_history[i])
         local page = self:load_page(p,v)
         table.insert(short_history, page)
      end
      
      return short_history
   end



--- Loads a page if it exist or returns a blank page otherwise.
--
--  @param page_name     Page name / id (OPTIONAL).
--  @param version       The version of the page to be loaded (OPTIONAL).
--  @return              A table representing the page.

function WikiStorage.load_page_or_new (self, page_name, version) 

   local page = { 
      name = page_name,
      page_name = page_name,
      version   = "New Page",
      author    = nil, 
      title     = page_name, 
      name      = page_name,
      content   = "", 
      minor     = "",
      history   = {all={}},
      actions   = "",
      raw       = "",
   }
   
   if self:page_exists(page_name) then
      page.history = self:get_page_history(page_name)
      page.prev_version = ""
      if version then
	 page.prev_version = nil  --::TODO::
	 page.version = version
      else 
	 page.version = page.history.current
	 page.prev_version = page.history.previous
      end

      if page.version then
	 for k, v in pairs(page.history:load(page.version)) do
	    page[k] = v
	 end
      end
   end
   
   return page
end



--- Loads Lua code safely, returning a table of variables defined by
--  the code.
--  
--  @param text          The text to be loaded as Lua code.
--  @param environment   The table containing the environment in which
--                       the code will be run.
--  @return              A table representing the variables defined by 
--                       the code.

function WikiStorage.load_config (self, text, environment)
   if text then 
      f,e = loadstring(text)
      if e then 
	 return {}, "can't parse lua code in a page:\n"
	    .. e .. "\nLua code: " .. text
      end
   end
   if f then 
      setfenv(f, environment)
      x = f()
      results = {}
      for k, v in pairs(getfenv(f)) do
	 results[k] = v
      end
      return results 
   end
   return nil
end


--- Performs a self-test.
--
local function test() 
   require("wikifilestorage")
   wfs = WikiFileStorage("data/")
   storage = WikiPage:new(wfs)

   print(storage.dir)
   history = storage:get_page_history("Kepler")
   print(history.current)
   print(history.previous)
   page = history:load_latest()

   print(page.content)

end


--- Returns an instance of WikiStorage.
--
--  @param storage       A storage module to be used
--  @return              An instance of WikiStorage.

function open(storage) 
   return WikiStorage:new(storage) 
end


-- Uncomment to run the test
-- test()

