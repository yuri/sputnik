#!/bin/bash
INSTALLATION=$1
ROCK=$2

if [ -d $INSTALLATION/rocks/$ROCK ]
then
echo "The Rock directory already exists, good"
else
mkdir $INSTALLATION/rocks/$ROCK
fi

ln -s `pwd`/$ROCK $INSTALLATION/rocks/$ROCK/cvs-1
$INSTALLATION/bin/luarocks-admin make-manifest
