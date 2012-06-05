Sputnik - An Extensible Wiki in Lua
===================================

Version "Galaxy" 12.06.04

INSTALLATION
------------

To install Sputnik with Lua and Luarocks use the included install.sh
script. This script will install Lua, LuaRocks, Sputnik, and all
dependencies.

To install Sputnik locally rather than system wide, use --prefix flag.

For example:

    mkdir /tmp/sputnik/
    ./install.sh --prefix=/tmp/sputnik/

This will install Lua, LuaRocks, Sputnik, etc. in /tmp/sputnik/

If your system does not have header files for readline, use
--without-readline flag. For example:

    ./install.sh --without-readline --prefix=/tmp/sputnik/

If you do not want to use LuaRocks to install Sputnik, you can find
Sputnik's source tree in sputnik-12.06.04.tar.gz. You will also need
to somehow install Lua 5.1, cosmo, luasocket, wsapi, coxpcall,
luafilesystem, markdown, md5. You may also want to install the
following optional modules: wsapi-xavante, xssfilter, recaptcha,
luaposix.

GETTING STARTED
---------------

Upon installation you should have a script called "sputnik" installed
in your bin directory. (This would be your local bin directory if you
do a local install, e.g. /tmp/sputnik/bin/sputnik.)

You can use this script to generate CGI and WSAPI scripts for running
Sputnik. You can do so with:

    sputnik make-cgi

This will produce two files: sputnik.ws and sputnik.cgi. The first is
for use with Xavante (a web server that is included with Sputnik) and
the second one is for use with any CGI server.

To start Sputnik with Xavante, use:

    sputnik start-xavante

This will start Xavante on port 8080.

Please see "sputnik help" for more options.

To use Sputnik via CGI, use sputnik.cgi as your CGI script. You may
need to correct your the first line to point to the right version of
Lua. You will also need to set the correct permissions.

For further configuration information see built in help available
through "sputnik topics" command, as well as Sputnik's website at
http://sputnik.freewisdom.org/

