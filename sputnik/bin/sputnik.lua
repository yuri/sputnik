
LUA = "/usr/bin/env lua5.1"
--WITHOUT_LUAROCKS = true  -- uncomment to disable Luarocks

if USE_LUAROCKS then
   pcall(require, "luarocks.require")
end

local function parse_args(arg)
   local parsed = {}
   
   for i,v in ipairs(arg) do
      local flag, val = v:match('^%-%-(%w+)=(.*)')
      if flag then
         parsed[flag] = val
      else
         flag = v:match('^%-%-(.+)')
         if flag then
            parsed[flag] = true
         else
            parsed[#parsed+1] = v
         end
      end
   end
   return parsed
end

local function main()
   local options = parse_args(arg)
   local command = options[1] or "help"
   local config_path = options.config or "sputnik.config"

   config = pcall(dofile, config_path)
   --print(config.VERSIUM_PARAMS[1])   

   local ok, handler = pcall(require, "sputnik.cli."..command)
   if ok then
      handler.execute(options)
   else
      print("Couldn't find or load handler for command '"..command.."'.")
   end
end

main()
