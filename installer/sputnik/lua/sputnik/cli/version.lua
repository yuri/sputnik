module(..., package.seeall)

local installer = require("sputnik.installer")

USAGE = [[
NAME:
        sputnik version

SYNOPSIS:

        sputnik version

DESCRIPTION:

        Shows the version of Sputnik.
]]

version = require ("sputnik.doc.version")

function execute(args, sputnik)
   print (version.VERSION or "Unknown")
end
