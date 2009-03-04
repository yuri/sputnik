
pcall(require, "luarocks.require")

local function parse_args(arg)
   local parsed = {}
   for i,v in ipairs(arg) do
      local flag, val = v:match('^%-%-(%w+)=(.*)')
      if flag then
         parsed[flag] = val
      else
         flag = v:match('^%-%-(%w+)')
         if flag then
            parsed[flag] = true
         else
            parsed[#parsed+1] = v
         end
      end
   end
   return parsed
end

BASIC_USAGE = [[

Sputnik - A Extensible Wiki in Lua

Usage: sputnik <command> --option1=value --option2=value

Some of the possible commands are:

    start-xavante
    make-cgi
]]

local function main()
   local options = parse_args(arg)

   local command = options[1]
   if not command then
      print(BASIC_USAGE)
      return
   end

   local config_path = options.config or "sputnik.config"

   config = pcall(dofile, config_path)
   --print(config.VERSIUM_PARAMS[1])   

   local ok, handler = pcall(require, "sputnik.cli."..command)
   if ok then
      handler.execute(options)
   else
      print("Couldn't find handler for command '"..command.."'.")
   end
end

main()
