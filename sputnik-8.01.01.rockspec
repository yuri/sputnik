-- Package metadata
package = 'Sputnik'
version = '7.12.26-0'
description = {
  summary = 'A wiki and a framework for wiki-like applications',
  detailed = [[
     Sputnik is a wiki written in Lua. It is also a platform for building a range of wiki-like 
     applications, drawing on Lua's strengths as an extension language.

     Out of the box Sputnik behaves like a wiki with all the standard wiki features: editable 
     pages, protection against spam bots, history view of pages, diff, preview, per-page-RSS feed 
     for site changes. (See http://sputnik.freewisdom.org/en/Features for more details.)

     At the same time, Sputnik is designed to be used as a platform for a wide range of "social 
     software" applications. A simple change of templates and perhaps a few spoons of Lua code can 
     turn it into a photo album, a blog, a calendar, a mailing list viewer, or almost anything else.
     So, you can think of it as a web framework of sorts. In addition to allowing you to add custom 
     bells and whistles to a wiki, Sputnik provides a good foundation for anything that's kind of 
     like a wiki but not quite. Sputnik stores its data as versioned "pages" that can be editable 
     through the web (just like any wiki). However, it allows those pages to store any data that 
     can be saved as text (prose, comma-separated values, lists of named parameters, Lua tables, 
     mbox-formatted messages, XML, etc.) While by default the page is displayed as if it carried 
     Markdown-formatted text, the way the page is viewed (or edited, or saved, etc.) can be 
     overriden on a per-page basis by over-riding or adding "actions". 
  ]],
  license = 'MIT/X11',
  homepage = 'http://sputnik.freewisdom.org/',  
}

-- Dependency information
dependencies = {
  'versium >= 7.12.26',
  'colors >= 7.12.26',
  'markdown >= 0.13',
}

-- Build rules
source = {
  url = 'http://sputnik.freewisdom.org/files/sputnik-package-7.12.26.tar.gz',
  dir = 'sputnik',
}

