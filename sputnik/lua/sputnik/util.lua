module(..., package.seeall)

---------------------------------------------------------------------------------------------------
-- Splits a string on a delimiter.  Adapted from http://lua-users.org/wiki/SplitJoin.
-- 
-- @param text           the text to be split.
-- @param delimiter      the delimiter.
-- @return               unpacked values.
---------------------------------------------------------------------------------------------------
function split(text, delimiter)
   local list = {}
   local pos = 1
   if string.find("", delimiter, 1) then 
      error("delimiter matches empty string!")
   end
   while 1 do
      local first, last = string.find(text, delimiter, pos)
      if first then -- found?
	 table.insert(list, string.sub(text, pos, first-1))
	 pos = last+1
      else
	 table.insert(list, string.sub(text, pos))
	 break
      end
   end
   return unpack(list)
end

---------------------------------------------------------------------------------------------------
-- Escapes a text for using in a text area.
-- 			
-- @param text           the text to be escaped.
-- @return               the escaped text.
---------------------------------------------------------------------------------------------------
function escape(text) 
   text = text or ""
   return text:gsub("&", "&amp;"):gsub(">","&gt;"):gsub("<","&lt;")
end

---------------------------------------------------------------------------------------------------
-- Escapes a URL.
-- 
-- @param text           the URL to be escaped.
-- @return               the escaped URL.
---------------------------------------------------------------------------------------------------
function escape_url(text) 
   return escape(text):gsub(" ","%%20")
end

---------------------------------------------------------------------------------------------------
-- Turns a string into something that can be used as a page name, converting convert ? + = % ' " / 
-- \ and spaces to '_'.  Note this isn't enought to ensure legal win2k names, since we _are_ 
-- allowing [ ] + < > : ; *, but we'll rely on versium to escape those later.
-- 
-- @param text           the string to be dirified.
-- @return               the dirified string.
---------------------------------------------------------------------------------------------------
function dirify(text)
   local pattern = [[[%?%+%=%%%s%'%"%/%\]+]]
   text = text or ""
   return text:gsub(pattern, "_")
end

---------------------------------------------------------------------------------------------------
-- Returns value1 if condition is true and value2 otherwise.  Note that if 
-- expressions are passed for value1 and value2, then they will be evaluated
-- _before_ the choice is made.
---------------------------------------------------------------------------------------------------
function choose(condition, value1, value2)
   if condition then
      return value1
   else
      return value2
   end
end
