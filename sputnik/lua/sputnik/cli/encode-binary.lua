module(..., package.seeall)

local base64 = require("sputnik.util.base64")

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

   local raw = io.open(path, "rb"):read("*all")
   local encoded = base64.encode_and_wrap(raw)
   
   if base64.decode(encoded)~=raw then
      print ("FAILED ROUNDTRIP")
   else
      print(encoded)
   end
end
