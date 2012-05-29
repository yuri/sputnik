module(..., package.seeall)

local GENERIC_USAGE = [[
usage: sputnik <command> [--option1=value] [--option2=value]

Some of the possible commands on which you can get help:

    make-cgi
    start-xavante
    encode-binary

See 'sputnik help <command>' for more information on a specific command.
]]

function execute(args, sputnik)
   local command = args[2]
   if command then
      local ok, handler = pcall(require, "sputnik.cli."..command)
      if ok then
         if handler.USAGE then
            print (handler.USAGE)
         else
            print ("No help is available for this command.")
         end
      else
         print("Couldn't find or load help information for command '"..command.."'.")
      end
   else
      print (GENERIC_USAGE)
   end
end
