
INTRODUCTION
============

Sputnik is a wiki/cms written in Lua. It is intended to be primarily used
as a web application, but could also be accessed programmatically.
See http://spu.tnik.org/ for more information.  

Sputnik is free / open source software, distributed under the MIT License.
Some optional plugins are distributed under other free software licenses.
See attached LICENSE.txt for more information.

(c) 2007-2012 Yuri Takhteyev (most of the code)
Some of the code is (c) other authors. (See LICENSE.txt for details.)

Contact: <qaramazov@gmail.com>


INSTALLATION
============

If you are simply looking to install Sputnik using the easiest method, you
probably shouldn't be reading this. The simplest way to install Sputnik is by
using one of our installers that relies on LuaRocks. If you want to try this
option, go to http://spu.tnik.org/en/Installation and follow the instructions
given there.

Similarly, if you do want to install the latest version from our source
code repository, see http://spu.tnik.org/en/Source.

If you really want to install Sputnik by hand using the source code in this
directory, see "Manual Installation and Use" below. Meanwhile, let's look at
what we've got in this directory.


SOURCE CODE ORGANIZATION
========================

This directory contains a number of sub-directories, representing "rocks"
- collections of Lua modules that can be installed as a unit using LuaRocks.
Each rock directory has a subdirectory called "lua" which has the actual Lua
code, organized into modules. One rock may define multiple modules. So, we
have for example

    sputnik/lua/sputnik/init.lua
       |     |     |       |      
       |     |     |     submodule
       |     |   module   
       | lua code
     rock     

The minimal set of rocks that you will need to run Sputnik is:

    sputnik - the core of Sputnik
    saci - Saci, a versioned document management system behind Sputnik

There are also some rocks representing optional plugins:

    sputnik-medialike - a plugin offering support for mediawiki markup
    sputnik-tickets - a bug tracking plugin
    sputnik-mbox - a plugin enabling archival of mailing list

Some of those optional plugins may be out of date. A few other ones are
available in the "out-of-date-but-potentially-useful" directory:

    sputnik-pod - a plugin offering support for POD markup
    sputnik-search-google - a plugin for google search
    versium-svn - stores your data in subversion (needs updating)
    sputnik-examples - a basic set of demos
    sputnik-luausers - a demo showing Lua-Users wiki data loading into Sputnik
    sputnik-tests - some old tests

Those are quite certainly out of date.

MANUAL INSTALLATION AND USE
===========================

If you really want to install Sputnik by hand using the source code in this
directory, you will need the following dependencies:

1. Lua5.1
2. Binary Lua libraries: luasocket, lbase64, MD5, lpeg, luafilesystem* 
3. Pure-lua Lua libraries: cosmo, coxpcall, wsapi, diff, markdown*

Note: luafilesystem and markdown are not strictly speaking required, but are
assumed by the _default_ storage system and markup module.

You may also want to install the "optional but highly recommended" modules:

    xssfilter - a filter against cross-site scripting
    recaptcha - a Lua API for recaptcha (http://recaptcha.net)

For a basic Sputnik installation, you will need to copy the following
directories to where your Lua can find it.

    sputnik/lua/*
    saci/lua/*

You should then use the script sputnik/bin/sputnik.lua to generate a WSAPI-
compatible launcher script:

    sputnik.lua make-cgi

produces "sputnik.ws", which is a Lua script that defines a WSAPI application.

You can run Sputnik on any server for which there is a WSAPI bridge. The
easiest, however, is Xavante, a pure-lua web server. To do this, install
Xavante libraries where Lua can find them and run Sputnik as follows:

    sputnik.lua start-xavante sputnik.ws

For other options see the wiki and WSAPI documentation.

