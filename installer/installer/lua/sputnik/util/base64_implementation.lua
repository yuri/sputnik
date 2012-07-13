module(..., package.seeall)

-----------------------------------------------------------------------------
-- Implements base64 encoding and decoding
--
-- This module was originally based on Daniel Lindsley's implementation:
--     https://github.com/toastdriven/lua-base64/
-- 
-- It was then substantially rewritten by Yuri for better accuracy and
-- performance.
--
-- (c) 2012 Daniel Lindsley, Yuri Takhteyev
-- License: BSD
-----------------------------------------------------------------------------

-- prepare a mapping from base64 alphabet to numbers and back
local base64_alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
                        .."abcdefghijklmnopqrstuvwxyz"
                        .."0123456789+/"
local int_to_letter = {}
local letter_to_int = {}
local position = 0
for letter in base64_alphabet:gmatch(".") do
    int_to_letter[position]=letter
    letter_to_int[letter]=position
    position = position + 1
end

-- prepare a mapping of hex codes to binary sequences so that we could 
-- later use string.format("%x",...") to convert to binary
local hex_to_binary = {
   ['0'] = "0000", ['1'] = "0001", ['2'] = "0010", ['3'] = "0011",
   ['4'] = "0100", ['5'] = "0101", ['6'] = "0110", ['7'] = "0111",
   ['8'] = "1000", ['9'] = "1001", ['a'] = "1010", ['b'] = "1011",
   ['c'] = "1100", ['d'] = "1101", ['e'] = "1110", ['f'] = "1111"
}

function encode(to_encode)    
    -- prepare a gsub substitution function to convert bytes into binary
    local byte_as_int
    local function byte_to_bits(byte)
        byte_as_int = string.byte(byte)
        return hex_to_binary[string.format("%x", byte_as_int/16)]
               ..hex_to_binary[string.format("%x", byte_as_int%16)]
    end
    local bit_pattern = to_encode:gsub(".", byte_to_bits)

    -- Check the number of bytes. If it's not evenly divisible by three,
    -- zero-pad bit_patter and append the correct number of ``=``s to the
    -- final output.
    local trailing = ''
    local remainder = string.len(bit_pattern) % 3
    if remainder == 2 then
        trailing = '=='
        bit_pattern = bit_pattern..'0000000000000000'
    elseif remainder == 1 then
        trailing = '='
        bit_pattern = bit_pattern..'00000000'
    end
    
    -- prepare a gsub function to convert six-bit sequences into characters
    local function bits_to_letters(chunk)
       return int_to_letter[tonumber(chunk, 2)]
    end
    -- use it to convert the bit patter into letters, taking up to six bits
    -- at a time
    local encoded = bit_pattern:gsub("..?.?.?.?.?", bits_to_letters)
    
    -- insert the last characters with trailing "=" if necessary
    return encoded:sub(1, -1 - string.len(trailing)) .. trailing
end

function decode(to_decode)
    local padded = to_decode:gsub("%s", "")
    local unpadded = padded:gsub("=", "")

    -- setup a substituter function to use inside gsub
    local code
    local function letter_to_bits(char)
       code = letter_to_int[char]
       return string.sub(hex_to_binary[string.format("%x", code/16)]
                         ..hex_to_binary[string.format("%x", code%16)], 3)
    end
    -- convert the unpadded input into bits using gsub
    local bit_pattern = unpadded:gsub(".", letter_to_bits)

    -- prepare another substitution function
    local function bits_to_binary(eight_bit_chunk)
       return string.char(tonumber(eight_bit_chunk, 2))
    end
    -- use it to convert the bit string to binary, grabbing <=8 bits at a time
    local decoded = bit_pattern:gsub("..?.?.?.?.?.?.?", bits_to_binary)

    -- check if we need to remove a null byte from the end
    local padding_length = padded:len()-unpadded:len()
    if (padding_length == 1 or padding_length == 2) then
        decoded = decoded:sub(1,-2)
    end
    return decoded
end

