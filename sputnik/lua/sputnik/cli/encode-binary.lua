module(..., package.seeall)
require("mime")
CHUNK_LENGTH = 78

USAGE = [[
sputnik encode-binary /path/to/binary.file
]]

function execute(arg, sputnik)
   local path = arg[2]
   assert(path, "Please specify path to the file")

   print("\nBase64 encoding for "..path..":")

   local long_line = mime.b64(io.open(path):read("*all"))
   content = "\n"
   for i=1,long_line:len(),CHUNK_LENGTH-1 do
      content = content..long_line:sub(i, i+CHUNK_LENGTH-2).."\n"
   end
   print(content)
end
