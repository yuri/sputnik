#!/bin/sh

# find $1 $2 $3 $4 $5 $6 -name '*.lua' -print | xargs grep . > /tmp/lines.lua
#grep -v "\-\-" /tmp/lines.lua | wc -l
find $1 $2 $3 $4 $5 $6 -name '*.lua' -print | xargs grep . > /tmp/lines.lua
wc -l /tmp/lines.lua


