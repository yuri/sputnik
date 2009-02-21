module(..., package.seeall)

local xavante = require("sputnik.xavante")

function execute(args, sputnik)
   assert(args.webdir)
   xavante.start(args.webdir)
end
