---------------------------------------------------------------------------------------------------
-- Provides some utility functions for use by versium and its clients.
---------------------------------------------------------------------------------------------------

module(..., package.seeall)

---------------------------------------------------------------------------------------------------
-- Splits a string into tokens for diffing.
--
-- @param text           A string to be split.
-- @return               A list of tokens.
---------------------------------------------------------------------------------------------------
local function _diffsplit(text)
   assert(text)
   local l = {}
   local text = text.." "
   for token, sep in string.gmatch(text, "([^%s]*)(%s+)") do
      l[#l+1] = token
      l[#l+1] = sep
   end
   return l
end

---------------------------------------------------------------------------------------------------
-- Derives the longest common subsequence of two strings.  This is a faster implementation than one
-- provided by stdlib.  Submitted by Hisham Muhammad. 
-- The algorithm was taken from:
-- http://en.wikibooks.org/wiki/Algorithm_implementation/Strings/Longest_common_subsequence
--
-- @param t1             the first string.
-- @param t2             the second string.
-- @return               the least common subsequence as a matrix.
---------------------------------------------------------------------------------------------------
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

---------------------------------------------------------------------------------------------------
-- Returns a diff of two strings as a list of pairs, where the first value represents a token and 
-- the second the token's status ("same", "in", "out").
--
-- @param t1             The "old" text string
-- @param t1             The "new" text string
-- @return               A list of annotated tokens.
---------------------------------------------------------------------------------------------------
function diff(t2, t1)
   assert(t1)
   assert(t2)
   local t2 = _diffsplit(t2)
   local t1 = _diffsplit(t1)

   -- First, compare the beginnings and ends of strings to remove the common prefix and suffix.
   -- Chances are, there is only a small number of tokens in the middle that differ, in which case
   -- we can save ourselves a lot in terms of LCS computation.
   local prefix = "" -- common text in the beginning
   local suffix = "" -- common text in the end
   while t1[1] and t1[1] == t2[1] do
      local t = table.remove(t1, 1)
      table.remove(t2, 1)
      prefix = prefix..t
   end
   while t1[#t1] and t1[#t1] == t2[#t2] do
      local t = table.remove(t1)
      table.remove(t2)
      suffix = t..suffix
   end

   -- Setup a table that will store the diff (an upvalue for get_diff). We'll store it
   -- in the reverse order to allow for tail calls.
   local rev_diff = {
      IN   = "in",
      OUT  = "out",
      SAME = "same",
      put  = function(self, token, type) table.insert(self, {token,type}) end,
      ins  = function(self, token) self:put(token, self.IN) end,
      del  = function(self, token) self:put(token, self.OUT) end,
      same = function(self, token) self:put(token, self.SAME) end,
   }

   -- Put the suffix as the first token (we are storing the diff in the reverse order)
   rev_diff:same(suffix)

   -- Scan the LCS matrix backwards to build diff output.  Recurse.
   local function get_diff(C, t1, t2, i, j)
      local t1i = t1[i]
      local t2j = t2[j]
      if i >= 1 and j >= 1 and t1i == t2j then
         rev_diff:same(t1i)
         return get_diff(C, t1, t2, i-1, j-1)
      else
         local Cij1 = C[i][j-1]
         local Ci1j = C[i-1][j]
         if j >= 1 and (i == 0 or Cij1 >= Ci1j) then
            rev_diff:ins(t2j)
            return get_diff(C, t1, t2, i, j-1)
         elseif i >= 1 and (j == 0 or Cij1 < Ci1j) then
            rev_diff:del(t1i)
            return get_diff(C, t1, t2, i-1, j)
         end
      end
   end
   get_diff(quick_LCS(t1, t2), t1, t2, #t1 + 1, #t2 + 1)

   -- Put the prefix in at the end
   rev_diff:same(prefix)

   -- Reverse the text.
   local diff = {}
   for i = #rev_diff, 1, -1 do
      table.insert(diff, rev_diff[i])
   end
   return diff
end

