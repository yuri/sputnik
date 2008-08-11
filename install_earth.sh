# Install Kepler + Sputnik
wget http://luaforge.net/frs/download.php/3468/kepler-install-1.1-1 
bash kepler-install-1.1-1 --prefix=${PWD} --without-readline
./bin/luarocks --only-from=http://sputnik.freewisdom.org/rocks/earth install sputnik 8.08.08
./bin/lua -lluarocks.require -e 'require("sputnik").setup()'
mkdir wiki-data && chmod -R a+rw wiki-data # Make wiki-data directory
