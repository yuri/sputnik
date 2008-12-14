module(..., package.seeall)

require("sfoto")

local Gridder = {}
local Gridder_mt = {__metatable = {}, __index = Gridder}

function new(node, photo_url, sputnik)
   return setmetatable({node=node, photo_url=photo_url, sputnik=sputnik}, Gridder_mt)
end


-----------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------
function Gridder:parse_flexrow(row_code)
   local row = {}
   local i = 0
   row_code:gsub("[^\n]+",
                 function(item)
                    i = i + 1
                    if item~="" and item:sub(1,3) ~= "---" then
                       if item:sub(1,1) ~= "x" then
                          item = "x1 "..item
                       end
                       local size, id, title = item:match("(%w*) ([^%s]*)(.*)")
                       row[i] = {item=item, id=id, size=tonumber(size:sub(2)), title=title}
                    else
                       row[i] = {}
                    end
                 end)
   table.insert(self.rows, row)
end

-----------------------------------------------------------------------------
-- A more flexible way to express a grid 
--
-- @param row            A string representing the image grid
-- @return               An HTML string
-----------------------------------------------------------------------------
function Gridder:flexgrid(image_code)
   -- first convert the string representing the images into a table of rows
   local buffer = ""

   self.rows = {}
   image_code:gsub("[^~]+", function (row) self:parse_flexrow(row) end)

   for i, row in ipairs(self.rows) do
      for j, photo in ipairs(row) do
         buffer = buffer .. (photo.id or "x").."\n"
      end
   end

   -- first figure out the total height of the grid in pixels
   local total_height = 0
   for i, row in ipairs(self.rows) do
      total_height = total_height + 8 + (#row==6 and 150 or 100)
   end

   -- a function to add "px" to ints
   local function pixify(value) 
      return string.format("%dpx", value)
   end

   -- we'll be positioning each photo individually, so we are making a single
   -- list of photos rather than assembling "rows"
   local photos = {}
   local width, dwidth, height
   local y = 2
   for i, row in ipairs(self.rows) do
      if #row == 6 then
         width, dwidth, height = 100, 6, 150
      else
         width, dwidth, height = 150, 10, 100
      end
      local x = 2
      for i = 1,#row do 
         photo = row[i]
         if photo and photo.id then
            local album, image = photo.id:gmatch("(.*)/(.*)") --util.split(photo.id, "/")
            photo.size = photo.size or 1
            table.insert(photos, {
               width      = pixify(width*photo.size + dwidth*(photo.size-1)),
               height     = pixify(height*photo.size + 8*(photo.size-1)),
               left       = pixify(2 + (width + dwidth) * (i-1)),
               top        = pixify(y),
               title      = photo.title or "",               
               photo_url  = sfoto.photo_url("photos/"..photo.id, 
                                            photo.size>1 and string.format("%dx", photo.size) or "thumb"),
               link       = self.sputnik:make_url("albums/"..photo.id),
            })
         end
      end
      y = y + height + 8
   end

   return cosmo.f(self.node.templates.MIXED_ALBUM){
             do_photos  = photos,
             height = total_height
          }
end

function Gridder:add_flexgrids(content)
   return content:gsub("<2~*\n(.-)\n~*>", function(code) return self:flexgrid(code) end)
end


function Gridder:parse_simplerow(row_code)
   local row = {}
   local i = 0
   row_code:gsub("[^\n]+",
                 function(item)
                    i = i + 1
                    if item~="" and item:sub(1,3) ~= "---" then
                       local id, title = item:match("([^%s]*)(.*)")
                       row[i] = {id=id, title=title}
                    else
                       row[i] = {}
                    end
                 end)
   table.insert(self.rows, row)
end


function Gridder:simplegrid(image_code)
   self.rows = {}
   image_code:gsub("[^~]+", function (row) self:parse_simplerow(row) end)

   for i, row in ipairs(self.rows) do
      row.photos = row
      for j, photo in ipairs(row) do
         photo.photo_url = sfoto.photo_url(photo.id, "thumb")
         photo.link = self.sputnik:make_url("albums/"..photo.id)
      end
   end

   return cosmo.f(self.node.templates.SIMPLE_IMAGE_GRID){
             rows = self.rows
          }
end

function Gridder:add_flexgrids(content)
   return content:gsub("<2~*\n(.-)\n~*>", function(code) return self:flexgrid(code) end)
end

function Gridder:add_simplegrids(content)
   return content:gsub("<~*\n(.-)\n~*>", function(code) return self:simplegrid(code) end)
end

