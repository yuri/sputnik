module(..., package.seeall)
require("mime")
CHUNK_LENGTH = 78

USAGE = [[
NAME:
        sputnik encode-binary

SYNOPSIS:

        sputnik encode-binary <path>

DESCRIPTION:

        Encodes a binary file for including in Sputnik as a binary node.
        
OPTIONS:

        <path>
            The path to the file that is to be encoded.

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
