mkdir /tmp/sputnik
cd /tmp/sputnik/

wget http://luaforge.net/frs/download.php/3468/kepler-install-1.1-1 
bash kepler-install-1.1-1 --prefix=${PWD} --without-readline --without-kepler
./bin/luarocks --only-from=http://spu.tnik.org/rocks/fenchurch install sputnik-binary-dependencies

./bin/luarocks --only-from=http://spu.tnik.org/rocks/fenchurch install sputnik
./bin/luarocks --only-from=http://spu.tnik.org/rocks/fenchurch install xavante
./bin/lua -lluarocks.require -e 'require("sputnik").setup()'
mkdir wiki-data && chmod -R a+rw wiki-data

#./bin/lua -lluarocks.require -e 'require("sputnik.xavante").start("./")'

