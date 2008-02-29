
module(...,package.seeall)

function make_sandbox(values)
   values = values or {}
   local returned_value = nil
   
   local function add_values(symbol_table)
      for symbol, value in pairs(symbol_table) do
         values[symbol] = value
      end
   end
   
   local function do_lua(lua)
   
      local f,err = loadstring(lua)
      if f then 
         setfenv(f, values)
         returned_value, err = f()
      end
         
      if err then
         local error_report = {}
         local reg_exp = "^.+%]%:(%d+)%:"
         error_report.line_num = string.match(err, reg_exp)
         error_report.errors = string.gsub(err, reg_exp, "On line %1:")
         error_report.source = lua
               
         if logger then
            logger:error("sputnik.luaenv: couldn't execute lua")
            logger:error("Source code: \n"..error_report.source)
            logger:error("environment: \n")
            for k,v in pairs(values) do
               logger:error(tostring(k)..": "..tostring(v))
            end
         end
         return nil, error_report
      else
         values = getfenv(f)
         return values
      end
   end
   return {
      values = values,
      add_values = add_values,
      do_lua = do_lua
   }
end

--local sandbox = make_sandbox{x=1}
--sandbox.add_values{y=2}
--sandbox.do_lua("z = x + y")
--print(sandbox.values.z)


