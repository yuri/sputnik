mkdir sputnik
cd sputnik
wget http://luaforge.net/frs/download.php/3468/kepler-install-1.1-1 
bash kepler-install-1.1-1 --prefix=${PWD} --without-readline --without-kepler
./bin/luarocks install md5
./bin/luarocks install lpeg
./bin/luarocks install rings
./bin/luarocks install luasocket
./bin/luarocks install luafilesystem
cp /tmp/sputnik-9-02-11b.zip .
unzip sputnik-9-02-11b.zip 
mv sputnik-9-02-11b/* share/lua/5.1/
./bin/lua -lluarocks.require -e 'require("sputnik").setup()'
mkdir web
mv sputnik.ws web/
mkdir wiki-data && chmod -R a+rw wiki-data
./bin/lua -e 'require("sputnik.xavante").start("./web/")'

