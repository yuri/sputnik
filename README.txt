
INTRODUCTION
============

Sputnik is a wiki written in Lua.  This readme is for version 7.12 Beta
See http://sputnik.freewisdom.org/ for more information.  

Sputnik is free software, distributed under the MIT License.  See 
http://sputnik.freewisdom.org/en/License for more information.

(c) Yuri Takhteyev <yuri@freewisdom.org>


INSTALLATION
============

This README.txt is written for someone who is getting Sputnik out of Subversion.  
If you are simply looking to install Sputnik, you probably shouldn't be reading
this.  Instead, you should go to http://sputnik.freewisdom.org/en/Installation
and follow the instructions presented there.

NAVIGATING THE SOURCE
=====================

Sputnik's development is organized around LuaRocks.  You don't need LuaRocks to 
use Sputnik but it helps to understand what it does.

Sputnik's code is divided into a bunch of "rocks".  Each rock contains somes 
modules or submodules and can be packaged into a "luarock".  The code contained 
in the rock can also be installed manually, by copying the content of the Lua 
directory to wherever your Lua modules normally go.  The lua code for each rock 
is stored as rocks/$rockname/lua/, so

    rocks/$rockname/lua/$module/$submodule.lua

should be installed into

    $LUA/share/lua/5.1/$module/$submodule.lua

Note that files from different rocks may end up in the same directory when you 
install them manually. For instance:

    rocks/sputnik/lua/sputnik/actions/wiki.lua 

and

    rocks/sputnik-tickes/lua/sputnik/actions/tickets.lua

should both be copied to 

    $LUA/share/lua/5.1/sputnik/actions/wiki.lua

Again, this all only applies if you want to install the code _manually_.  The 
normal way to do it, however, is to package each rock and then install them using LuaRocks.

PACKAGING ROCKS
===============

