---------------------------------------------------------------------------------------------------
-- Provides easy facility for running Lua code in restricted environment and then getting 
-- the environment created by the code.
---------------------------------------------------------------------------------------------------

module(...,package.seeall)

Sandbox = {}
Sandbox.__index = Sandbox

---------------------------------------------------------------------------------------------------
-- Creates a new environment and initiates its locals to the given values.
--
-- @param values         initial values of the environment.
-- @param logger         a logger (optional)
-- @return               a new environment object.
---------------------------------------------------------------------------------------------------

function Sandbox:new(values, logger)
   local env = {}
   setmetatable(env, self)
   env.values = values or {}
   env.returned_value = nil
   env.logger = logger
   return env
end

---------------------------------------------------------------------------------------------------
-- Adds values to the environment.
--
-- @param values         values to be added.
-- @return               nothing.
---------------------------------------------------------------------------------------------------

function Sandbox:add_values(symbol_table)
   for symbol, value in pairs(symbol_table) do
      env.values[symbol] = value
   end
end

---------------------------------------------------------------------------------------------------
-- Executes Lua code in the environment.
--
-- @param lua            Lua code to be executed.
-- @return               the values at the end of the execution or nil and an error report.
---------------------------------------------------------------------------------------------------

function Sandbox:do_lua(lua)
   local f,err = loadstring(lua)
   if f then 
      setfenv(f, env.values)
      env.returned_value, err = f()
   end
         
   if err then
      local error_report = {}
      local reg_exp = "^.+%]%:(%d+)%:"
      error_report.line_num = string.match(err, reg_exp)
      error_report.errors = string.gsub(err, reg_exp, "On line %1:")
      error_report.source = lua
               
      if self.logger then
         self.logger:error("sputnik.luaenv: couldn't execute lua")
         self.logger:error("Source code: \n"..error_report.source)
         self.logger:error("environment: \n")
         for k,v in pairs(values) do
            self.logger:error(tostring(k)..": "..tostring(v))
         end
      end
      return nil, error_report
   else
      values = getfenv(f)
         return values
      end
   end
end


--local sandbox = Sandbox{x=1}
--sandbox:add_values{y=2}
--sandbox:do_lua("z = x + y")
--print(sandbox.values.z)


