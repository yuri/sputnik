module("cosmo", package.seeall)

---------------------------------------------------------------------------------------------------
-- Expands a template with the values supplied as a table.
--
-- @param text           The template.
-- @param table          The values to fill in.
-- @param lazy           A flag to determine whether unfilled fields should be removed (lazy==True)
--                       or left as is.
-- @return               Filled template as a string.
---------------------------------------------------------------------------------------------------

function fill(text, table, lazy)
   text = text or "" --if not text then return "" end
   assert(type(table)=="table", "the second parameter to cosmo.fill should be a table")
   local function lazify(pattern)
      return (lazy and "") or pattern -- hide unfilled keys in "lazy" mode
   end

   -- First, setup a function to later use with gsub to handle subtemplates
   local function do_subtemplate (match, key, eqs, template, template2, template3)
      if not table[key] then return lazify(match) end -- check if there is a value to work with
      local coro = function_or_table_to_coroutine(table[key]) -- turn this value into a coroutine
      assert(coro, "Cosmo: "..key.." is neither a table, nor a function but "..type(key))
      -- create a function for selecting the template (out of possible three)
      local function get_template(values)
         if values._template == 2 then return template2
         elseif values._template == 3 then return template3
         else return template
         end
      end
      -- now iterate over the items using the coroutine   
      local buffer = ""
      while true do -- until the coroutine stops yielding
         local status, values = coroutine.resume(coro)
         assert(status, "Cosmo: the iterator for "..key.." failed: "..tostring(values))
         if values then
            buffer=buffer..fill(get_template(values), values, lazy) -- yes, recursion
         else
            return buffer
         end
      end
   end

   -- Now we are ready to deal with our template.     
   -- First handle the more complicated case of subtemplates - things like -- $key[[...]]
   -- (Here we'll be using the local function defined above.)  We'll first check for fields with
   -- three subtemplates ($key[[...]],[[...]],[[...]]), then with two, then with just one
   local single_template = "$([%w_]+)%[(=*)%[(.-)%]%3%]"
   local extra_template = ",%s*%[%3%[(.-)%]%3%]"
   text = string.gsub(text, "("..single_template..extra_template..extra_template..")", do_subtemplate)
   text = string.gsub(text, "("..single_template..extra_template..")", do_subtemplate)
   text = string.gsub(text, "("..single_template..")", do_subtemplate)

   -- now do the simple fields ( $key )
   text = string.gsub(text, "($([%w_]+))",
                      function(match, key)
                         local t=type(table[key]) 
                         if t=="nil" then return lazify(match)
                         elseif t=="function" then return table[key]()
                         else return tostring(table[key])
                         end
                      end)
   return text
end

---------------------------------------------------------------------------------------------------
-- Returns a coroutine that iterates over a yielding function or a table.
---------------------------------------------------------------------------------------------------
function function_or_table_to_coroutine(value)
   if type(value) == "table" then -- if we got a table, make a courotine that iterates over it
      return coroutine.create(function() 
                                 for i,v in ipairs(value) do coroutine.yield(v) end 
                              end)
   elseif type(value) == "function" then -- if it's a function, use as is
      return coroutine.create(value)
   else -- anything else is bad
      return nil 
   end
end

---------------------------------------------------------------------------------------------------
-- Same as fill() but skips unfilled keys.
---------------------------------------------------------------------------------------------------
function lazy_fill(template, table) 
   return fill(template, table, true) 
end

---------------------------------------------------------------------------------------------------
-- A "shortcut" for fill(), which returns a function to which the table can be then passed.
---------------------------------------------------------------------------------------------------
function f(template)
   return function(table) 
      return fill(template, table)
   end
end

---------------------------------------------------------------------------------------------------
-- Yields a set of values if a condition is satisfied.
---------------------------------------------------------------------------------------------------
function cond (condition, values)
	return function()
		if condition then coroutine.yield(values) end
	end
end

---------------------------------------------------------------------------------------------------
-- A "shortcut" for cond(), which returns a function to which the table can be then passed.
---------------------------------------------------------------------------------------------------
function c (condition)
   return function(table) return cond(condition, table) end
end

yield = coroutine.yield -- so that clients could use "cosmo.yield"
