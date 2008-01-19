
module("cosmo", package.seeall)


local StringBuffer = { content = {} } --------------------- StringBuffer class

function StringBuffer:new() 
   local o = {content={}}
   setmetatable(o, self)
   self.__index = self
   return o  
end

function StringBuffer:add(text) 
   self.content[#self.content + 1] = text
end

function StringBuffer:addf(template, ...) 
   self:add(string.format(template, ...))
end

function StringBuffer:to_string() 
   local output = ""
   for i, v in ipairs(self.content) do
	output = output .. v
      end
      return output
end
--- end of StringBuffer ------------------------------------------------------

function max_equals(text) 
   local max = ""
   string.gsub(text, "%[(=*)%[", function(match) 
                                    if max:len() < match:len() then
                                       max = match
                                    end
                                 end )
   return max
end


Cosmo = {}  -------------------------------------------------- Cosmo class ---

function Cosmo:expand(text, table, lazy)
   if not text then return "" end
   local lazify = function(value) 
      if lazy then return "" else return value end
   end
   text = string.gsub(text, "$([%w_]+)%[(=*)%[(.-)%]%2%]", -- $var_name[[...]]
                      function(fn_name, eqs, template) 
                         local iterator = table[fn_name]
                         if not iterator then
                            return lazify("$"..fn_name.."["..eqs.."]"..template.."["..eqs.."]")
                         elseif type(iterator) ~= "function"  then
                            error(string.format("Cosmo: %s not a function but %s",
                                  fn_name, type(iterator)))		   
                         else
                            return self:expand_items(template, iterator, fn_name)
                         end
                      end)
   text = string.gsub(text, "$([%w_]+)",                 -- $var_name
                      function(varname) 
                         local value = table[varname]
                         if not value then
                            return lazify("$"..varname)
                         elseif type(value) == "function" then
                            return tostring(value() or lazify("$"..varname))
                         else
                            return tostring(value)
                         end
                      end)
   return text
end

function Cosmo:expand_items(template, fn, fn_name)
   local buffer = StringBuffer:new()
   local co = coroutine.create(fn)
   while true do
      local status, value = coroutine.resume(co)
      if not status then
         error("Cosmo: the iterator for "..fn_name.." failed: "..value)
      end
      if not value then break end
      buffer:add(self:expand(template, value))
   end
   return buffer:to_string()
end

function Cosmo:expand_list(template, array, tablefn)
   local buffer = StringBuffer:new()
   for i, table in unpack(self:fpairs(array, tablefn)) do
      if table then
         buffer:add(self:expand(template, table))
      end
   end
   return buffer:to_string()
end

------ end of Cosmo

function cond (condition, table)
	return function()
		if condition then
		   coroutine.yield(table)
		end
	end
end

function c (condition)
   return function(table)
	   return cond(condition, table)
   end
end


function test_iterator(f)
   co = coroutine.create(f)
   while true do
      status, value = coroutine.resume(co)
      print(status, value)
      if not (status and value) then break end
   end
end

function lazy_fill(template, table) 
   return Cosmo:expand(template, table, true) 
end

function fill(template, table) 
   return Cosmo:expand(template, table) 
end

function f(template)
   return function(table) 
      return fill(template, table)
   end
end

yield = coroutine.yield -- so that clients could use "cosmo.yield"

__call = f
