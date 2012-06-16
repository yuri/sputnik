module(..., package.seeall)

--require("mime")
--require("ltn12")

CHUNK_LENGTH=78

require("base64")

--local base64 = require("sputnik.util.base64")

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


--base64_encode = base64.enc
--base64_decode = base64.dec
