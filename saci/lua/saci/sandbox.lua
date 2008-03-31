
module(...,package.seeall)

local Sandbox = {}
local Sandbox_mt = {__metatable = {}, __index = Sandbox}

function new(initial_values)
   local sandbox = setmetatable({}, Sandbox_mt)

   -- Create a table that allows us to define private functions
   -- while still pulling values from the initial_values table
   local private = setmetatable({}, {__index = initial_values})
   -- Now link the tables together to create the values table
   sandbox.values = setmetatable({}, {__index = private})

   -- Define a function that allow us to reset the protected environment
   -- from within a sandbox
   do
      local tbl = sandbox.values
      local pairs = pairs
      function private.reset()
         for k,v in pairs(tbl) do
            tbl[k] = nil
         end
      end
   end

   sandbox.returned_value = nil
   return sandbox
end

function Sandbox:add_values(symbol_table)
   for symbol, value in pairs(symbol_table) do
      self.values[symbol] = value
   end
end
   
function Sandbox:do_lua(lua_code)

   local f, err = loadstring(lua_code)      -- load the code into a function
   if f then 
      setfenv(f, self.values or {})         -- set a restricted environment
      local ok, result = pcall(f)           -- run it
      if ok then 
         self.returned_value = result 
      else
         err = result
      end
   end
     
   if err then                              -- check if something went wrong
      local error_report = {}
      local reg_exp = "^.+%]%:(%d+)%:"
      error_report.line_num = string.match(err, reg_exp)
      error_report.errors = string.gsub(err, reg_exp, "On line %1:")
      error_report.source = lua_code
      error_report.err = err
           
      if self.logger then
         self.logger:error("sputnik.luaenv: couldn't execute lua")
         self.logger:error("Source code: \n"..error_report.source)
         self.logger:error("environment: \n")
         for k,v in pairs(self.values) do
            self.logger:error(string.format("%s=%q", tostring(k), tostring(v)))
         end
         self.logger:error(err)
      end
      return nil, error_report
   else
      self.values = getfenv(f)         -- save the values
      return self.values               -- return them
   end
end

