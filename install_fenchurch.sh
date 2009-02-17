mkdir /tmp/sputnik
cd /tmp/sputnik/

## Install Lua with luafilesystem, lpeg, md5, luasocket, rings

wget http://luaforge.net/frs/download.php/3468/kepler-install-1.1-1 
yes | bash kepler-install-1.1-1 --prefix=${PWD} --without-readline --without-kepler
./bin/luarocks --only-from=http://spu.tnik.org/rocks/fenchurch install sputnik-binary-dependencies

## Install Sputnik and Pure-Lua Dependencies

If you installed LuaRocks in the step above, then you can use it to install Sputnik and Xavante.

./bin/luarocks --only-from=http://spu.tnik.org/rocks/fenchurch install sputnik
./bin/luarocks --only-from=http://spu.tnik.org/rocks/fenchurch install xavante

*Alternatively*, you can just get the Lua source for Sputnik and all of it's pure-Lua dependencies from

and copy the the files and directories in the "lua" folder to some place where your Lua installation will find them.



## Setup

./bin/lua -lluarocks.require -e 'require("sputnik").setup()'
mkdir wiki-data && chmod -R a+rw wiki-data

## Run Sputnik Using Xavante

./bin/lua -lluarocks.require -e 'require("sputnik.xavante").start("./")'

There is no bin/xavante_start.sh anymore, but you can put the line above into a shell script.

