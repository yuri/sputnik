# Install Kepler + Sputnik
wget http://luaforge.net/frs/download.php/3468/kepler-install-1.1-1 
export SPUTNIK=`pwd`
bash kepler-install-1.1-1 --prefix=$SPUTNIK --without-readline
./bin/luarocks --from=http://sputnik.freewisdom.org/rocks/earth install sputnik

# Make wiki-data directory
mkdir wiki-data
chmod -R a+rw wiki-data


# Make sputnik.ws
echo "require('sputnik')"                         > kepler/htdocs/sputnik.ws
echo "return sputnik.new_wsapi_run_fn{"           >> kepler/htdocs/sputnik.ws
echo "   VERSIUM_PARAMS = { '$SPUTNIK/wiki-data/' }," >> kepler/htdocs/sputnik.ws
echo "   BASE_URL       = '/sputnik.ws',"         >> kepler/htdocs/sputnik.ws
echo "}"                                          >> kepler/htdocs/sputnik.ws

# Make sputnik.cgi

echo "#! /bin/bash $SPUTNIK/bin/wsapi.cgi"        >  sputnik.cgi
echo "require('sputnik')"                         >> sputnik.cgi
echo "return sputnik.new_wsapi_run_fn{"           >> sputnik.cgi
echo "   VERSIUM_PARAMS = { '$SPUTNIK/wiki-data/' }," >> sputnik.cgi
echo "   BASE_URL       = '/cgi-bin/sputnik.cgi'," >> sputnik.cgi
echo "   VERSION        = 'Earth from git',"      >> sputnik.cgi
echo "}"                                          >> sputnik.cgi

