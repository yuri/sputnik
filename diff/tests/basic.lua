

require"diff"




-- Print test split

TO_BE = [[To <b>be</b>, or not to be:
     that is the question:
   Whether 'tis nobler in the mind to suffer
        The slings and arrows of outrageous fortune,
       Or to take arms against a sea of troubles,
And by opposing end them?
]]

TO_BE_2 = [[To <b>be</b>, and <i>not</i> to be:
     that is the question:
   Whether 'tis nobler in the mind to suffer
        The slings and arrows of outrageous fortune,
       Or to take legs against a sea of troubles,
And by opposing end them?
]]

HTML_DIFF = [[To &lt;b&gt;be&lt;/b&gt;, <del>or</del><ins>and</ins> <del>not</del><ins>&lt;i&gt;not&lt;/i&gt;</ins> to be:
     that is the question:
   Whether 'tis nobler in the mind to suffer
        The slings and arrows of outrageous fortune,
       Or to take <del>arms</del><ins>legs</ins> against a sea of troubles,
And by opposing end them?
]]

SPLIT_1 = { "To", " ", "<b>be</b>,", " ", "or", " ", "not", " ", "to", " ", "be:", "\
     ", "that", " ", "is", " ", "the", " ", "question:", "\
   ", "Whether", " ", "'tis", " ", "nobler", " ", "in", " ", "the", " ",
"mind", " ", "to", " ", "suffer", "\
        ", "The", " ", "slings", " ", "and", " ", "arrows", " ", "of", " ",
"outrageous", " ", "fortune,", "\
       ", "Or", " ", "to", " ", "take", " ", "arms", " ", "against", " ",
"a", " ", "sea", " ", "of", " ", "troubles,", "\
", "And", " ", "by", " ", "opposing", " ", "end", " ", "them?", "\
"}

SPLIT_2 = { "To <b>be</b>, or not to be:",
 "     that is the question:",
 "   Whether 'tis nobler in the mind to suffer",
 "        The slings and arrows of outrageous fortune,",
 "       Or to take arms against a sea of troubles,",
 "And by opposing end them?"
}


local result = diff.split(TO_BE)
for i,v in ipairs(result) do
   --print(string.format("[%s], [%s]", v, SPLIT_1[i]))
   assert(v==SPLIT_1[i])
end

local result = diff.split(TO_BE, "\n", true)
for i,v in ipairs(result) do
   --print(string.format("[%s], [%s]", v, SPLIT_1[i]))
   assert(v==SPLIT_2[i])
end


--for i, v in ipairs(diff.diff(TO_BE, TO_BE_2)) do
--   if v[2]~="same" then
--      print (v[1], v[2])
--   end
--end



d = diff.diff(TO_BE, TO_BE_2):to_html()
assert(d == HTML_DIFF)


--buffer = ""
--for i,v in ipairs(result) do
--   buffer = buffer..string.format(" %q,", v)
--end
--print (buffer)
