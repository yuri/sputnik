module(..., package.seeall)

local params = require("sputnik.doc.params")

USAGE = [===[
NAME:
        sputnik topic

SYNOPSIS:

        sputnik topic [<topic>]

DESCRIPTION:

        Provides information about configuration parameters by topic/area.
        
OPTIONS:

        <topic>
            The topic/area on which information is sought. If left blank, a
            full list of topics will be shown.
]===]

function execute(args, sputnik)
   local key = args[2]
   if key then
      if params.topics[key] then
         print (params.topics[key])
      else
         print ("No such topic.")
      end
   else
      local ordered = {}
      for k,v in pairs(params.topics) do
         table.insert(ordered, k)
      end
      table.sort(ordered)
      
      print ("Please specify the topic. Possible topics are: ")
      print ()
      for i,v in ipairs(ordered) do
         print ("     "..v)
      end
      print ()
   end
end
