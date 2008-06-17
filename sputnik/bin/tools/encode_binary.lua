
require"base64"
CHUNK_LENGTH = 78

local long_line = base64.encode(io.open(arg[1]):read("*all"))
content = "\n"
for i=1,long_line:len(),CHUNK_LENGTH-1 do
   content = content..long_line:sub(i, i+CHUNK_LENGTH-2).."\n"
end
print(content)
