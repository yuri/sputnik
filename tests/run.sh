#!/usr/bin/env bash

USAGE="Usage: $0 <sputnik-dir> [shake-bin]"

if [ ! -d "$1" ]; then echo ${USAGE}; exit 1; fi

SHAKE=$2

if [ ! -f "$SHAKE" ]; then SHAKE="$1/rocks/shake/1.0.1-1/bin/shake"; fi

if [ ! -f "$SHAKE" ]
then
	echo "I was unable to determine the location of your 'shake' script.  Please specify it on the commandline";
	echo $USAGE;
	exit 1;
fi

unset LUA_PATH
unset LUA_CPATH

$1/bin/lua5.1 -lluarocks.require $SHAKE -r 

