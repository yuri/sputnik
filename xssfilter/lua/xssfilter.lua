
function parseargs(s)
  local arg = {}
  string.gsub(s, "(%w+)=([\"'])(.-)%2", function (w, _, a)
    arg[w] = a
  end)
  return arg
end
    
function collect(s)
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
      table.insert(top, {label=label, xarg=parseargs(xarg), empty=1})
    elseif c == "" then   -- start tag
      top = {label=label, xarg=parseargs(xarg)}
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

XSSFilter = {}

ALLOWED_TAGS = {
   "ul", "ol", "li", "dl", "dt", "dd",
   "br", "em", "strong", "i", "b",
   "blockquote",
   "pre", "code",
   "acronym", "abbr", "cite", "dfn", "tt", "del", "ins", "kbd", "strike", "sub", "sup", "var",
   "table", "tr", "th", "thead", "td", "caption", "tbody", "tfoot", 

   a = {
      name = ".",
      href= {"http://", "ftp://"},
   }, 
   img = {
      src = "http://",
   },
   object = {
      data = "http://",
      _test = function(tag) 
         return tag.xarg.type=="image/svg+xml"
      end
   }
}

GENERIC_ATTRIBUTES = {
   class = ".",
   alt = ".",
   title = "."
}


function XSSFilter:new(args)
   args = args or {}
   local obj = {}
   setmetatable(obj, self)
   self.__index = self
   obj:init(args)
   return obj
end

function XSSFilter:init(args)
   self.allowed_tags = args.allowed_tags or ALLOWED_TAGS
   for i,v in ipairs(self.allowed_tags) do
      self.allowed_tags[v] = self.allowed_tags[v] or {}
   end
end

function XSSFilter:filter(html)
   local parsed = collect("<xml>"..html.."</xml>")

   local buffer = ""

   function xml2string(t)
      for i,child in ipairs(t) do
         if type(child) == "string" then
            buffer = buffer..child
         elseif type(child) == "table" then
            local taginfo = self.allowed_tags[child.label]
            if taginfo and (not taginfo._test or taginfo._test(child)) then
               buffer = buffer.."<"..child.label
               for k, v in pairs(child.xarg) do
                  if taginfo[k] then
                     if type(taginfo[k]) == "string" then taginfo[k] = {taginfo[k]} end
                     local ok
                     for j, pattern in ipairs(taginfo[k]) do
                        if v:find(pattern) then
                           ok = true
                        end
                     end
                     buffer = buffer.." "..k..'="'..v:gsub('"', "&quot;")..'"'
                  end
               end
               buffer = buffer..">"
               xml2string(child)
               buffer = buffer.."</"..child.label..">"
            else
               buffer = buffer.."&lt;"..child.label.." (removed)/&gt;"
            end
         else
            error("Unexpected type of field in parsed XML")
         end
      end
   end
   
   xml2string(parsed[2])
   return buffer   
end

xssf = XSSFilter:new()

print(xssf:filter[[

     This is just a <b>test</b>.  Really, no big <strong class='asdf("foo")'>deal</strong>.
     
     <ul>
      <li>ok?</li>
     </ul>

     And a little <script src="foo/bar"> </script>.

     <methodCall kind="xuxu">
      <methodName>  
examples.getStateName</methodName>
      <params>
         <param>
            <value><i4>41</i4></value>
            </param>
         </params>
      </methodCall>


]])
