-----------------------------------------------------------------------------
-- Provides some utility functions for use by versium and its clients.
--
-- (c) 2007, 2008  Yuri Takhteyev (yuri@freewisdom.org)
-- (c) 2007 Hisham Muhammad (quick_LCS())
-- License: MIT/X, see http://sputnik.freewisdom.org/en/License
-----------------------------------------------------------------------------

module(..., package.seeall)
local errors = require"versium.errors"

-----------------------------------------------------------------------------
-- Escapes a node id to make it safe for use as a file name.
-- 
-- @param id             a node id.
-- @return               an escaped node id.
-----------------------------------------------------------------------------
function fs_escape_id(id)
   assert(id and id:len() > 0)
   return fs_escape_id_but_keep_slash(id):gsub("/", "%%2F")
end

-----------------------------------------------------------------------------
-- Escapes a node id to make it safe for use as a file name, but keeps
-- forward slash in it.
-- 
-- @param id             a node id.
-- @return               an escaped node id.
-----------------------------------------------------------------------------
function fs_escape_id_but_keep_slash(id, options)
   return id:gsub("%%", "%%25"):gsub(":", "%%3A")
end

-----------------------------------------------------------------------------
-- Un-escapes a node id. (See escape_id().)
-- 
-- @param id             an escaped node id.
-- @return               the original node id.
-----------------------------------------------------------------------------
function fs_unescape_id(id)
   assert(id and id:len() > 0)
   return id:gsub("%%2F", "/"):gsub("%%3A", ":"):gsub("%%25", "%%")
end

-----------------------------------------------------------------------------
-- Writes data to a file (to be replaced with atomic write).
-- 
-- @param path           the file path.
-- @param data           data to be written to the file.
-- @return               nothing
-----------------------------------------------------------------------------
function write_file(path, data, node)
   assert(path)
   assert(data)
   local f, err = io.open(path, "w")
   assert(f, errors.could_not_save(node, err))
   f:write(data)
   f:close()
end

-----------------------------------------------------------------------------
-- An auxiliary function for reading the content of a file.  (Throws an a 
-- Versium-specific error if something goes wrong.)
-- 
-- @param path           the file path.
-- @return               the data read from the file as a string.
-----------------------------------------------------------------------------
function read_file(path, node)
   assert(path)
   local f, err = io.open(path)
   assert(f, errors.could_not_read(node, err))
   local data = f:read("*all")
   f:close()
   return data
end

-----------------------------------------------------------------------------
-- Reads data from a file without complaining if the file doesn't exist.
-- 
-- @param path           the file path.
-- @return               the data read from the file or just "" if the file 
--                       doesn't exist.
-----------------------------------------------------------------------------
function read_file_if_exists(path)
   assert(path)
   local status, f = pcall(io.open, path)
   if status and f then
      local data = f:read("*all")
      f:close()
      return data
   else
      return ""
   end
end

-----------------------------------------------------------------------------
-- Converts a versium time stamp into the requested format.  Uses some code
-- from http://lua-users.org/wiki/TimeZone)
--
-- @param timestamp      Versium timestamp (string) 
-- @param format         Lua time format (string) 
-- @param tzoffset       time zone offset as "+hh:mm" or "-hh:mm"
--                        (ISO 8601) or "local" [string, optional, defaults 
--                        to "local"]
-- @param tzname         name/description of the time zone [string, optional,
--                        defaults to tzoffset, valid XHTML is ok]
-- @return               formatted time (string)
-----------------------------------------------------------------------------

function format_time(timestamp, format, tzoffset, tzname)
   if tzoffset == "local" then  -- calculate local time zone (for the server)
      local now = os.time()
      local local_t = os.date("*t", now)
      local utc_t = os.date("!*t", now)
      local delta = (local_t.hour - utc_t.hour)*60 + (local_t.min - utc_t.min)
      local h, m = math.modf( delta / 60)
      tzoffset = string.format("%+.4d", 100 * h + 60 * m)
   end
   tzoffset = tzoffset or "GMT"
   format = format:gsub("%%z", tzname or tzoffset)
   if tzoffset == "GMT" then 
      tzoffset = "+0000"
   end
   tzoffset = tzoffset:gsub(":", "")

   local sign = 1
   if tzoffset:sub(1,1) == "-" then
      sign = -1
      tzoffset = tzoffset:sub(2)
   elseif tzoffset:sub(1,1) == "+" then
      tzoffset = tzoffset:sub(2)       
   end
   tzoffset = sign * (tonumber(tzoffset:sub(1,2))*60 + tonumber(tzoffset:sub(3,4)))*60
   return os.date(format, os.time{ year=timestamp:sub(1,4), month=timestamp:sub(6,7),
                                   day=timestamp:sub(9,10), hour=timestamp:sub(12,13),
                                   min=timestamp:sub(15,16), sec=timestamp:sub(18)} + tzoffset)
end
