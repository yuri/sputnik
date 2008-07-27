module(..., package.seeall)

local util = require"sputnik.util"

local imagegrid = require"sfoto.imagegrid"

local LOCAL_MODE = false

local function photo_url(id, size)
   if LOCAL_MODE then 
      return "http://localhost/image.jpg"
   end
   local album_base = "http://media.freewisdom.org/freewisdom/albums/"
   local full_size_base = "http://media.freewisdom.org/freewisdom/full_size/"
   if size=="original" then
      return full_size_base.."/"..id:gsub("albums/", "")..".JPG"
   elseif size=="thumb" then
      return album_base..id:gsub("albums/", "")..".thumb.jpg"
   elseif size=="2x" or size=="3x" or size=="4x" then
      return album_base.."/oddsize/"..id:match("/([^%/]*)$")..".thumb"..size..".jpg"
   else
      return album_base.."/"..id:gsub("albums/", "")..".sized.jpg"
   end
end



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
                        photo_url     = photo_url(node.id),
                        original_size = photo_url(node.id, "original"),
                        next_link     = sputnik:make_url(parent_id.."/"..(photos[node.position+1] or {id=""}).id),
                        prev_link     = sputnik:make_url(parent_id.."/"..(photos[node.position-1] or {id=""}).id),
                        note          = link_notes[photos[node.position+1]~=nil]
                  }
end

actions.show_photo = function(node, request, sputnik)
   node.inner_html = actions.show_photo_content(node, request, sputnik)
   return node.wrappers.default(node, request, sputnik)
end


for_thumb = [[
   <style type="css">
     a:link img {border-style: none;}     
   </style>
   <div style="width: $width{}px">
$html
   </div>"
]]


actions.show_entry_content = function(node, request, sputnik)
   local title = ""
   if request.params.show_title then
      title = "<h1>"..node.title.."</h1>\n\n"
   end

   gridder = imagegrid.new(node, photo_url, sputnik)

   local content = gridder:add_flexgrids(node.content or "")
   content = gridder:add_simplegrids(content)
   --:gsub("<~*\n(.-)\n~*>", gridder.simplegrid)

   local html = title..node.markup.transform(content)
   if request.params.width then
      return cosmo.f(for_thumb){width=request.params.width, html=html}
   else
      return html
   end
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
         photo.thumb = photo_url(node.id.."/"..photo.id, "thumb")
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

function actions.show_index_content(node, request, sputnik)

   --node:add_javascript_link(sputnik:make_url("jquery.js"))
   -- node.content.data

   local tag = request.params.tag

   local items = {} --node.content.data

   for k,v in pairs(sputnik.saci:get_nodes_by_prefix("albums/"..node.id, 500)) do
      v.id = v.id:gsub("^albums/", "")
      v.sort_key = v.id:gsub("-", "/")
      local match = false
      for i, photo in ipairs(v.content.photos) do
         if matches_tag(photo, tag) then
            match = true
         end
      end
      if match then
         table.insert(items, v)
      end
   end
   for k,v in pairs(sputnik.saci:get_nodes_by_prefix("entries/"..node.id, 500)) do
      v.id = v.id:gsub("^entries/", "")
      v.sort_key = v.id
      v.type = "blog"
      if matches_tag(v, tag) then
         table.insert(items, v)
      end
   end

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
   for i, m in ipairs(MONTHS) do m.short_name = m.name:sub(1,3):lower() end

   local reverse_url
   if request.params.ascending then
      table.sort(items, function(x,y) return x.sort_key < y.sort_key end)
      table.sort(MONTHS, function(x,y) return x.id < y.id end)
      reverse_url = sputnik:make_url(node.id)
   else
      table.sort(items, function(x,y) return x.sort_key > y.sort_key end)
      reverse_url = sputnik:make_url(node.id, nil, {ascending='1'})
   end

   local odd = "odd"
   local cur_date = ""
   local show_date = ""
   local row_counter = 0

   local function make_row()
      row_counter = row_counter + 1
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
                                                   if item.id:sub(6,7)==month.id then
                                                          item.if_blog = cosmo.c(item.type=="blog"){}
                                                          item.if_album = cosmo.c(item.type~="blog"){}
                                                          if item.type == "blog" then
                                                              item.url = sputnik:make_url("entries/"..item.id)
                                                              item.content_url = sputnik:make_url("entries/"..item.id, "show_content", {show_title="1"})
                                                              item.blog_thumb = "http://media.freewisdom.org/blog_thumbs/"..item.id..".jpg"
                                                          else
                                                              item.url = sputnik:make_url("albums/"..item.id)
                                                              item.content_url = sputnik:make_url("albums/"..item.id, "show_content", {show_title="1"})
                                                              item.thumbnail = photo_url(item.id.."/"..item.thumb, "thumb")
                                                              
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
                                                   local num_items = #(row.items)
                                                   if num_items > 0 then
                                                      if num_items < 6 then
                                                         if odd == "odd" then odd = "even" else odd = "odd" end
                                                      end
                                                      row.if_blanks = cosmo.c(num_items < 6) {
                                                                         blanks = 6 - num_items,
                                                                         odd = odd,
                                                                         width = 170*(6-num_items),
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
   if sputnik.app_cache then
       local tracker = sputnik.saci:get_node_info("sfoto_tracker")
       local key = node.id.."|"..request.query_string.."|"..(request.user or "Anon")
       cached_info = sputnik.app_cache:get_node_info(key) or {}
       if (not cached_info.timestamp) or (cached_info.timestamp < tracker.timestamp) then
          print("not cached or expired cache")
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

