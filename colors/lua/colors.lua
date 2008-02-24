---------------------------------------------------------------------------------------------------
-- Provides support for color manipulation in HSL color space.
---------------------------------------------------------------------------------------------------

module(..., package.seeall)

---------------------------------------------------------------------------------------------------
-- Converts an HSL triplet to RGB
-- (see http://homepages.cwi.nl/~steven/css/hsl.html).
-- 
-- @param h              hue (0-360)
-- @param s              saturation (0.0-1.0)
-- @param L              lightness (0.0-1.0)
-- @return               an R, G, and B component of RGB
---------------------------------------------------------------------------------------------------

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


Color = {}

---------------------------------------------------------------------------------------------------
-- Instantiates a new "color".
--
-- @param H              hue (0-360)
-- @param S              saturation (0.0-1.0)
-- @param L              lightness (0.0-1.0)
-- @return               an instance of Color
---------------------------------------------------------------------------------------------------
function Color:new(H, S, L) 
   local obj = {H = H, S = S, L = L}
   setmetatable(obj, self)		
   self.__index = self
   self.__tostring = self.to_rgb
   return obj
end

---------------------------------------------------------------------------------------------------
-- Converts the color to an RGB string.
--
-- @return               a 6-digit RGB representation of the color prefixed with "#" (suitable for 
--                       inclusion in HTML)
---------------------------------------------------------------------------------------------------

function Color:to_rgb()
   local r, g, b = hsl_to_rgb(self.H, self.S, self.L)
   local rgb = {hsl_to_rgb(self.H, self.S, self.L)}
   local buffer = "#"
   for i,v in ipairs(rgb) do
	  buffer = buffer..string.format("%02x",math.floor(v*255))
   end
   return buffer
end

---------------------------------------------------------------------------------------------------
-- Creates a new color with hue different by delta.
--
-- @param delta          a delta for hue.
-- @return               a new instance of Color.
---------------------------------------------------------------------------------------------------
function Color:hue_offset(delta)
   return self:new((self.H + delta) % 360, self.S, self.L)
end

---------------------------------------------------------------------------------------------------
-- Creates a complementary color.
--
-- @return               a new instance of Color
---------------------------------------------------------------------------------------------------
function Color:complementary() 
   return self:hue_offset(180)
end

---------------------------------------------------------------------------------------------------
-- Creates two neighboring colors (by hue), offset by "angle".
--
-- @param angle          the difference in hue between this color and the neighbors
-- @return               two new instances of Color
---------------------------------------------------------------------------------------------------
function Color:neighbors(angle)
   local angle = angle or 30
   return self:hue_offset(angle), self:hue_offset(360-angle)
end

---------------------------------------------------------------------------------------------------
-- Creates two new colors to make a triadic color scheme.
--
-- @return               two new instances of Color
---------------------------------------------------------------------------------------------------
function Color:triadic() 
   return self:neighbors(120)
end

---------------------------------------------------------------------------------------------------
-- Creates two new colors, offset by angle from this colors complementary.
--
-- @param angle          the difference in hue between the complementary and the returned colors
-- @return               two new instances of Color
---------------------------------------------------------------------------------------------------
function Color:split_complementary(angle)
   return self:neighbors(180-(angle or 30))
end

---------------------------------------------------------------------------------------------------
-- Creates a new color with saturation set to a new value.
--
-- @param saturation     the new saturation value (0.0 - 1.0)
-- @return               a new instance of Color
---------------------------------------------------------------------------------------------------
function Color:desaturate_to(saturation)
   return self:new(self.H, saturation, self.L)
end

---------------------------------------------------------------------------------------------------
-- Creates a new color with saturation set to a old saturation times r.
--
-- @param r              the multiplier for the new saturation
-- @return               a new instance of Color
---------------------------------------------------------------------------------------------------
function Color:desaturate_by(r)
   return self:new(self.H, self.S*r, self.L)
end	      

---------------------------------------------------------------------------------------------------
-- Creates a new color with lightness set to a new value.
--
-- @param lightness      the new lightness value (0.0 - 1.0)
-- @return               a new instance of Color
---------------------------------------------------------------------------------------------------
function Color:lighten_to(lightness)
   return self:new(self.H, self.S, lightness)
end

---------------------------------------------------------------------------------------------------
-- Creates a new color with lightness set to a old lightness times r.
--
-- @param r              the multiplier for the new lightness
-- @return               a new instance of Color
---------------------------------------------------------------------------------------------------
function Color:lighten_by(r)
   return self:new(self.H, self.S, self.L*r)
end

---------------------------------------------------------------------------------------------------
-- Creates n variations of this color using supplied function and returns them as a table.
--
-- @param f              the function to create variations
-- @param n              the number of variations
-- @return               a table with n values containing the new colors
---------------------------------------------------------------------------------------------------
function Color:variations(f, n)
   n = n or 5
   local results = {}
   for i=1,n do
	  table.insert(results, f(self, i, n))
   end
   return results
end

---------------------------------------------------------------------------------------------------
-- Creates n tints of this color and returns them as a table
--
-- @param n              the number of tints
-- @return               a table with n values containing the new colors
---------------------------------------------------------------------------------------------------
function Color:tints(n)
   local f = function (color, i, n) 
                return color:lighten_to(color.L + (1-color.L)/n*i)
             end
   return self:variations(f, n)
end

---------------------------------------------------------------------------------------------------
-- Creates n shades of this color and returns them as a table
--
-- @param n              the number of shades
-- @return               a table with n values containing the new colors
---------------------------------------------------------------------------------------------------
function Color:shades(n)
   local f = function (color, i, n) 
                return color:lighten_to(color.L - (color.L)/n*i)
             end
   return self:variations(f, n)
end

function Color:tint(r)
      return self:lighten_to(self.L + (1-self.L)*r)
end

function Color:shade(r)
      return self:lighten_to(self.L - self.L*r)
end



