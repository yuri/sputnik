package = "Sputnik-Binary-Dependencies"
version = "9.02.15-0"
source = {
  url = "http://spu.tnik.org/files/dummy.tar.gz",
}
description = {
   summary    = "A virtual rock that pulls together binary dependencies for Sputnik",
   detailed   = "",
   license    =  "MIT/X11",
   homepage   = "",
   maintainer = "Yuri Takhteyev (yuri@freewisdom.org)",
}
dependencies = {
  'luafilesystem >= 1.4.1',
  'lpeg >= 0.9', 
  'md5 >= 1.1',
  'luasocket >= 2.0',
  'rings >= 1.2.2',
}

build = {
  type = 'none'
}

