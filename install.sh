SPUTNIK_DIR=`pwd`
# Install Kepler, with both Xavante and CGI launchers -------------------------
TMP=$SPUTNIK_DIR/tmp/
mkdir $TMP && cd $TMP
wget http://sputnik.freewisdom.org/files/kepler-1.1-snapshot-20071217-2000.tar.gz
tar xvzf kepler-1.1-snapshot-20071217-2000.tar.gz
cd kepler-1.1
./configure --prefix=$SPUTNIK_DIR --launcher=xavante --without-readline --enable-lua --lua-suffix=5.1 > log.txt
make && make install
./configure --prefix=$SPUTNIK_DIR --launcher=cgi --without-readline --enable-lua --lua-suffix=5.1 > log.txt
make && make install
# Install LuaRocks ------------------------------------------------------------
cd $TMP && wget http://luaforge.net/frs/download.php/3152/luarocks-0.4.2.tar.gz
tar xvzf luarocks-0.4.2.tar.gz && cd luarocks-0.4.2
./configure --with-lua=$SPUTNIK_DIR --with-lua-include=$SPUTNIK_DIR/include/ --prefix=$SPUTNIK_DIR --default-config=$SPUTNIK_DIR/etc/luarocks_config
make && make install 
# Configure Luarocks and install Sputnik --------------------------------------
echo "repo_dir='$SPUTNIK_DIR/rocks'" > $SPUTNIK_DIR/etc/luarocks_config
echo "scripts_dir = '$SPUTNIK_DIR/bin'" >> $SPUTNIK_DIR/etc/luarocks_config
echo "repositories = {'http://sputnik.freewisdom.org/rocks'}" >> $SPUTNIK_DIR/etc/luarocks_config
$SPUTNIK_DIR/bin/luarocks install sputnik
cd $SPUTNIK_DIR

# Create a LuaScript for CGILua 
echo "SPUTNIK_CONFIG = {                                      " > htdocs/sputnik.lua
echo "   VERSIUM_PARAMS = { dir = '$SPUTNIK_DIR/wiki-data' }, " >> htdocs/sputnik.lua
echo "   BASE_URL       = '/sputnik.lua'                      " >> htdocs/sputnik.lua
echo "}                                                       " >> htdocs/sputnik.lua
echo "require'luarocks.require'                               " >> htdocs/sputnik.lua
echo "require'sputnik'                                        " >> htdocs/sputnik.lua
echo "sputnik.cgilua_run()                                    " >> htdocs/sputnik.lua

# Create sputnik.cgi for WSAPI CGI

echo "#! $SPUTNIK_DIR/bin/lua5.1                              " > sputnik.cgi
echo "require'luarocks.require'                               " >> sputnik.cgi
echo "require'wsapi.cgi'; require'sputnik'                    " >> sputnik.cgi
echo "SPUTNIK_CONFIG = {                                      " >> sputnik.cgi
echo "   VERSIUM_PARAMS = { dir = '$SPUTNIK_DIR/wiki-data' }, " >> sputnik.cgi
echo "   BASE_URL       = '/cgi-bin/sputnik.cgi'              " >> sputnik.cgi
echo "}                                                       " >> sputnik.cgi
echo "wsapi.cgi.run(sputnik.wsapi_run)                        " >> sputnik.cgi

# Create the wiki-data directory
mkdir $SPUTNIK_DIR/wiki-data
chmod -R a+w $SPUTNIK_DIR/wiki-data
