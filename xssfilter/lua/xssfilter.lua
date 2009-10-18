-----------------------------------------------------------------------------
-- Filters XHTML removing all tags that are not explicitly allowed.
--
-- The function parse_xml() is adapted from Roberto Ierusalmischy's collect()
-- (see http://lua-users.org/wiki/LuaXml).
--
-- (c) 2007, 2008  Yuri Takhteyev (yuri@freewisdom.org)
-- 
-- License: MIT/X, see http://sputnik.freewisdom.org/en/License
-----------------------------------------------------------------------------

module(..., package.seeall)

local iconv_loaded, iconv = pcall(require, "iconv")

-----------------------------------------------------------------------------
-- Default configuration of which tags are allowed.  The client can override
-- this by passing their own table.  The table allows two types of entries:
-- simply entering the name of the tag as string, allows this tag to be used
-- but without any attributes, except for those attributes listed in
-- GENERIC_ATTRIBUTES and allowed for _all_ tags.  Alternatively, the tag can
-- be entered as a table, keyed with the tag name, which can specify what 
-- attributes the tag can have, specifying for each attribute the pattern
-- with which its values must start (use "." to allow _any_ values).  
-- Additionally, _test can be set to a function that does a more complex
-- evaluation of whether the tag's attributes should be allowed.
--
-- @see GENERIC_ATTRIBUTES
-----------------------------------------------------------------------------

ALLOWED_TAGS = {

   -- Simple tags allowed without any attributes other than those listed in
   -- GENERIC_ATTRIBUTES
   "p",
   "h1", "h2", "h3", "h4", "h5", "h6",
   "ul", "ol", "li", "dl", "dt", "dd",
   "br", "em", "strong", "i", "b",
   "blockquote",
   "pre", "code",
   "acronym", "abbr", "cite", "dfn", "tt", "del", "ins", "kbd", "strike",
   "sub", "sup", "var",
   "table", "tr", "thead", "caption", "tbody", "tfoot",
   "big", "center", "right", "left",
   "hr",
   "style",
   "div",
   -- For "a" tag allow "name" and "href", and limit href to three protocols.
   a = {
      name = ".",
      href= {"^http://", "^https://", "^ftp://", "^mailto:", "^/", "#"},
   },
   -- For "img" tag allow only "src" and limit it to http.
   img = {
      src = {"^http://", "^/"},
   },
   -- Style is allowed on "span" as long as the string "url" does not occur
   -- in the value
   span = {
      style=".",
      _test = function(tag)
         if not tag.xarg.style or not tag.xarg.style:find("url") then
            return true
         else
            return nil, "'url' not allowed in the value of 'style'"
         end
      end
   },
   -- Enable the colspan/rowspan attributes for table elements
   th = {
	   colspan = ".",
	   rowspan = ".",
   },
   td = {
	   colspan = ".",
	   rowspan = ".",
   }
}

-----------------------------------------------------------------------------
-- Extra tags (disabled by default), allow then at your own risk.
-----------------------------------------------------------------------------
EXTRA_TAGS = {
   -- Allow "object" if the it's type is "image/svg+xml" (not that this could
   -- be overriden by setting "filter.allowed_tags.object = false"
   object = {
      data = "http://",
      _test = function(tag)
         if tag.xarg.type=="image/svg+xml" then
            return true
         else
            return false, "only 'image/svg+xml' is allowed for 'type'"
         end
      end
   }
}

-----------------------------------------------------------------------------
-- Specifies which attributes are allowed for _all_ tags.  This table should
-- probably be limited to "class", "alt" and "title".
-----------------------------------------------------------------------------
GENERIC_ATTRIBUTES = {
 	class = ".",
 	alt = ".",
 	title = ".",
}

-----------------------------------------------------------------------------
-- The class table for the XSS Filter.
-----------------------------------------------------------------------------

local XSSFilter = {}
local XSSFilter_mt = {__metatable = {}, __index = XSSFilter}

-----------------------------------------------------------------------------
-- Creates a new instance of XSSFilter.
--
-- @param allowed_tags   [optional] a table specifying which tags are allowed
--                       (defaults to ALLOWED_TAGS).
-- @param generic_attrs  [optional] a table specifying generic attributes
--                       (defaults to GENERIC_ATTRIBUTES).
-- @return               a new instance of XSSFilter.
-----------------------------------------------------------------------------      
function new(allowed_tags, generic_attrs)
   local obj = setmetatable({}, XSSFilter_mt)
   obj:init(allowed_tags)
   if iconv_loaded then
      obj.utf8_converter = iconv.new("UTF8", "UTF8")
   end

   return obj
end

-----------------------------------------------------------------------------
-- Initializes the new instance of XSSFilter.  This function is called by
-- new() and does not need to be called by the client.
--
-- @param allowed_tags   [optional] a table specifying which tags are allowed
--                       (defaults to ALLOWED_TAGS).
-- @param generic_attrs  [optional] a table specifying generic attributes
--                       (defaults to GENERIC_ATTRIBUTES).
-----------------------------------------------------------------------------
function XSSFilter:init(allowed_tags, generic_attrs)
   args = args or {}
   self.allowed_tags = allowed_tags or ALLOWED_TAGS
   for i,v in ipairs(self.allowed_tags) do
      self.allowed_tags[v] = self.allowed_tags[v] or {}
   end
   self.generic_attributes = generic_attrs or GENERIC_ATTRIBUTES
end

-----------------------------------------------------------------------------
-- Parses simple XML.  Adapted from from Roberto Ierusalmischy's collect()
-- (see http://lua-users.org/wiki/LuaXml).
--
-- @param xml            XML as a string.
-- @return               A table representing the tags.
-----------------------------------------------------------------------------
local function parse_xml(s)

   --- An auxiliary function to parse tag's attributes
   local function parse_attributes(s)
      local arg = {}
         string.gsub(s, "(%w+)=([\"'])(.-)%2", function (w, _, a)
         arg[w] = a
         end)
      return arg
   end

   local stack = {}
   local top = {}
   table.insert(stack, top)
   local ni,c,label,xarg, empty
   local i, j = 1, 1
   while true do
      ni,j,c,label,xarg, empty = string.find(s, "<(%/?)(%w+)(.-)(%/?)>", i)
      if not ni then break end
      local text = string.sub(s, i, ni-1)
      --if not string.find(text, "^%s*$") then
      table.insert(top, text)
      --end
      if empty == "/" then  -- empty element tag
         table.insert(top, {label=label, xarg=parse_attributes(xarg), empty=1})
      elseif c == "" then   -- start tag
         top = {label=label, xarg=parse_attributes(xarg)}
         table.insert(stack, top)   -- new level
      else  -- end tag
         local toclose = table.remove(stack)  -- remove top
         top = stack[#stack]
         if #stack < 1 then
            error("nothing to close with "..label)
         end
         if toclose.label ~= label then
            error("trying to close "..toclose.label.." with "..label)
         end
         table.insert(top, toclose)
      end
      i = j+1
   end
   local text = string.sub(s, i)
   if not string.find(text, "^%s*$") then
      table.insert(stack[stack.n], text)
   end
   if #stack > 1 then
      error("unclosed "..stack[stack.n].label)
   end
   return stack[1]
end

--x--------------------------------------------------------------------------
-- An auxiliary function to match a value against a list of patterns.
-----------------------------------------------------------------------------
local function find_match(value, patterns)
   patterns = patterns or {}
   if type(patterns) == "string" then patterns = {patterns} end
   for _, pattern in ipairs(patterns) do
      if value:find(pattern) then return true end
   end
end

local function dummy_test()
   return true
end

-----------------------------------------------------------------------------
-- Filters (X)HTML.  The input must be valid XML, without doctype and
-- document element.  It doesn't not need to be specifically XHTML 1.x, in
-- the sense that no specific schema is expected.
--
-- @param html           An HTML string that must parse as valid XML if <xml>
--                       is appended to it on both sides.
-- @return               A string with all but the allowed tags removed.
-----------------------------------------------------------------------------
function XSSFilter:filter(html)

   if self.utf8_converter then
       out, err = self.utf8_converter:iconv(html)
       if err then
          html = "[Invalid UTF8 - removed by XSSFilter]"
       end
   end

   local status, parsed = pcall(parse_xml, "<xml>"..html.."</xml>")
   if not status then
      return nil, "XSSFilter could not parse (X)HTML:\n"..html:gsub("<", "&lt;"):gsub(">", "&gt;")
   end

   local buffer = ""

   -- this function is called recursively on all nodes
   function xml2string(t)
      for i,child in ipairs(t) do
         if type(child) == "string" then
            buffer = buffer..child
         elseif type(child) == "table" then
            local taginfo = self.allowed_tags[child.label]
            if not taginfo then
               buffer = buffer..self:get_replacement(child.label, "not allowed")
            else
               local test_result, why_not =  (taginfo._test or dummy_test)(child)
               if not test_result then
                  buffer = buffer..self:get_replacement(child.label, why_not)
               else
                  -- ok, let's put the tag in
                  -- we might still strip some attributes, but silently
                  buffer = buffer.."<"..child.label
                  for attr, value in pairs(child.xarg) do
                     local patterns = taginfo[attr] or self.generic_attributes[attr] or {}
                     if find_match(value, patterns) then
                        buffer = buffer.." "..attr..'="'..value:gsub('"', "&quot;")..'"'
                     end
                  end
                  buffer = buffer..">"
                  xml2string(child)
                  buffer = buffer.."</"..child.label..">"
               end
            end
         else
            error("XSSFilter: Unexpected type of field in parsed XML")
         end
      end
   end
   -- call the xml2string() function on the first top node.
   xml2string(parsed[2])
   return buffer   
end

-----------------------------------------------------------------------------
-- Returns HTML to be used for replacing bad tags.
--
-- @param tag            tag name.
-- @param message        [optional] an explanation for why the tag was removed.
-- @return               replacement HTML.
-----------------------------------------------------------------------------
function XSSFilter:get_replacement(tag, message)
   local buffer = "<code>[HTML tag &lt;"..tag.."&gt; removed"
   if message then
      buffer = buffer..": "..message
   end
   return buffer.."]</code>"
end

--x--------------------------------------------------------------------------
-- A simple test function.
-----------------------------------------------------------------------------
local function test()
   local xssf = new()

   print(xssf:filter[[

     This is just a <b>test</b>.  Really, no big <strong class='asdf("foo")'>deal</strong>.
     
     <ul>
      <li>ok?</li>
     </ul>

     And a little <script src="foo/bar"> </script>.

     <methodCall kind="xuxu">
      <methodName>examples.getStateName</methodName>
      <params>
         <param>
            <value><i4>41</i4></value>
            </param>
         </params>
      </methodCall>
   ]])
end
