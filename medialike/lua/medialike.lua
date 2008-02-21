
module("medialike", package.seeall)

---------- Utility functions ----------

-- Splits the text into an array of separate lines.
-- (from markdown.lua)
local function split(text, sep)
   sep = sep or "\n"
   local lines = {}
   local pos = 1
   while true do
      local b,e = text:find(sep, pos)
      if not b then table.insert(lines, text:sub(pos)) break end
      table.insert(lines, text:sub(pos, b-1))
      pos = e + 1
   end
   return lines
end

-- Applies string.find for every pattern in the list and returns which was
-- the first matching pattern in the list and the search results
-- (adapted, from markdown.lua)
function find_first(s, patterns, index)
   local res = {}
   local whichpat = 0
   for i,p in ipairs(patterns) do
      local match = {s:find(p, index)}
      if #match>0 and (#res==0 or match[1] < res[1]) then
         res = match
         whichpat = i
      end
   end
   return patterns[whichpat], unpack(res)
end

---------- Span-level formatting ----------

local function tag_a(url, name)
   return '<a href="'..url..'">'..name..'</a>'
end

local mark_pattern = "''+"
local wiki_pattern = "%[%[([^%]]*)%]%](%a*)"
local nowiki_pattern = "<nowiki>(.-)</nowiki>"
local ref_pattern = "<ref>(.-)</ref>"
local references_pattern = "<references/?>"
local link_pattern = "%[([^%]]*)%](%a*)"

local wiki_patterns={
   mark_pattern,
   wiki_pattern,
   ref_pattern,
   references_pattern,
   nowiki_pattern,
   link_pattern
}

local function format_span(output, input)
   local input = input or ""
   local at = 1
   local in_bold = false
   local in_italic = false
   local result = {}
   while true do
      local which, start, finish, match, extra = find_first(input, wiki_patterns, at)
      if which then
         table.insert(result, input:sub(at, start - 1))
      end
      if which == mark_pattern then
         local len = finish - start + 1
         if len == 3 or len == 5 then
            if in_bold then
               table.insert(result, "</b>")
            else
               table.insert(result, "<b>")
            end
            in_bold = not in_bold
         end
         if len == 2 or len == 5 then
            if in_italic then
               table.insert(result, "</i>")
            else
               table.insert(result, "<i>")
            end
            in_italic = not in_italic
         end
      elseif which == wiki_pattern then
         table.insert(result, output.wikilink(match, extra))
      elseif which == ref_pattern then
         table.insert(output.references, match)
         local id = tostring(#output.references)
         table.insert(result, '<sup><a href="#_ref-'..id..'">['..id..']</a></sup>')
      elseif which == references_pattern then
         table.insert(result, '<ol class="references">\n')
         for i, ref in ipairs(output.references) do
            local id = tostring(i)
            table.insert(result, '<li id="_note-'..id..'"><a href="#_ref-'..id..'" title="">&uarr;</a>')
            table.insert(result, format_span(output, ref))
            table.insert(result, '</li>\n')
         end
         table.insert(result, '</ol>\n')
      elseif which == nowiki_pattern then
         table.insert(result, (match:gsub("([<>&])", {["<"] = "&lt;", [">"] = "&gt;", ["&"] = "&amp;"})))
      elseif which == link_pattern then
         local _, _, url, name = match:find("^([^ ]+) (.*)$")
         if url then
            if extra then name = name .. extra end
            table.insert(result, tag_a(url, name))
         else
            name = extra and (match .. extra) or match
            table.insert(result, tag_a(match, name))
         end
      else
         table.insert(result, input:sub(at))
         break
      end
      at = finish + 1
   end
   if in_italic then
      table.insert(result, "</i>")
   end
   if in_bold then
      table.insert(result, "</b>")
   end
   return table.concat(result)
end

---------- Block-level formatting ----------

local push = table.insert
local pop = table.remove

block_tags = {
   ["*"] = "ul",
   ["#"] = "ol",
   [";"] = "dl",
   [":"] = "dl"
}

function close_blocks(output, at)
   local blocks = output.blocks
   for i = #blocks, at, -1 do
      table.insert(output.pending_blocks, "</"..blocks[i]..">")
      table.remove(blocks, i)
   end
end

function check_blocks(output, line, at)
   local blocks = output.blocks
   local ch = line:sub(at, at)
   local block_tag = block_tags[ch]
   if block_tag then
      local current_block = blocks[at]
      if not current_block then
         table.insert(blocks, block_tag)
         table.insert(output.pending_blocks, "<"..block_tag..">")
      elseif current_block ~= block_tag then
         close_blocks(output, at)
         table.insert(blocks, block_tag)
         table.insert(output.pending_blocks, "<"..block_tag..">")
      end
      return check_blocks(output, line, at + 1)
   else
      close_blocks(output, at)
      return at
   end
end

heading_tags={ "h1", "h2", "h3", "h4", "h5" }

function open_if_not(output, tag)
   local tags = output.tags
   if tags[#tags] ~= tag then
      table.insert(output, "<"..tag..">")
      push(tags, tag)
   end
end

function close_if(output, tag)
   local tags = output.tags
   curr = tags[#tags]
   if curr == tag then
      table.insert(output, "</"..tag..">")
      pop(tags)
   end
end

function output_cell(output, tag, line)
   close_if(output, tag)
   local datastart, datafinish, data = line:find("^(.*)|")
   if data then
      table.insert(output, "<"..tag.." "..data..">"..format_span(output, line:sub(datafinish+1)))
   else
      table.insert(output, "<"..tag..">"..format_span(output, line))
   end
   push(output.tags, tag)
end

--- This function generates HTML markup
function handle_content(output, tag, content)
   local tags = output.tags
   local curr = tags[#tags]
   if (tag ~= "p" and #output.paragraph > 0) or tag == "/p" then
      table.insert(output, "<p>"..format_span(output, output.paragraph) .. "</p>")
      output.paragraph = ""
   end
   if #output.pending_blocks > 0 then
      for _, block in ipairs(output.pending_blocks) do
         table.insert(output, block)
      end
      output.pending_blocks = {}
   end
   if tag == "pre" then
      open_if_not(output, "pre")
      table.insert(output, content)
   else
      close_if(output, "pre")
   end
   if tag == "p" then
      output.paragraph = output.paragraph .. content .. " "
   elseif tag == "dt" or tag == "dd" or tag == "li" or tag:find("^h[12345]$") then
      table.insert(output, "<"..tag..">"..format_span(output, content) .. "</"..tag..">")
   elseif tag == "table" then
      table.insert(output, "<table "..content..">")
      push(tags, "table")
   elseif tag == "tr" then
      close_if(output, "tr")
      table.insert(output, "<tr "..content..">")
      push(tags, "tr")
   elseif tag == "/table" then
      close_if(output, "td")
      close_if(output, "tr")
      close_if(output, "table")
      table.insert(output, "</table>")
   elseif tag == "td" or tag == "th" then
      close_if(output, "td")
      close_if(output, "th")
      open_if_not(output, "tr")
      output_cell(output, tag, content)
   elseif tag == "hr" then
      table.insert(output, "<hr/>")
   end
end

function strip_templates(input)
   local result = {}
   local at = 1
   while true do
      local start, finish = input:find("%b{}", at)
      if start then
         if input:sub(start, start+1) == "{{" and input:sub(finish-1, finish) == "}}" then
            table.insert(result, input:sub(at, start - 1))
            at = finish + 1
         else
            table.insert(result, input:sub(at, start))
            at = start + 1
         end
      else
         table.insert(result, input:sub(at))
         break
      end
   end
   return table.concat(result)
end

--- This function detects block-level MediaLike markup
function format_content(input, wikilink_fn)
   input = strip_templates(input)
   local lines = split(input)
   local output = {}
   output.blocks = {}
   output.tags = { "p" }
   output.references = {}
   output.pending_blocks = {}
   output.wikilink = wikilink_fn
   local blocks = output.blocks
   local tags = output.tags
   output.paragraph = ""
   for _, line in ipairs(lines) do
      local all = line
      local start = check_blocks(output, line, 1)
      line = line:sub(start)

      local current_tag = tags[#tags]
      local current_block = blocks[#blocks]
      if all:match("^ +[^ ]") or (current_tag == "pre" and all:match("^ ")) then
         handle_content(output, "pre", all:sub(2))
      elseif current_block == "dl" then
         local current_item = all:sub(start-1, start-1)
         if current_item == ";" then
            handle_content(output, "dt", line)
         else
            handle_content(output, "dd", line)
         end
      elseif current_block == "ul" or current_block == "ol" then
         handle_content(output, "li", line)
      elseif line:find("^%{%|") then
         handle_content(output, "table", line:sub(3))
      elseif line:find("^%|%-") then
         handle_content(output, "tr", line:sub(3))
      elseif line:find("^%|%}") then
         handle_content(output, "/table")
      elseif line:find("^%|") then
         for _, cell in ipairs(split(line:sub(2), "||")) do
            handle_content(output, "td", cell)
         end
      elseif line:find("^%!") then
         for _, cell in ipairs(split(line:sub(2), "!!")) do
            handle_content(output, "th", cell)
         end
      elseif line:find("^%-%-%-%-") then
         handle_content(output, "hr")
      elseif line:find("^=") then
         local marks, heading, closing_marks = line:match("^(=+)(.*[^=])(=+)%s*$")
         local tag = heading_tags[#marks]
         if not tag then tag = "h5" end
         handle_content(output, tag, heading)
      elseif current_tag == "p" and line:find("^%s*$") then
         handle_content(output, "/p")
      else
         handle_content(output, "p", line)
      end
   end
   handle_content(output, "")
   content = table.concat(output, "\n")
   return content
end
