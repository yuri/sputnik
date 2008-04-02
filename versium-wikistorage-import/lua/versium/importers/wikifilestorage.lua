module(..., package.seeall)

require("lfs")

starts_with = function(text, prefix) 
   if not prefix then return true end
   local preflen = prefix:len()
   return (    (text:len() >= preflen) 
	   and (text:sub(1, preflen) == prefix))
end




WikiFileStorage = {

   dir = "",

   ----------------------------------------------------------------------------
   -- Creates a new "storage" object
   -- 
   -- @params dir the directory where the files will be stored
   ----------------------------------------------------------------------------

   new = function(self, dir)

      local obj = {dir=dir, object_table={}}

      for x in lfs.dir(dir) do
	 if x:len() > 2 then
	    obj.object_table[x] = 1
	 end
      end

      setmetatable(obj, self)
      self.__index = self
      return obj         
   end,

   ----------------------------------------------------------------------------
   -- Return an object with a given id as a string.
   --
   -- @param version - the desired version of the object (defaults to current)
   -- @return the objct as a string
   ----------------------------------------------------------------------------

   load_object = function(self, id, version)
      local path = self.dir .. id .. "/" .. version
      local f = io.open(path)
      local raw = f:read("*all")
      f:close()
      return raw
   end,

   ----------------------------------------------------------------------------
   -- Return true or false depending on whether the object with this id
   -- exists
   -- 
   -- @param id - an id of an object
   --
   ----------------------------------------------------------------------------

   object_exists = function(self, id) 
      return self.object_table[id]
   end,

   ----------------------------------------------------------------------------
   -- Lists all object ids
   -- exists
   -- 
   ----------------------------------------------------------------------------

   list_object_ids = function(self, id)
      ids = {} 
      for id, _ in pairs(self.object_table) do
	 ids[#ids+1] = id
      end
      return ids
   end,

   ----------------------------------------------------------------------------
   -- Saves the object with the current file stamp
   --
   -- @data the value to save
   ----------------------------------------------------------------------------

   save_object = function(self, id, data)
      local path = self.dir .. id

      if not self:object_exists(id) then
         lfs.mkdir(path)
         self.object_table[id] = 1
      end
      local t = os.date("*t")
      timestamp = string.format("%02d-%02d-%02dT%02d-%02d-%02d", 
                                t.year, t.month, t.day,
                                t.hour, t.min, t.sec)
      local full_path = path .. "/" .. timestamp
      local f = io.open(full_path, "w")

      if not f then
	 error("\nWikiFileStorage: Can't open file for writing: " .. full_path)
      end

      f:write(data)
      f:close()
   end,

   ----------------------------------------------------------------------------
   -- Return the history of the object as a list of VERSIONS.
   -- The versions can be filtered by a prefix.
   --
   -- @param id the id of the object.
   ----------------------------------------------------------------------------

   get_object_history = function (self, id, prefix)
      prefix = prefix or ""
      local history = {}
      if self.object_table[id] then			 
	 for v in lfs.dir(self.dir .. id) do
	    if v:len() > 2 and tonumber(v:sub(1,4))
	       and starts_with(v, prefix) then
	       history[#history+1] = v
	    end
	 end
      end
      table.sort(history)
      return history
   end
}

open = function(dir) return WikiFileStorage:new(dir) end
