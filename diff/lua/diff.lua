-----------------------------------------------------------------------------
-- Provides functions for diffing text.
--
-- (c) 2007, 2008  Yuri Takhteyev (yuri@freewisdom.org)
-- (c) 2007 Hisham Muhammad
--
-- License: MIT/X, see http://sputnik.freewisdom.org/en/License
-----------------------------------------------------------------------------

module(..., package.seeall)

SKIP_SEPARATOR = true  -- a constant

IN   = "in"; OUT  = "out"; SAME = "same"  -- token statuses

-----------------------------------------------------------------------------
-- Split a string into tokens.  (Adapted from Gavin Kistner's split on
-- http://lua-users.org/wiki/SplitJoin.
--
-- @param text           A string to be split.
-- @param separator      [optional] the separator pattern (defaults to any
--                       white space - %s+).
-- @param skip_separator [optional] don't include the sepator in the results.     
-- @return               A list of tokens.
-----------------------------------------------------------------------------
function split(text, separator, skip_separator)
   separator = separator or "%s+"
   local parts = {}  
   local start = 1
   local split_start, split_end = text:find(separator, start)
   while split_start do
      table.insert(parts, text:sub(start, split_start-1))
      if not skip_separator then
         table.insert(parts, text:sub(split_start, split_end))
      end
      start = split_end + 1
      split_start, split_end = text:find(separator, start)
   end
   if text:sub(start)~="" then
      table.insert(parts, text:sub(start) )
   end
   return parts
end


-----------------------------------------------------------------------------
-- Derives the longest common subsequence of two strings.  This is a faster
-- implementation than one provided by stdlib.  Submitted by Hisham Muhammad. 
-- The algorithm was taken from:
-- http://en.wikibooks.org/wiki/Algorithm_implementation/Strings/Longest_common_subsequence
--
-- @param t1             the first string.
-- @param t2             the second string.
-- @return               the least common subsequence as a matrix.
-----------------------------------------------------------------------------
function quick_LCS(t1, t2)
   local m = #t1
   local n = #t2

   -- Build matrix on demand
   local C = {}
   local setmetatable = setmetatable
   local mt_tbl = {
      __index = function(t, k)
         t[k] = 0
         return 0
      end
   }
   local mt_C = {
      __index = function(t, k)
         local tbl = {}
         setmetatable(tbl, mt_tbl)
         t[k] = tbl
         return tbl
      end
   }
   setmetatable(C, mt_C)
   local max = math.max
   for i = 1, m+1 do
      local ci1 = C[i+1]
      local ci = C[i]
      for j = 1, n+1 do
         if t1[i-1] == t2[j-1] then
            ci1[j+1] = ci[j] + 1
         else
            ci1[j+1] = max(ci1[j], ci[j+1])
         end
      end
   end
   return C
end



-----------------------------------------------------------------------------
-- Escapes an HTML string.
--
-- @param text           The string to be escaped.
-- @return               Escaped string.
-----------------------------------------------------------------------------
function escape_html(text)
   text = text:gsub("&", "&amp;"):gsub(">","&gt;"):gsub("<","&lt;")
   text = text:gsub("\"", "&quot;")
   return text
end


-----------------------------------------------------------------------------
-- Formats an inline diff as HTML, with <ins> and <del> tags.
-- 
-- @param tokens         a table of {token, status} pairs.
-- @return               an HTML string.
-----------------------------------------------------------------------------
function format_as_html(tokens)
   local diff_buffer = ""
   local token, status
   for i, token_record in ipairs(tokens) do
      token = escape_html(token_record[1])
      status = token_record[2]
      if status == "in" then
         diff_buffer = diff_buffer.."<ins>"..token.."</ins>"
      elseif status == "out" then
         diff_buffer = diff_buffer.."<del>"..token.."</del>"
      else 
         diff_buffer = diff_buffer..token
      end
   end
   return diff_buffer
end

-----------------------------------------------------------------------------
-- Returns a diff of two strings as a list of pairs, where the first value
-- represents a token and the second the token's status ("same", "in", "out").
--
-- @param old             The "old" text string
-- @param new             The "new" text string
-- @param separator      [optional] the separator pattern (defaults ot any
--                       white space).
-- @return               A list of annotated tokens.
-----------------------------------------------------------------------------
function diff(old, new, separator)
   assert(old); assert(new)
   new = split(new, separator); old = split(old, separator)

   -- First, compare the beginnings and ends of strings to remove the common
   -- prefix and suffix.  Chances are, there is only a small number of tokens
   -- in the middle that differ, in which case  we can save ourselves a lot
   -- in terms of LCS computation.
   local prefix = "" -- common text in the beginning
   local suffix = "" -- common text in the end
   while old[1] and old[1] == new[1] do
      local token = table.remove(old, 1)
      table.remove(new, 1)
      prefix = prefix..token
   end
   while old[#old] and old[#old] == new[#new] do
      local token = table.remove(old)
      table.remove(new)
      suffix = token..suffix
   end

   -- Setup a table that will store the diff (an upvalue for get_diff). We'll
   -- store it in the reverse order to allow for tail calls.  We'll also keep
   -- in this table functions to handle different events.
   local rev_diff = {
      put  = function(self, token, type) table.insert(self, {token,type}) end,
      ins  = function(self, token) self:put(token, IN) end,
      del  = function(self, token) self:put(token, OUT) end,
      same = function(self, token) if token then self:put(token, SAME) end end,
   }

   -- Put the suffix as the first token (we are storing the diff in the
   -- reverse order)

   rev_diff:same(suffix)

   -- Define a function that will scan the LCS matrix backwards and build the
   -- diff output recursively.
   local function get_diff(C, old, new, i, j)
      local old_i = old[i]
      local new_j = new[j]
      if i >= 1 and j >= 1 and old_i == new_j then
         rev_diff:same(old_i)
         return get_diff(C, old, new, i-1, j-1)
      else
         local Cij1 = C[i][j-1]
         local Ci1j = C[i-1][j]
         if j >= 1 and (i == 0 or Cij1 >= Ci1j) then
            rev_diff:ins(new_j)
            return get_diff(C, old, new, i, j-1)
         elseif i >= 1 and (j == 0 or Cij1 < Ci1j) then
            rev_diff:del(old_i)
            return get_diff(C, old, new, i-1, j)
         end
      end
   end
   -- Then call it.
   get_diff(quick_LCS(old, new), old, new, #old + 1, #new + 1)

   -- Put the prefix in at the end
   rev_diff:same(prefix)

   -- Reverse the diff.
   local diff = {}

   for i = #rev_diff, 1, -1 do
      table.insert(diff, rev_diff[i])
   end
   diff.to_html = format_as_html
   return diff
end



