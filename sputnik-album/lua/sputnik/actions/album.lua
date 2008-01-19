module(..., package.seeall)

SLASH = "/"

actions = {}

actions.mixed_album = function(page, params, sputnik)

   local data = sputnik:load_config_page(page.name, sputnik)
 
   function get_total_height (rows)
      local total = 0
      for i, row in ipairs(rows) do
	 if #row == 6 then 
	    total = total + 150 + 8
	 else
	    total = total + 100 + 8
	 end
      end
      return total
   end

   page.inner_html = cosmo.fill(page.templates.MIXED_ALBUM, {
      before     = sputnik:wikify_text(data.before),
      after      = sputnik:wikify_text(data.after),
      do_photos  = function() 

		      local width, dwidth, height
		      local y = 2


		      for i, row in ipairs(data.rows) do
			 if #row == 6 then
			    width, dwidth, height = 100, 6, 150
			 else
			    width, dwidth, height = 150, 10, 100
			 end

			 local x = 2
			 for i = 1,#row do 
			    photo = row[i]
			    if photo then
			       local album, image = sputnik:split(photo.id, SLASH)
			       local suffix = "thumb.jpg"
			       local thumbdir = album
			       if not photo.size then photo.size = 1 end
			       if photo.size > 1 then
				  suffix = string.format("thumb%dx.jpg", photo.size)
				  thumbdir = "oddsize"
			       end

			       photo.width      = width*photo.size + dwidth*(photo.size-1)
			       photo.height     = height*photo.size + 8*(photo.size-1)
			       photo.left       = 2 + (width + dwidth) * (i-1)
			       photo.top        = y
			       photo.link_base  = data.link_base
			       photo.thumb_base = data.thumb_base
			       photo.suffix     = suffix
			       photo.thumb_dir  = thumbdir
			       photo.album      = album
			       photo.image      = image

			       cosmo.yield(photo)
			    end
			 end
			 y = y + height + 8
		      end
		   end,
      height     = get_total_height(data.rows)
   })

   return page.wrappers.default(page, params, sputnik)
end

