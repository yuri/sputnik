require"luarocks.require"
require"luarocks.pack"
require"luarocks.build"
require"luarocks.make_manifest"
require"lfs"
require"markdown"
require"cosmo"
require "logging.file"
taglet = require"luadoc.taglet.standard"


---------------------------------------------------------------------------------------------------
-- The main HTML template
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


---------------------------------------------------------------------------------------------------
-- A template for an RSS feed about releases
---------------------------------------------------------------------------------------------------

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


---------------------------------------------------------------------------------------------------
-- The rockspec template
---------------------------------------------------------------------------------------------------

ROCKSPEC_TEMPLATE = [[package = "$package"
version = "$last_version-$revision"
source = {
   url = "$last_release_url",
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


---------------------------------------------------------------------------------------------------
-- A template for the build section of the rockspec
---------------------------------------------------------------------------------------------------

BUILD_TEMPLATE = [[
  type = "none",
  install = {
     lua = {%s     }
  }
]]

---------------------------------------------------------------------------------------------------
-- Generates LuaDoc
---------------------------------------------------------------------------------------------------

function luadoc(modules)
   lfs.chdir("lua")
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
-- Includes the content of another file.
---------------------------------------------------------------------------------------------------

function include(path)
   print(lfs.currentdir())
   print(path)
   local f, x = io.open(path)
   return f:read("*all")
end


---------------------------------------------------------------------------------------------------
-- Makes a map from module names to file paths for the "none" build.
---------------------------------------------------------------------------------------------------

function make_module_map(dir, subtract)
   local mode = lfs.attributes(dir).mode
   if mode == "file" then
      local path = string.gsub(dir, subtract, "")
      if string.match(path, "%.lua$") then
         local mod = path:gsub("%.lua$", ""):gsub("%/", ".")
         return string.format([=[        ["%s"] = "lua/%s",]=], mod, path)
      end 
   elseif mode == "directory" then
      local buffer = ""
      for child in lfs.dir(dir) do
         if not (child=="." or child=="..") then
            buffer=buffer..make_module_map(dir.."/"..child, subtract).."\n"
         end
      end
      return buffer
   end
   return ""
end


---------------------------------------------------------------------------------------------------
-- Does everything ("Main")
---------------------------------------------------------------------------------------------------

function petrodoc(name, spec, revision, server)

   function fill_and_save(path, content)
      local f = io.open(path, "w")
      f:write(cosmo.fill(content, spec))
      f:close()
   end

   -- fill in the necessary parameters
   spec.name = spec.package:lower()
   spec.last_version = spec.versions[1][1]
   spec.version = spec.last_version
   spec.last_release_url = cosmo.fill(spec.download, spec)
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
   if not spec.build then 
      spec.build = string.format(BUILD_TEMPLATE, make_module_map(name.."/lua", name.."/lua/"))
   end

   -- generate the documentation page
   spec.body = ""
   for i,item in ipairs(spec.TOC) do
      spec.anchor = item[1]
      spec.h1 = item[1]
      spec.text = cosmo.fill(item[2], spec)
      spec.body=spec.body..cosmo.fill('\n\n<a name="$anchor"></a><h1>$h1<sup class="return"><a class="return" href="#top">&uarr;</a></sup></h1>\n$text\n', spec)
   end
   spec.do_toc = function()
                     for i, item in ipairs(spec.TOC) do
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

   fill_and_save(name.."/docs/index.html", HTML_TEMPLATE)
   fill_and_save(name.."/docs/releases.rss", RSS)

   -- make a release
   local released_rock_dir = name.."-"..spec.last_version
   os.execute("cp -r "..name.." "..released_rock_dir)
   os.execute("tar czvpf "..released_rock_dir..".tar.gz "..released_rock_dir)

   -- publish it
   if server then 
      os.execute("scp "..released_rock_dir..".tar.gz "..server)
   end

   -- make the rockspec
   local rockspec = released_rock_dir.."-"..revision..".rockspec"
   fill_and_save(rockspec, ROCKSPEC_TEMPLATE)

   -- pack the rock
   luarocks.pack.run(rockspec)
   luarocks.build.run(rockspec)
   luarocks.make_manifest.run()
   luarocks.pack.run(name, spec.last_version.."-"..revision)   

end


local cwd = lfs.currentdir()
local rock = arg[1]
lfs.chdir(rock)
print(lfs.currentdir())
local petrofunc, err = loadfile("petrodoc")
if not petrofunc then error(err) end
local spec = getfenv(petrofunc())
lfs.chdir(cwd)

petrodoc(rock, spec, arg[2] or "0", arg[3])


