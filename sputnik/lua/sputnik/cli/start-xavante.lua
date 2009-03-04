module(..., package.seeall)

local xavante = require("sputnik.xavante")

function execute(args, sputnik)
   xavante.start(args.webdir or ".")
end
