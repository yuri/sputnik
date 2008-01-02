-- Package metadata
package = 'Sputnik-Tickets'
version = '8.01.01-0'
description = {
  summary = 'A bug-tracking plugin for Sputnik',
  detailed = [[
  ]],
  license = 'MIT/X11',
  homepage = 'http://sputnik.freewisdom.org/',  
}

-- Dependency information
dependencies = {
  'sputnik >= 8.01.01',
}

-- Build rules
source = {
  url = 'http://sputnik.freewisdom.org/files/sputnik-package-7.12.26.tar.gz',
  dir = 'sputnik',
}

