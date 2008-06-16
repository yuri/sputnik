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
-- @param options        [optional] a table of options.
-- @return               the original node id.
-----------------------------------------------------------------------------
function fs_unescape_id(id, options)
   assert(id and id:len() > 0)
   if (options or {}).keep_slash then
      return id:gsub("%%3A", ":"):gsub("%%25", "%%")
   else
      return id:gsub("%%2F", "/"):gsub("%%3A", ":"):gsub("%%25", "%%")
   end
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

function format_time(timestamp, format)
   return os.date(format, os.time{ year=timestamp:sub(1,4), month=timestamp:sub(6,7),
                                   day=timestamp:sub(9,10), hours=timestamp:sub(12,13),
                                   min=timestamp:sub(15,16), sec=timestamp:sub(18)} )
end
