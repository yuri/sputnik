module(..., package.seeall)

local util = require"sputnik.util"

album_base = "http://media.freewisdom.org/freewisdom/albums/"
full_size_base = "http://media.freewisdom.org/freewisdom/full_size/"

actions = {}


actions.show_photo_content = function(node, request, sputnik)
   local parent_id, short_id = node:get_parent_id()
   local parent = sputnik:get_node(parent_id) 
   node.title = parent.title

   local photos = {}
   local user_access_level = sputnik.auth:get_metadata(request.user, "access") or "0"
   for i, photo in ipairs(parent.content.photos) do
      if user_access_level >= (photo.private or "0") then
         table.insert(photos, photo)
         if photo.id == short_id then
            node.position = i 
            node.title = node.title.." #"..i 
         end
      end
   end
   if not node.position then
      node:post_error("No such photo or access denied")
      return ""
   end

   local link_notes = { 
            [true]  = "Click for the next photo", 
            [false] = "This is the last photo photo, click to return"
         }

   return cosmo.f(node.templates.SINGLE_PHOTO){
                        photo_url = album_base.."/"..node.id:gsub("albums/", "")..".sized.jpg",
                        original_size = full_size_base.."/"..node.id:gsub("albums/", "")..".JPG",
                        next_link = sputnik:make_url(parent_id.."/"..(photos[node.position+1] or {id=""}).id),
                        prev_link = sputnik:make_url(parent_id.."/"..(photos[node.position-1] or {id=""}).id),
                        note = link_notes[photos[node.position+1]~=nil]
                  }
end

actions.show_photo = function(node, request, sputnik)
   node.inner_html = actions.show_photo_content(node, request, sputnik)
   return node.wrappers.default(node, request, sputnik)
end


local function format_image_grid(node, rows, sputnik)
   local total_height = 0
   for i, row in ipairs(rows) do
      total_height = total_height + 8 + (#row==6 and 150 or 100)
   end

   local function pixify(value) 
      return string.format("%dpx", value)
   end

   local photos = {}
    local width, dwidth, height
    local y = 2
    for i, row in ipairs(rows) do
       if #row == 6 then
          width, dwidth, height = 100, 6, 150
       else
          width, dwidth, height = 150, 10, 100
       end
       local x = 2
       for i = 1,#row do 
          photo = row[i]
          if photo and photo.id then
             local album, image = util.split(photo.id, "/")
             photo.size = photo.size or 1

             table.insert(photos, {
                width      = pixify(width*photo.size + dwidth*(photo.size-1)),
                height     = pixify(height*photo.size + 8*(photo.size-1)),
                left       = pixify(2 + (width + dwidth) * (i-1)),
                top        = pixify(y),
                image_base = album_base,
                suffix     = photo.size>1 and string.format("%dx", photo.size) or "",
                thumb_dir  = photo.size==1 and album or "oddsize",
                album      = album,
                image      = image,
                url        = sputnik:make_url(node.id, "photo", {id=photo.id}),
             })
          end
       end
       y = y + height + 8
    end

   return cosmo.f(node.templates.MIXED_ALBUM){
             do_photos  = photos,
             height = total_height
   }
end

function image_link_2(node, image_code, sputnik)
   local rows = {}
   local buffer = ""
   image_code:gsub("[^~]+", 
                   function(row_code)
                      row = {}
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
                      table.insert(rows, row)
                   end)
   for i, row in ipairs(rows) do
      for j, photo in ipairs(row) do
         buffer = buffer .. (photo.id or "x").."\n"
      end
   end

   return format_image_grid(node, rows, sputnik)
end

actions.show_entry_content = function(node, request, sputnik)
   local title = ""
   if request.params.show_title then
      title = "<h1>"..node.title.."</h1>\n\n"
   end
   return title..node.markup.transform((node.content or ""):gsub("<2~*\n(.-)\n~*>", function(x) return image_link_2(node, x, sputnik) end))
end

actions.show_entry = function(node, request, sputnik)
   request.is_indexable = true
   node.inner_html = node.actions.show_content(node, request, sputnik)
   return node.wrappers.default(node, request, sputnik)
end

actions.show_album_content = function(node, request, sputnik)
   local num_hidden = 0
   local rows = {}
   local row = {photos={}}
   local user_access_level = sputnik.auth:get_metadata(request.user, "access") or "0"
   for i, photo in ipairs(node.content.photos) do
      if user_access_level >= (photo.private or "0") then
         table.insert(row.photos, photo)
         photo.thumb = album_base..node.id:gsub("albums/", "").."/"..photo.id..".thumb.jpg"
         if #(row.photos) == 5 then
            table.insert(rows, row)
            row = {photos={}}
         end
      else
         num_hidden = num_hidden + 1
      end
   end
   if #(row.photos) > 0 then
      table.insert(rows, row)
   end

   local title = ""
   if request.params.show_title then
      title = "<h1>"..node.title.."</h1>\n\n"
   end
   return title..cosmo.f(node.templates.ALBUM){
                    album_url = sputnik:make_url(node.id),
                    rows = rows,
                    if_has_hidden = cosmo.c(num_hidden > 0) {
                       lock_icon_url = sputnik:make_url("sfoto/lock.png"),
                       num_hidden = num_hidden,
                    }
                 }
end

actions.show_album = function(node, request, sputnik)
   node.inner_html = actions.show_album_content(node, request, sputnik)
   return node.wrappers.default(node, request, sputnik)
end


actions.show = function(node, request, sputnik)

   --node:add_javascript_link(sputnik:make_url("jquery.js"))
   -- node.content.data

   local items = {} --node.content.data

   for k,v in pairs(sputnik.saci:get_nodes_by_prefix("albums/"..node.id, 100)) do
      v.id = v.id:gsub("^albums/", "")
      v.sort_key = v.id:gsub("-", "/")
      table.insert(items, v)
   end
   for k,v in pairs(sputnik.saci:get_nodes_by_prefix("entries/"..node.id, 100)) do
      v.id = v.id:gsub("^entries/", "")
      v.sort_key = v.id
      v.type = "blog"
      table.insert(items, v)
   end

   table.sort(items, function(x,y) return x.sort_key > y.sort_key end)
   
   --items = node.content.data

   local MONTHS = {
      {id = "12", name="December"},
      {id = "11", name="November"},
      {id = "10", name="October"},
      {id = "09", name="September"},
      {id = "08", name="August"},
      {id = "07", name="July"},
      {id = "06", name="June"},
      {id = "05", name="May"},
      {id = "04", name="April"},
      {id = "03", name="March"},
      {id = "02", name="February"},
      {id = "01", name="January"},
   }

   local odd = "odd"
   local cur_date = ""
   local show_date = ""
   local row_counter = 0

   local function make_row()
      row_counter = row_counter + 1
      return {
         items={}, 
         dates={},
         row_id = tostring(row_counter),
      }
   end

   local user_access_level = sputnik.auth:get_metadata(request.user, "access") or "0"
   
   local items_by_month = {}
   for i, item in ipairs(items) do
      local month = item.id:sub(6,7)
      if not items_by_month[month] then items_by_month[month] = {} end
      table.insert(items_by_month[month], item)
   end
 
   local months = {}
   for i, month in ipairs(MONTHS) do
      if items_by_month[month.id] then
         month.items = items_by_month[month.id]
         table.insert(months, month)
      end
   end

   node.inner_html = cosmo.f(node.templates.INDEX){

                        do_months = function()
                                       for i, month in ipairs(months) do
                                          cosmo.yield { 
                                             month = month.name, 
                                             do_rows = function()
                                                local row = make_row()
                                                for i, item in ipairs(month.items) do
                                                   item.row_id = row.row_id
                                                   if item.id:sub(6,7)==month.id then
                                                          item.if_blog = cosmo.c(item.type=="blog"){}
                                                          item.if_album = cosmo.c(item.type~="blog"){}
                                                          if item.type == "blog" then
                                                              item.url = sputnik:make_url("entries/"..item.id)
                                                              item.content_url = sputnik:make_url("entries/"..item.id, "show_content", {show_title="1"})
                                                          else
                                                              item.url = sputnik:make_url("albums/"..item.id)
                                                              item.content_url = sputnik:make_url("albums/"..item.id, "show_content", {show_title="1"})
                                                              item.thumbnail = album_base..item.id.."/"..item.thumb..".thumb.jpg"
                                                              
                                                              if user_access_level < (item.private or "0") then
                                                                 item.thumbnail = sputnik:make_url("sfoto/lock.png")
                                                                 item.title = "Login to see"
                                                              end
                                                          end
                                                          if cur_date == item.id:sub(9,10) then
                                                             show_date = "&nbsp;"
                                                          else
                                                             if odd == "odd" then odd = "even" else odd = "odd" end
                                                             cur_date = item.id:sub(9,10)
                                                             show_date = cur_date
                                                          end
                                                          item.odd = odd
                                                          table.insert(row.items, item)
                                                          table.insert(row.dates, {date=show_date, odd=odd})
                                                          if #(row.items) == 5 then
                                                             row.do_date_cells = {}
                                                             cosmo.yield(row)
                                                             row = make_row()
                                                          end
                                                      end
                                                   end
                                                   if #(row.items) > 0 then cosmo.yield(row) end
                                               end
                                          }
                                       end
                                    end    
                        }

   return node.wrappers.default(node, request, sputnik)
end

