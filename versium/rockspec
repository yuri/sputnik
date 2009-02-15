package = "Versium"
version = "9.02.15-0"
source = {
   url = "http://spu.tnik.org/files/versium-9.02.15.tar.gz",
}
description = {
   summary    = "A versioned storage API for Lua",
   detailed   = [===[     Versium is a simple abstract API over several storage solutions, all of 
     which provide access to a collection of versioned documents or "nodes".
     Nodes carry Lua byte-string data as their payload, but no assumptions
     are made about its content.  The client interacts with versium through
     the "versium" module, which then delegates most of the work to a 
     specific storage implementation (specified at the initialization time).
     Two storage implementations are included with this rock: "simple" which
     stores nodes and their histories on the file system and "virtual" which
     stores them in memory.  Other implementations (e.g., using subversion or
     a database) are provided as separate rocks.
]===],
   license    =  "MIT/X11",
   homepage   = "http://spu.tnik.org/en/Versium",
   maintainer = "Yuri Takhteyev (yuri@freewisdom.org)",
}
dependencies = {
  'luafilesystem >= 1.3',
  'diff == 8.06.15',
}
build = {
  type = "none",
  install = {
     lua = {        ["versium.util"] = "lua/versium/util.lua",
        ["versium.filedir"] = "lua/versium/filedir.lua",
        ["versium.virtual"] = "lua/versium/virtual.lua",
        ["versium.errors"] = "lua/versium/errors.lua",

     }
  }
}

