-- Package metadata
package = 'Versium'
version = '8.01.01-0'
description = {
  summary = 'A versioned storage system',
  detailed = [[
     Versium contains two layers.  The first layer represents a simple abstract API over several 
     storage solutions, all of which provide access to a collection of versioned documents or 
     nodes. Nodes are supposed to be represented as strings (at least by default), but no 
     assumptions is made about their content.  The user interacts with this layer of Versium via 
     the versium module, which then delegates some of the work to a specific storage implementation. 
     The two implementations that are currently supported are a simple file-based storage and a 
     subversion binding.

     The second layer represents the case where Versium is used to store a collection of tables,
     each of which is converted into a sequence of Lua assignments for storage.  This layer, 
     available in versium.smart package also allows for the prototype inheritance between the 
     stored tables.
  ]],
  license = 'MIT/X11',
  homepage = 'http://sputnik.freewisdom.org/en/Versium',
  maintainer = 'Yuri Takhteyev (yuri@freewisdom.org)'
}

-- Dependency information
dependencies = {
  'cosmo >= 7.12.26',
  'luafilesystem >= 1.3'
}

-- Build rules
source = {
  url = 'http://sputnik.freewisdom.org/files/versium-7.12.26.tar.gz',
  dir = 'versium',
}
