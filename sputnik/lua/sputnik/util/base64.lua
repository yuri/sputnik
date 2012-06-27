module(..., package.seeall)

CHUNK_LENGTH=78

local base64_loaded, base64 = pcall(require, "base64")
if not base64_loaded then
   base64 = require("sputnik.util.base64_implementation")
end
encode = base64.encode
decode = base64.decode

function encode_and_wrap(binary_content) 
   local encoded = encode(binary_content)
   local wrapped = "\n"
   for i=1, encoded:len(),CHUNK_LENGTH-1 do
      wrapped = wrapped..encoded:sub(i, i+CHUNK_LENGTH-2).."\n"
   end
   return wrapped
end

