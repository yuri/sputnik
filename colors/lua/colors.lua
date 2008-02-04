-------------------------------------------------------------------------------
-- Provides support for color manipulation in HSL color space.
-------------------------------------------------------------------------------

module(..., package.seeall)


-------------------------------------------------------------------------------
-- Converts HSL to RGB (see http://homepages.cwi.nl/~steven/css/hsl.html)
-------------------------------------------------------------------------------

function hsl_to_rgb(h, s, L)
   h = h/360
   local m1, m2
   if L<=0.5 then 
      m2 = L*(s+1)
   else 
      m2 = L+s-L*s
   end
   m1 = L*2-m2

   local function _h2rgb(m1, m2, h)
      if h<0 then h = h+1 end
      if h>1 then h = h-1 end
      if h*6<1 then 
         return m1+(m2-m1)*h*6
      elseif h*2<1 then 
         return m2 
      elseif h*3<2 then 
         return m1+(m2-m1)*(2/3-h)*6
      else
         return m1
      end
   end

   return _h2rgb(m1, m2, h+1/3), _h2rgb(m1, m2, h), _h2rgb(m1, m2, h-1/3)
end


Color = {

   new = function(self, H, S, L) 
      obj = {H = H, S = S, L = L}
      setmetatable(obj, self)		
      self.__index = self
      self.__tostring = self.to_rgb
      return obj
   end,

   to_rgb = function(self)
      local r, g, b = hsl_to_rgb(self.H, self.S, self.L)
      local rgb = {hsl_to_rgb(self.H, self.S, self.L)}
      buffer = "#"
      for i,v in ipairs(rgb) do
	 buffer = buffer..string.format("%02x",math.floor(v*255))
      end
      return buffer
   end,

   hue_offset = function(self, delta)
      return self:new((self.H + delta) % 360, self.S, self.L)
   end,

   complementary = function(self) 
      return self:hue_offset(180)
   end,

   neighbors = function(self, angle)
      angle = angle or 30
      return self:hue_offset(angle), self:hue_offset(360-angle)
   end,

   triadic = function(self) 
      return self:neighbors(120)
   end,

   split_complementary = function(self, angle)
      angle = angle or 30
      return self:neighbors(180-angle)
   end,

   desaturate_to = function(self, v)
      return self:new(self.H, v, self.L)
   end,

   desaturate_by = function(self, r)
      return self:new(self.H, self.S*r, self.L)
   end,	      

   lighten_to = function(self, v)
      return self:new(self.H, self.S, v)
   end,

   lighten_by = function(self, r)
      return self:new(self.H, self.S, self.L*r)
   end,

   variations = function(self, f, n)
      n = n or 5
      local results = {}
      for i=1,n do
	 table.insert(results, f(self, i, n))
      end
      return results
   end,

   tints = function(self, n)
      local f = function (color, i, n) 
		   return color:lighten_to(color.L + (1-color.L)/n*i)
		end
      return self:variations(f, n)
   end,

   shades = function(self, n)
      local f = function (color, i, n) 
		   return color:lighten_to(color.L - (color.L)/n*i)
		end
      return self:variations(f, n)
   end,

   tint = function(self, r)
      return self:lighten_to(self.L + (1-self.L)*r)
   end,

   shade = function(self,r)
      return self:lighten_to(self.L - self.L*r)
   end,		
}


