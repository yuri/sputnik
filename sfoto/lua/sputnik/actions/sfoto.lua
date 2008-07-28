module(..., package.seeall)

local util = require"sputnik.util"

local imagegrid = require"sfoto.imagegrid"

local ITEMS_PER_ROW = 5

-----------------------------------------------------------------------------
-- Given a string in a prefix/YYYY/MM/DD-xyz or prefix/YYYY-MM-DD-xyz format,
-- returns "YYYY", "MM", "DD", and "xyz".
-----------------------------------------------------------------------------
local function parse_id(id)
   local root_id = id:match("[^%/]*")
   id = id:sub(root_id:len()+2)
   return {
      root  = root_id,
      year  = id:sub(1,4),
      month = id:sub(6,7),
      date  = id:sub(9,10),
      rest  = id:sub(12),
   }
end

-----------------------------------------------------------------------------
-- Maps ids to actual image URLs, assuming that the images are stored outside
-- Sputnik.
-----------------------------------------------------------------------------
local function photo_url(id, size)
   local LOCAL_MODE = false
   if LOCAL_MODE then 
      return "http://localhost/image.jpg"
   end

   local parsed = parse_id(id)
   id = parsed.year.."-"..parsed.month.."-"..parsed.date.."-"..parsed.rest

   local album_base = "http://media.freewisdom.org/freewisdom/albums/"
   local full_size_base = "http://media.freewisdom.org/freewisdom/full_size/"
   if size=="original" then
      return full_size_base.."/"..id..".JPG"
   elseif size=="thumb" then
      return album_base..id..".thumb.jpg"
   elseif size=="2x" or size=="3x" or size=="4x" then
      return album_base.."/oddsize/"..id:match("/([^%/]*)$")..".thumb"..size..".jpg"
   else
      return album_base.."/"..id..".sized.jpg"
   end
end

-----------------------------------------------------------------------------
-- A list of months, hardcoded for now.
-----------------------------------------------------------------------------
local MONTHS = {"January", "February", "March", "April", "May", "June", "July",
          "August", "September", "October", "November", "December"}

local MONTHS2 = {
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

-----------------------------------------------------------------------------
-- A table of actions for export.
-----------------------------------------------------------------------------
actions = {}

-----------------------------------------------------------------------------
-- Returns a list of items that the user is allowed to see and the number of
-- excluded items.
-----------------------------------------------------------------------------
local function items_user_can_see(items, request, sputnik)
   local user_access_level = sputnik.auth:get_metadata(request.user, "access") or "0"
   local viewable_items = {}
   local num_hidden = 0
   for i, item in ipairs(items) do
      if user_access_level >= (item.private or "0") then
         table.insert(viewable_items, item)
      else
         num_hidden = num_hidden + 1
      end
   end
   return viewable_items, num_hidden
end

-----------------------------------------------------------------------------
-- Returns the HTML (without the wrapper) for displaying a single photo,
-- together with links to previous and next ones.
-----------------------------------------------------------------------------
actions.show_photo_content = function(node, request, sputnik)
   local parent_id, short_id = node:get_parent_id()
   local parent = sputnik:get_node(parent_id) 

   -- find all photos this user is authorized to see
   local photos = items_user_can_see(parent.content.photos, request, sputnik)

   -- find the requested photo among them or post an error message
   local this_photo
   for i, photo in ipairs(photos) do
      if photo.id == short_id then
         this_photo = i 
         node.title = parent.title.." #"..i 
      end
   end
   if not this_photo then
      node:post_error("No such photo or access denied")
      return ""
   end

   -- format the photo display
   local link_notes = { 
            [true]  = "Click for the next photo", 
            [false] = "This is the last photo photo, click to return"
         }
   local prev_photo, next_photo = "", ""
   if photos[this_photo-1] then prev_photo = photos[this_photo-1].id end
   if photos[this_photo+1] then next_photo = photos[this_photo+1].id end

   return cosmo.f(node.templates.SINGLE_PHOTO){
                        photo_url     = photo_url(node.id),
                        original_size = photo_url(node.id, "original"),
                        next_link     = sputnik:make_url(parent_id.."/"..next_photo),
                        prev_link     = sputnik:make_url(parent_id.."/"..prev_photo),
                        note          = link_notes[photos[this_photo+1]~=nil]
                  }
end


-----------------------------------------------------------------------------
-- Returns the HTML (complete page) for displaying a single photo.
-----------------------------------------------------------------------------
actions.show_photo = function(node, request, sputnik)
   node.inner_html = actions.show_photo_content(node, request, sputnik)
   return node.wrappers.default(node, request, sputnik)
end


-- MOVE TO TEMPLATES --------------------------------------------------------
FOR_THUMB = [[
   <style type="css">
     a:link img {border-style: none;}     
   </style>
   <div style="width: $width{}px">
$html
   </div>"
]]

-----------------------------------------------------------------------------
-- Returns the HTML (without the wrapper) for displaying a blog post.
-----------------------------------------------------------------------------
actions.show_entry_content = function(node, request, sputnik)
   -- figure out if we want to add a title
   local title = ""
   if request.params.show_title then
      title = "<h1>"..node.title.."</h1>\n\n"
   end

   -- handle image grids
   local gridder = imagegrid.new(node, photo_url, sputnik)
   local content = gridder:add_flexgrids(node.content or "")
   content = gridder:add_simplegrids(content)

   -- decide if we want to put a width-limited div around it (for thumbnails)
   local html = title..node.markup.transform(content)
   if request.params.width then
      html = cosmo.f(FOR_THUMB){width=request.params.width, html=html}
   end

   return html
end

-----------------------------------------------------------------------------
-- Returns the HTML (complete page) for displaying a blog post.
-----------------------------------------------------------------------------
actions.show_entry = function(node, request, sputnik)
   request.is_indexable = true
   node.inner_html = node.actions.show_content(node, request, sputnik)
   return node.wrappers.default(node, request, sputnik)
end


function group(list, field, items_per_bucket)
   local buckets = {}
   local bucket = {[field] = {}}
   for i, item in ipairs(list) do
      table.insert(bucket[field], item)
      if #(bucket[field]) == items_per_bucket then
         table.insert(buckets, bucket)
         bucket = {[field] = {}}
      end
   end
   if #(bucket[field]) > 0 then
      table.insert(buckets, bucket)
   end
   return buckets
end

-----------------------------------------------------------------------------
-- Returns the HTML (without the wrapper) for displaying an album.
-----------------------------------------------------------------------------
actions.show_album_content = function(node, request, sputnik)
   local num_hidden = 0
   local rows = {}
   local row = {photos={}}

   local photos, num_hidden = items_user_can_see(node.content.photos, request, sputnik)
   for i, photo in ipairs(photos) do
      photo.thumb = photo_url(node.id.."/"..photo.id, "thumb")
   end

   rows = group(photos, "photos", ITEMS_PER_ROW)

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


tag_expander = {
   rio = "brazil",
   paris = "france",
   ["france-other"] = "france",
   amiens = "france",
   vladivostok="russia",
}

local function matches_tag(item, tag)
   if not tag then
      return true
   elseif not item.tags then
      return false
   else
      for t in item.tags:gmatch("[^ ]*") do
         if t == tag or tag_expander[t]==tag then 
            return true
         end
      end
   end
   return false
end

local function album_matches_tag(album, tag)
   if not tag then 
      return true
   end
   for i, photo in ipairs(album.content.photos) do
      if matches_tag(photo, tag) then
         return true
      end
   end
   return false
end

function actions.show_index_content(node, request, sputnik)
   local root_id = node.id:match("[^%/]*")
   local tag = request.params.tag
   local items = {} --node.content.data

   for k,v in pairs(sputnik.saci:get_nodes_by_prefix(node.id, 50)) do
      v.subid = v.id:sub(root_id:len()+2)
      if v.prototype == "sfoto/@album" then
          v.type = "album"
          if album_matches_tag(v, tag) then
             table.insert(items, v)
          end
      else
          v.type = "blog"
          if matches_tag(v, tag) then
             table.insert(items, v)
          end
      end
   end

   --for i, m in ipairs(MONTHS) do m.short_name = m.name:sub(1,3):lower() end

   local reverse_url
   if request.params.ascending then
      table.sort(items, function(x,y) return x.id < y.id end)
      reverse_url = sputnik:make_url(node.id)
   else
      table.sort(items, function(x,y) return x.id > y.id end)
      reverse_url = sputnik:make_url(node.id, nil, {ascending='1'})
   end

   local odd = "odd"
   local cur_date = ""
   local show_date = ""

   local row_counter = 0
   local function make_row()
      row_counter = row_counter + 1  -- a local variable!
      return {
         items={}, 
         dates={},
         if_blanks = cosmo.c(false){},
         row_id = tostring(row_counter),
      }
   end

   local user_access_level = sputnik.auth:get_metadata(request.user, "access") or "0"
   
   local items_by_month = {}
   for i, item in ipairs(items) do
      local month = parse_id(item.id).month
      if not items_by_month[month] then items_by_month[month] = {} end
      table.insert(items_by_month[month], item)
   end
 
   local months = {}
   for i, name in ipairs(MONTHS) do
      local month = {
         id         = string.format("%02d", i),
         name       = name,
         short_name = name:sub(1,3):lower()
      }
      if items_by_month[month.id] then
         month.items = items_by_month[month.id]
         if request.params.ascending then
            table.insert(months, month)
         else 
            table.insert(months, 1, month) -- insert in front
         end
      end
   end

   return cosmo.f(node.templates.INDEX){
                        reverse_url = reverse_url,
                        months      = months,
                        do_months = function()
                                       for i, month in ipairs(months) do
                                          cosmo.yield { 
                                             month = month.name,
                                             month_id = month.id, 
                                             do_rows = function()
                                                local row = make_row()
                                                for i, item in ipairs(month.items) do
                                                   item.row_id = row.row_id
                                                   local parsed = parse_id(item.id)
                                                   if parsed.month==month.id then
                                                          item.if_blog = cosmo.c(item.type=="blog"){}
                                                          item.if_album = cosmo.c(item.type~="blog"){}
                                                          if item.type == "blog" then
                                                              item.url = sputnik:make_url(item.id)
                                                              item.content_url = sputnik:make_url(item.id, "show_content", {show_title="1"})
                                                              item.blog_thumb = "http://media.freewisdom.org/blog_thumbs/"..item.subid..".jpg"
                                                          else
                                                              item.url = sputnik:make_url(item.id)
                                                              item.content_url = sputnik:make_url(item.id, "show_content", {show_title="1"})
                                                              item.thumbnail = photo_url(item.id.."/"..item.thumb, "thumb")
                                                              
                                                              if user_access_level < (item.private or "0") then
                                                                 item.thumbnail = sputnik:make_url("sfoto/lock.png")
                                                                 item.title = "Login to see"
                                                              end
                                                          end
                                                          if cur_date == parsed.date then
                                                             show_date = "&nbsp;"
                                                          else
                                                             if odd == "odd" then odd = "even" else odd = "odd" end
                                                             cur_date = parsed.date
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
                                                   local num_items = #(row.items)
                                                   if num_items > 0 then
                                                      if num_items < ITEMS_PER_ROW then
                                                         if odd == "odd" then odd = "even" else odd = "odd" end
                                                      end
                                                      row.if_blanks = cosmo.c(num_items <= ITEMS_PER_ROW) {
                                                                         blanks = ITEMS_PER_ROW + 1 - num_items,
                                                                         odd = odd,
                                                                         width = 170*(ITEMS_PER_ROW + 1 - num_items),
                                                                      }
                                                      cosmo.yield(row)
                                                   end
                                                end                                                
                                          }
                                       end
                                    end    
                        }
end

--require"versium.sqlite3"
--require"versium.filedir"
--cache = versium.filedir.new{"/tmp/cache/"} --sqlite3.new{"/tmp/cache.db"}

actions.show = function(node, request, sputnik)
   print("foo")
   if sputnik.app_cache and false then
       local tracker = sputnik.saci:get_node_info("sfoto_tracker")
       local key = node.id.."|"..request.query_string.."|"..(request.user or "Anon")
       cached_info = sputnik.app_cache:get_node_info(key) or {}
       if (not cached_info.timestamp) or (cached_info.timestamp < tracker.timestamp) then
          node.inner_html = actions.show_index_content(node, request, sputnik)
          sputnik.app_cache:save_version(key, node.inner_html, "sfoto")
       else
          node.inner_html = sputnik.app_cache:get_node(key)
       end
   else
      node.inner_html = actions.show_index_content(node, request, sputnik)
   end
   return node.wrappers.default(node, request, sputnik)
end

