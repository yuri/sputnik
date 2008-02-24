require"luarocks.require"
require"lfs"
require"markdown"
require"cosmo"
require"md5"
require "logging.file"
taglet = require"luadoc.taglet.standard"


---------------------------------------------------------------------------------------------------
-- The main template
---------------------------------------------------------------------------------------------------
HTML_TEMPLATE = [[<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
 <head>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
  <meta name="description" content="$package: $summary"/>
  <meta name="keywords" content="$keywords"/>
  <link rel="shortcut icon" href="$favicon"/>
  <link rel="alternate" type="application/rss+xml" title="New releases of $package" href='$rss'/>
  <title>$package</title>
  <style type="text/css">
    body { color:#000; background:#fff; }
    #header { width:100%;
       text-align:center;  
       border-top:solid #aaa 1px;
       border-bottom:solid #aaa 1px;
    }
    #header p { margin-left:0; }
    p { margin-left:3px; }
    sup.return {font-size: small;}
    a.return {text-decoration: none; color: gray;}
    pre { background-color:#ffe; white-space:pre; padding-left:3ex; border-left: 1px solid gray; margin-left: 10px}

    table.index { border: 1px #00007f; }
    table.index td { text-align: left; vertical-align: top; }
    table.index ul { padding-top: 0em; margin-top: 0em; }

    table {
     border: 1px solid black;
	 border-collapse: collapse;
     margin-left: auto;
     margin-right: auto;
    }
    th {
     border: 1px solid black;
     padding: 0.5em;
    }
    td {
     border: 1px solid black;
     padding: 0.5em;
    }
    div.header, div.footer { margin-left: 0em; }
  </style>
</head>
<body>
 <div id="header">
  <a name="top"></a>
  <img border=0 alt="$package logo" src="$logo"/>
  <p>$summary</p>
  <p>
   <a name="toc"></a>$do_toc[=[<a href="#$anchor">$item</a>]=],[=[ &middot; <a href="#$anchor">$item</a>]=]
  </p>
 </div>
 $body
</body>
</html>
]]

ROCKSPEC_TEMPLATE = [[package = "$package"
version = "$last_version-$revision"
source = {
   url = "$last_release_url",
   md5 = "$md5",
}
description = {
   summary    = "$summary",
   detailed   = [===[$detailed]===],
   license    =  "$license",
   homepage   = "$homepage",
   maintainer = "$maintainer ($email)",
}
dependencies = {
$dependencies}
build = {
$build}

]]

RSS = [===[<rss version="2.0">
 <channel>
  <title>$package</title>
  <description/>
   <link>$homepage</link>
     $do_versions[[
   <item>
    <link>$download</link>
    <title>$package $version</title>
    <guid isPermalink="true">$url</guid>
    <description>$comment</description>
   </item>]]
 </channel>
</rss>
]===]


---------------------------------------------------------------------------------------------------
-- The template for the LuaDoc section
---------------------------------------------------------------------------------------------------
LUADOC = [[
 <table style="width:100%" class="function_list">
 $do_modules[=[
  <tr>
   <td colspan=2 style='background: #dddddd;'>
    <h2>$module</h2>
    <p>$description</p>
    $if_release[==[Release: $release]==]
   </td>
  </tr>
  $do_functions[==[
   <tr>
	<td class="name" width="300px" style="vertical-align: top;"><b>$fname()</b></td>
	<td class="summary" >$summary
     <dl>
      $do_params[===[<dt><color="green"><b>$param</b></font>: <dd>$description</dd></dt>]===]
     </dl>
     Returns: $do_returns[====[<font color="purple">$ret</color>]====],[====[<b>$i.</b> <font color="purple">$ret</color>]====]
    </td>
   </tr>
  ]==]
 ]=]
 </table>
]]


MIT_X_LICENSE_EXPLAIN = [[

Copyright © $copyyears $author.

$package is free software: it can be used for both academic and
commercial purposes at absolutely no cost.  There are no royalties or
GNU-like "copyleft" restrictions. $package qualifies as Open Source
software.  Its licenses are compatible with GPL. The legal details are
below.

The spirit of the license is that you are free to use $package for any
purpose at no cost without having to ask us. The only requirement is
that if you do use $package, then you should give us credit by including
the appropriate copyright notice somewhere in your product or its
documentation.

The $package library is designed and implemented by $author.  $authorship_details
]]

MIT_X_LICENSE = [[

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

---------------------------------------------------------------------------------------------------
-- Generates LuaDoc
---------------------------------------------------------------------------------------------------

function luadoc(modules)
   lfs.chdir("src")
   taglet.logger = logging.file("luadoc.log")
   taglet.options = {}
   local doc = taglet.start(modules)
   lfs.chdir("..")

   return cosmo.f(LUADOC){
       do_modules = function() for i, name in ipairs(doc.modules) do
                       local m = doc.modules[name]
                       cosmo.yield {
                          module       = name,
                          description  = m.description,
                          if_release   = cosmo.c(m.release){release = m.release},
                          do_functions = function() for j, fname in ipairs(m.functions) do
                                            local f = m.functions[fname]
                                            cosmo.yield{
                                            fname = fname,
                                            summary = f.summary,
                                            do_params  = function() for p = 1, #(f.param or {})do
                                                            cosmo.yield{param=f.param[p], description = f.param[f.param[p]] }
                                                         end end,
                                            do_returns = function() if type(f.ret) == "string" then 
                                                            cosmo.yield{ret=f.ret, i=1}
                                                         elseif type(f.ret) == "table" then
                                                            for k,r in ipairs(f.ret) do
                                                               cosmo.yield{ i=k, ret=r, _template=2}
                                                            end
                                                         end end,
                                         }
                                         end end,
                       }
                       end end,
    }
end


---------------------------------------------------------------------------------------------------
-- Used to include the content of another file
---------------------------------------------------------------------------------------------------

function include(path)
   local f, x = io.open(path)
   return f:read("*all")
end



---------------------------------------------------------------------------------------------------
-- "Main"
---------------------------------------------------------------------------------------------------

function petrodoc(spec, revision, name)

   function fill_and_save(path, content)
      local f = io.open(path, "w")
      f:write(cosmo.lazy_fill(content, spec))
      f:close()
   end

   -- fill in the necessary parameters
   spec.name = name
   spec.last_version = spec.versions[1][1]
   spec.version = spec.last_version
   spec.last_release_url = cosmo.fill(spec.download, spec)
   spec.dirs = spec.dirs or {"src", "docs", "LICENSE.txt"}
   spec.favicon = spec.favicon or 'http://www.lua.org/favicon.ico'
   spec.do_versions = function() 
                         for i, version in ipairs(versions) do
                            spec.version = version[1]
                            spec.date = version[2]
                            spec.comment = version[3]
                            spec.url = cosmo.fill(spec.download, spec)
                            cosmo.yield(spec)
                         end
                      end
   spec.body = ""
   for i,item in ipairs(spec.toc) do
      spec.anchor = item[1]
      spec.h1 = item[1]
      spec.text = cosmo.lazy_fill(item[2], spec)
      spec.body=spec.body..cosmo.lazy_fill('\n\n<a name="$anchor"></a><h1>$h1<sup class="return"><a class="return" href="#top">&uarr;</a></sup></h1>\n$text\n', spec)
   end

   spec.do_toc = function()
                     for i, item in ipairs(spec.toc) do
                        --item.anchor = string.gsub(item[1], "([^%w]*)", "_")
                        local template = 1
                        if i > 1 then template = 2 end
                        cosmo.yield {
                           anchor = item[1],
                           item = item[1],
                           _template = template
                        }
                     end
                  end

   spec.dependencies = spec.dependencies or ""
   spec.revision = revision
   spec.download_filled = cosmo.fill(spec.download, spec)

   -- generate the license
   fill_and_save("LICENSE.txt", spec.license_txt)

   -- generate the html file
   fill_and_save("docs/index.html", HTML_TEMPLATE)
   fill_and_save("tmp/index.html", HTML_TEMPLATE)

   -- make an archive
   local archive_name = spec.name.."-"..spec.last_version
   lfs.chdir("tmp")
   os.remove(archive_name..".zip")
   lfs.mkdir(archive_name)   
   for i, dir in ipairs(spec.dirs) do
      os.execute("cp -r ../"..dir.." "..archive_name.."/")
      os.execute("zip -r "..archive_name..".zip".." "..archive_name.."/"..dir.." -x *.svn/* *~ *log")
   end
   spec.md5 = md5.sumhexa(io.open(archive_name..".zip"):read("*all"))
   lfs.chdir("..")

   -- make the rockspec
   spec.version = spec.versions[1][1]
   fill_and_save("tmp/"..spec.name.."-"..spec.last_version.."-"..revision..".rockspec", ROCKSPEC_TEMPLATE)

   -- make the RSS feed
   fill_and_save("tmp/releases.rss", RSS)
end


local dir = arg[1].."/"..arg[2]
lfs.chdir(dir)
local petrofunc, err = loadfile("petrodoc")
if not petrofunc then error(err) end

local spec = getfenv(petrofunc())
petrodoc(spec, arg[3] or "0", arg[2])


