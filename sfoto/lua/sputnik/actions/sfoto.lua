-----------------------------------------------------------------------------
-- Implements Sputnik actions for a photoalbum / blog combo.
-----------------------------------------------------------------------------
module(..., package.seeall)

local ITEMS_PER_ROW = 5
local imagegrid = require("sfoto.imagegrid")
local wiki = require("sputnik.actions.wiki")
require("sfoto")

-----------------------------------------------------------------------------
-- A table of actions for export.
-----------------------------------------------------------------------------
actions = {}

-----------------------------------------------------------------------------
-- Returns the HTML (without the wrapper) for displaying a single photo,
-- together with links to previous and next ones.
-----------------------------------------------------------------------------
actions.show_photo_content = function(node, request, sputnik)
   -- find all photos in this album that the user is authorized to see
   local parent_id, short_id = node:get_parent_id()
   local parent = sputnik:get_node(parent_id) 
   local user_access = sputnik.auth:get_metadata(request.user, "access")
   local photos = sfoto.visible_photos(parent.content.photos, request.user,
                                       sputnik)

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
             photo_url     = sfoto.photo_url(node.id),
             original_size = sfoto.photo_url(node.id, "original"),
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
   local title = ""
   if request.params.show_title then
      title = "<h1>"..node.title.."</h1>\n\n"
   end

   -- handle image grids
   local gridder = imagegrid.new(node, photo_url, sputnik)
   local content = gridder:add_flexgrids(node.content or "")
   content = gridder:add_simplegrids(content)

   -- decide if we want to put a width-limited div around it
   -- (needed for generating page thumbnails)
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
-- Returns the HTML (without the wrapper) for displaying an album.
-----------------------------------------------------------------------------
actions.show_album_content = function(node, request, sputnik)
   -- select viewable photos
   local user_access = sputnik.auth:get_metadata(request.user, "access")
   local photos, num_hidden = sfoto.visible_photos(node.content.photos,
                                                   request.user, sputnik)   
   -- attach URLs to them
   for i, photo in ipairs(photos) do
      photo.thumb = sfoto.photo_url(node.id.."/"..photo.id, "thumb")
   end
   -- group into rows
   local rows = sfoto.group(photos, "photos", ITEMS_PER_ROW)

   -- figure out if we need a title (for AHAH)
   local title = request.params.show_title
                 and "<h1>"..node.title.."</h1>\n\n" or ""

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

function get_visible_items_by_tag(sputnik, user, id, tag)
   local function make_key(tag)
      return (user or "Anon").."/"..tag
   end
   if not TAG_CACHE then
      TAG_CACHE = {}
      if not TAG_CACHE[user] then
         local items = get_visible_nodes_lazily(sputnik, user, id)
         for i, item in ipairs(items) do
            if item.tags then
               for tag in item.tags:gmatch("%S*") do
                  local key = make_key(tag)
                  TAG_CACHE[key] = TAG_CACHE[key] or {}
                  table.insert(TAG_CACHE[key], item)
               end
            end
         end
         TAG_CACHE[user] = true
      end
   end
   return TAG_CACHE[make_key(tag)] or {}
end

function get_visible_nodes_lazily(sputnik, user, id)
   if not SFOTO_NODE_CACHE then
      SFOTO_NODE_CACHE = {}
   end
   local key = (user or "Anon").."/"..id
   if SFOTO_NODE_CACHE[key] then
      return SFOTO_NODE_CACHE[key]
   else
      local nodes = wiki.get_visible_nodes(sputnik, user, id, {lazy=true})
      SFOTO_NODE_CACHE[key] = nodes
      return nodes
   end
end

-----------------------------------------------------------------------------
-- Shows the HTML (just the content) for an index page.
-----------------------------------------------------------------------------
function actions.show_index_content(node, request, sputnik)
   local items
   if node.id:match("/[a-z]") then
      local section, tag
      print(node.id)
      node.id, section, tag = node.id:match("(.-)/(.-)/(.*)")
      items = get_visible_items_by_tag(sputnik, request.user, node.id, tag)
   else
      items = get_visible_nodes_lazily(sputnik, request.user, node.id)
   end

   local months, url_for_reversing
   if request.params.ascending then
      url_for_reversing = sputnik:make_url(node.id, nil)
      months = sfoto.make_calendar(items, sputnik, true)
   else
      url_for_reversing = sputnik:make_url(node.id, nil, {ascending='1'})
      months = sfoto.make_calendar(items, sputnik)
   end

   return cosmo.f(node.templates.INDEX){
                        reverse_url = url_for_reversing,
                        months      = months
                  }
end

--require"versium.sqlite3"
--require"versium.filedir"
--cache = versium.filedir.new{"/tmp/cache/"} --sqlite3.new{"/tmp/cache.db"}

-----------------------------------------------------------------------------
-- Handles the basic "show" request with caching.
-----------------------------------------------------------------------------
actions.show = function(node, request, sputnik)
   if sputnik.app_cache then
       --local tracker = sputnik.saci:get_node_info("sfoto_tracker")
       local key = node.id.."|"..request.query_string.."|"..(request.user or "Anon")
       cached_info = sputnik.app_cache:get_node_info(key) or {}
       --if (not cached_info.timestamp) or (cached_info.timestamp < tracker.timestamp) then
       if not cached_info.timestamp then
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
