package = "SACI"
version = "12.06.04-0"
source = {
   url = "http://spu.tnik.org/files/saci-12.06.04.tar.gz",
}
description = {
   summary    = "Saci is a document-oriented hierarchical storage system",
   detailed   = [===[    A document-to-object mapper for Lua.
]===],
   license    =  "MIT/X11",
   homepage   = "http://spu.tnik.org/en/Saci",
   maintainer = "Yuri Takhteyev (yuri@freewisdom.org)",
}
dependencies = {
  'cosmo >= 7.12.24',
}
build = {
  type = "none",
  install = {
     lua = {        ["saci"] = "lua/saci.lua",
        ["versium.util"] = "lua/versium/util.lua",
        ["versium.filedir"] = "lua/versium/filedir.lua",
        ["versium.git"] = "lua/versium/git.lua",
        ["versium.virtual"] = "lua/versium/virtual.lua",
        ["versium.errors"] = "lua/versium/errors.lua",
        ["versium.sqlite3"] = "lua/versium/sqlite3.lua",
        ["versium.keyvalue"] = "lua/versium/keyvalue.lua",
        ["versium.mysql"] = "lua/versium/mysql.lua",

        ["saci.node"] = "lua/saci/node.lua",
        ["saci.sandbox"] = "lua/saci/sandbox.lua",
        ["saci.search"] = "lua/saci/search.lua",

     }
  }
}

