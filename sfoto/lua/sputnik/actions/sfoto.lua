-----------------------------------------------------------------------------
-- Implements Sputnik actions for a photoalbum / blog combo.
-----------------------------------------------------------------------------
module(..., package.seeall)

local ITEMS_PER_ROW = 5

local util = require"sputnik.util"
local imagegrid = require"sfoto.imagegrid"


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
-- Sputnik.  "id" can be supplied as a string or already parsed into a table.
-----------------------------------------------------------------------------
local function photo_url(id, size)
   local LOCAL_MODE = false
   if LOCAL_MODE then 
      return "http://localhost/image.jpg"
   end

   local parsed
   if type(id) == "table" then
      parsed = id
   else
      parsed = parse_id(id)
   end
   id = parsed.year.."-"..parsed.month.."-"..parsed.date.."-"..parsed.rest

   local album_base = "http://media.freewisdom.org/freewisdom/albums/"
   local full_size_base = "http://media.freewisdom.org/freewisdom/full_size/"
   if size=="original" then
      return full_size_base.."/"..id..".JPG"
   elseif size=="blog_thumb" then
      return "http://media.freewisdom.org/blog_thumbs/"
             ..parsed.year.."/"..parsed.month.."/"..parsed.date.."/"..parsed.rest
             ..".jpg"
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

-----------------------------------------------------------------------------
-- Returns the HTML (without the wrapper) for displaying a blog post.
-----------------------------------------------------------------------------
actions.show_entry_content = function(node, request, sputnik)
   -- figure out if we want to add a title
   local title = request.params.show_title and "" 
                 or "<h1>"..node.title.."</h1>\n\n"

   -- handle image grids
   local gridder = imagegrid.new(node, photo_url, sputnik)
   local content = gridder:add_flexgrids(node.content or "")
   content = gridder:add_simplegrids(content)

   -- decide if we want to put a width-limited div around it (for thumbnails)
   local html = title..node.markup.transform(content)
   if request.params.width then
      html = cosmo.f(node.templates.FOR_THUMB){
                width = request.params.width, 
                html  = html
             }
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

-----------------------------------------------------------------------------
-- Groups items into buckets, e.g., for the purpose of grouping photos into
-- rows.
-----------------------------------------------------------------------------
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
   -- select viewable photos
   local photos, num_hidden = items_user_can_see(node.content.photos,
                                                 request, sputnik)
   -- attach URLs to them
   for i, photo in ipairs(photos) do
      photo.thumb = photo_url(node.id.."/"..photo.id, "thumb")
   end
   -- group into rows
   local rows = group(photos, "photos", ITEMS_PER_ROW)

   -- figure out if we need a title (for AHAH)
   local title = request.params.show_title and ""
                 or "<h1>"..node.title.."</h1>\n\n"

   -- format the output
   return title..cosmo.f(node.templates.ALBUM){
                    album_url = sputnik:make_url(node.id),
                    rows = rows,
                    if_has_hidden = cosmo.c(num_hidden > 0) {
                       lock_icon_url = sputnik:make_url("sfoto/lock.png"),
                       num_hidden = num_hidden,
                    }
                 }
end

-----------------------------------------------------------------------------
-- Returns the HTML (complete page) for displaying an album.
-----------------------------------------------------------------------------
actions.show_album = function(node, request, sputnik)
   node.inner_html = actions.show_album_content(node, request, sputnik)
   return node.wrappers.default(node, request, sputnik)
end

------------------- MOVE ----------------------------------------------------
tag_expander = {
   rio = "brazil",
   paris = "france",
   ["france-other"] = "france",
   amiens = "france",
   vladivostok="russia",
} ------------------- MOVE --------------------------------------------------

-----------------------------------------------------------------------------
-- Checks if item has the specified tag, considering the expansion of the
-- tags (i.e., "brazil" matches "rio").
-----------------------------------------------------------------------------
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

-----------------------------------------------------------------------------
-- Checks if the album or it's photos have the specified tag.
-----------------------------------------------------------------------------
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


-----------------------------------------------------------------------------
-- Filters a list of icons (albums or posts) by a tag.
-----------------------------------------------------------------------------
local function filter_by_tag(items, tag)
   local tag_item = {}
   for i,v in ipairs(items) do
      if v.sfoto_type == "album" then
         if album_matches_tag(v, tag) then
            table.insert(tag_items, v)
         end
      else
         if matches_tag(v, tag) then
            table.insert(tag_items, v)
         end
      end
   end
   return tag_items
end

-----------------------------------------------------------------------------
-- Shows the HTML (just the content) for an index page.
-----------------------------------------------------------------------------
function actions.show_index_content(node, request, sputnik)

   local nodes = sputnik.saci:get_nodes_by_prefix(node.id, 2000)

   local tag = request.params.tag
   -- get matching items
   local items = {}
   for k,v in pairs(nodes) do
      table.insert(items, v)
   end
   items = items_user_can_see(items, request, sputnik)
   if tag then
      items = filter_by_tag(items, tag)
   end

   local reverse_url = request.params.ascending and sputnik:make_url(node.id)
                       or sputnik:make_url(node.id, nil, {ascending='1'})

   local sorter = request.params.ascending 
                  and function(x,y) return x.id < y.id end
                  or function(x,y) return x.id > y.id end
   table.sort(items, sorter)

   local oddeven = util.new_cycle{"odd", "even"}
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

   -- separate items by month
   local items_by_month = {}
   for i, item in ipairs(items) do
      local month = parse_id(item.id).month
      if not items_by_month[month] then items_by_month[month] = {} end
      table.insert(items_by_month[month], item)
   end
 
   -- make a list of months for which we have items
   local months = {}
   for i, name in ipairs(MONTHS) do
      local month = {
         id         = string.format("%02d", i),
         name       = name,
         short_name = name:sub(1,3):lower()
      }
      if items_by_month[month.id] then
         month.items = items_by_month[month.id]
         --month.rows = group(month.items, "items", ITEMS_PER_ROW)
         if request.params.ascending then
            table.insert(months, month)
         else 
            table.insert(months, 1, month) -- insert in front
         end
      end
   end

   local function decorate_item(item)
      local parsed = parse_id(item.id)
      item.if_blog = cosmo.c(item.sfoto_type=="post"){}
      item.if_album = cosmo.c(item.sfoto_type~="post"){}
      if item.sfoto_type == "post" then
          item.url = sputnik:make_url(item.id)
          item.content_url = sputnik:make_url(item.id, "show_content", {show_title="1"})
          item.blog_thumb = photo_url(item.id, "blog_thumb")
      else
          item.url = sputnik:make_url(item.id)
          item.content_url = sputnik:make_url(item.id, "show_content", {show_title="1"})
          item.thumbnail = photo_url(item.id.."/"..item.thumb, "thumb")
      end

      item.show_date = (cur_date ~= parsed.date) and parsed.date
                       or "&nbsp;"

      if cur_date ~= parsed.date then
         oddeven:next()
         cur_date = parsed.date
      end
      item.odd = oddeven:get()
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
                                                -- go through this month's items, yielding rows
                                                for i, item in ipairs(month.items) do
                                                   item.row_id = row.row_id
                                                   decorate_item(item)
                                                   table.insert(row.items, item)
                                                   table.insert(row.dates, {date=item.show_date, odd=item.odd})
                                                   if #(row.items) == 5 then
                                                      cosmo.yield(row)
                                                      row = make_row()
                                                   end
                                                end
                                                -- check if we have a partial row left
                                                local num_items = #(row.items)
                                                if num_items > 0 then
                                                   if num_items < ITEMS_PER_ROW then
                                                      oddeven:next()
                                                   end
                                                   row.if_blanks = cosmo.c(num_items <= ITEMS_PER_ROW) {
                                                                      blanks = ITEMS_PER_ROW + 1 - num_items,
                                                                      odd = oddeven:get(),
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

