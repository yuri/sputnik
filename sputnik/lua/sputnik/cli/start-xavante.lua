module(..., package.seeall)

local xavante = require("sputnik.xavante")

function execute(args, sputnik)
   xavante.start(args[2] or "./sputnik.ws")
end
