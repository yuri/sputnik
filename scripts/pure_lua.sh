
#md5
#rings
#lpeg
#luasocket
#lfs

cp -r xssfilter/lua/* pure_lua/
cp -r colors/lua/* pure_lua/
cp -r recaptcha/lua/* pure_lua/
cp -r diff/lua/* pure_lua/
cp -r versium/lua/* pure_lua/
cp -r saci/lua/* pure_lua/
cp -r sputnik/lua/* pure_lua/
cp -r ~/sputnik/rocks/wsapi/cvs-3/lua/* pure_lua/
cp -r ~/sputnik/rocks/xavante/2.0.0-1/lua/* pure_lua/
cp -r ~/sputnik/rocks/markdown/0.32-1/lua/markdown.lua pure_lua/
cp -r ~/sputnik/rocks/coxpcall/1.13.0-1/lua/coxpcall.lua pure_lua/
cp -r ~/sputnik/rocks/copas/1.1.3-1/lua/copas.lua pure_lua/
cp -r ~/sputnik/rocks/cosmo/8.04.14-1/lua/* pure_lua/

# for actually running a pure-lua installation we'll need:
#
# ./bin/lua -e 'require("sputnik.xavante").start("./web/")'
