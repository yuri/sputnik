#!/bin/sh

echo "versium" && ./scripts/count_lines.sh versium
echo "saci" && ./scripts/count_lines.sh saci
echo "sputnik" && ./scripts/count_lines.sh sputnik
echo "colors" && ./scripts/count_lines.sh colors
echo "xssfilter" && ./scripts/count_lines.sh xssfilter
echo "---------------------------------"
echo "total" && ./scripts/count_lines.sh versium saci sputnik colors xssfilter
echo "---------------------------------"

echo "versium-git" && ./scripts/count_lines.sh versium-git
echo "versium-mysql" && ./scripts/count_lines.sh versium-mysql
echo "sfoto" && ./scripts/count_lines.sh sfoto


