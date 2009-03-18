
#md5
#rings
#lpeg
#luasocket
#lfs

mkdir $1
mkdir $1/lua
mkdir $1/bin
cp -r xssfilter/lua/* $1/lua/
cp -r colors/lua/* $1/lua/
cp -r recaptcha/lua/* $1/lua/
cp -r diff/lua/* $1/lua/
cp -r versium/lua/* $1/lua/
cp -r saci/lua/* $1/lua/
cp -r sputnik/lua/* $1/lua/
cp -r sputnik-markitup/lua/* $1/lua/
cp -r sputnik/bin/* $1/bin/
cp -r ~/sputnik/rocks/wsapi/1.1-2/lua/* $1/lua/
cp -r ~/sputnik/rocks/xavante/2.0.0-1/lua/* $1/lua/
cp -r ~/sputnik/rocks/markdown/0.32-1/lua/markdown.lua $1/lua/
cp -r ~/sputnik/rocks/coxpcall/1.13.0-1/lua/coxpcall.lua $1/lua/
cp -r ~/sputnik/rocks/copas/1.1.4-1/lua/copas.lua $1/lua/
cp -r ~/sputnik/rocks/cosmo/8.04.14-1/lua/* $1/lua/

cp sputnik/LICENSE* $1/
cp licenses/LICENSE_* $1/

# for actually running a pure-lua installation we'll need:
#
# ./bin/sputnik.lua make-cgi
# ./bin/sputnik.lua start-xavante
