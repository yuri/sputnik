-- installation script for Sputnik with Lua for Windows
require 'lfs'

function quit (msg)
	print('error: '..msg)
	os.exit(1)
end

function system (cmd)
    print(cmd)
    if not os.execute(cmd) then
		quit('*this operation failed')
	end
end

function readfile (file)
	local f,err = io.open(file,'r')
	if not f then quit(err) end
	local s = f:read '*a'
	f:close()
	return s
end

function writefile (file,s)
	local f,err = io.open(file,'w')
	if not f then quit(err) end
	f:write(s)
	f:close()
end

function isdir (f)
	return lfs.attributes(f,'mode') == 'directory'
end

function get_lua_directory ()
    for p in package.path:gmatch '[^;]+' do
        if p:find '^%a:\\' then  -- first full path
            return p:match('(.+)%?')  -- strip the ?.lua pattern
        end
    end
end


local dir = lfs.currentdir()

if not isdir 'lua' or not isdir 'bin' then
	quit('Current directory is '..dir..'\nIs this where you unzipped Sputnik?')
end

--- OK, first copy the Sputnik Lua files onto the Lua path
local lua_dir = get_lua_directory()
print('Lua module directory',lua_dir)

system(([[xcopy /S /Y lua\* "%s"]]):format(lua_dir))

-- make a directory for our Wiki data
if not lfs.mkdir 'wiki-data' then
	quit 'Could not create wiki-data. Do you have permission to write here?'
end

--- Create the local configuration files and patch sputnik.ws
if not lfs.attributes 'sputnik.ws' then
	system [[lua bin\sputnik.lua make-cgi]]
	local ws = readfile 'sputnik.ws'

	ws = ws:gsub("/sputnik.ws","/")                         -- nicer root URL
	ws = ws:gsub("'([^']+)'","[[%1]]")                      -- use long strings so we won't be bothered by path backslashes
	ws = ws:gsub('%,%s}',',\n   SHOW_STACK_TRACE=true,\n}') -- this will make Sputnik tell us about any Lua problems

	writefile('sputnik.ws',ws)
end


--- Make a batch file for launching Sputnik with Xavante
writefile('run.bat',([[
@cd %s
@lua bin\sputnik.lua start-xavante
]]):format(dir))

print '\nSputnik has been installed, and run.bat has been created. You can copy this on your path if you want'







