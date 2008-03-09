#!/usr/bin/env sh

#BUG luarocks(-admin) as no command to give $ROCKS_DIR

PROG_NAME=${0##*/}

while getopts ":i:r:a:g:h?" Option
do
   case "$Option" in
      "h" | "?" )
         cat <<DOCUMENTATION
Synopsis :
   Make symbolic link of rocks (local directory assumed) 
   to luarocks repository directory. 
   Then run luarocks-admin make-manifest.
   Make them available to lua installation.

Usage :
$PROG_NAME -h -?           # This help
$PROG_NAME                 # Link all rocks from current directory
$PROG_NAME rocksA rocksB   # Link desiried rocks

Options :
-i installation    : Use specified local installation. Can assume :
                     installation/bin to find lua and luarocks-admin
-r rocks_dir       : Rocks directory to had rocks links
                     default to installation rocks directory
-a luarocks-admin  : luarocks-admin to use for updating manifest
-g git_dir         : Repository from wich make link.
                     Default to current directory

Example :
# link all rocks from curent directory
$PROG_NAME -i ../..        #Use local install who is two level upper
# is equivalent at :
$PROG_NAME -r ../../rocks/ -a ../../bin/luarocks-admin -g .
# if desired lua binaries is in your path
# or you have setup LUAROCKS_CONFIG
# just run :
$PROG_NAME

DOCUMENTATION
         exit 0 
         ;;
      "i" ) #give installation directory
         LUA_INSTALLATION=${OPTARG%/};
         echo "Use specified $LUA_INSTALLATION as installation directory"
         ;;
      "r" ) #give Rocks dir
         ROCKS_DIR=${OPTARG%/}
         ;;
      "a" ) #give luarocks-admin
         LUAROCKS_ADMIN=${OPTARG%/}
         ;;
      "g" ) #give git directory
         GIT_DIR=${OPTARG%/}
         ;;
   esac
done

shift $(($OPTIND - 1))

# directory form which link Rocks
if [ -z $GIT_DIR ]; then
   GIT_DIR=`pwd`
fi
if [ -d $GIT_DIR ]; then
   echo "Will link Rocks from $GIT_DIR"
   cd $GIT_DIR
else
   echo "$GIT_DIR isn't a directory"
   exit 1
fi

# set Rocks target directory
if [ -z $ROCKS_DIR ]; then
   #use installation if specified
   if [ ! -z $LUA_INSTALLATION]; then 
      if [ -x $LUA_INSTALLATION/lua ]; then
         LUA_BIN=$LUA_INSTALLATION/lua
      elif [ -x $LUA_INSTALLATION/lua5.1 ]; then
         LUA_BIN=$LUA_INSTALLATION/lua5.1
      fi
   fi
   if [ -z $LUA_BIN ]; then
      echo "Use site wide lua install"
      LUA_BIN=`which lua || which lua5.1`
   fi
   #use luarocks configuration
   #environment variable $LUAROCKS_CONFIG will change it
   ROCKS_DIR=`$LUA_BIN -e "require'luarocks.config';print(luarocks.config.repo_dir)"`
fi
if [ -d $ROCKS_DIR ]; then
   echo "Use $ROCKS_DIR as Rocks directory"
else
   echo "ERROR : no Rocks directory $ROCKS_DIR"
   exit 1
fi

#set luarocks-admin
if [ -z $LUAROCKS_ADMIN ]; then
   #using luarocks-admin in LUA_INSTALLATION if specified
   if [ -z $LUA_INSTALLATION ]; then
      echo "Use site wide luarocks-admin"
      LUAROCKS_ADMIN=`which luarocks-admin`
   else
      LUAROCKS_ADMIN=$LUA_INSTALLATION/bin/luarocks-admin
      echo "Use $LUAROCKS_ADMIN"
   fi
fi
if [ ! -x $LUAROCKS_ADMIN ]; then
   echo "Can't launch $LUAROCKS_ADMIN"
   exit 1
fi


# take remaning args as Rocks to link
ROCKS=$*
# or process all in none specified
if [ $# -eq 0 ]; then
   echo -e "Will process all Rocks\n"
   ROCKS="*"
fi

for ROCK in $ROCKS; do
   #process only repertory who have a rockspec file
   if [[ -e $ROCK/rockspec ]]; then
      #trim trailing / (cosmetic)
      ROCK=${ROCK%/}
      echo "Process $ROCK"
      if [ -d $ROCKS_DIR/$ROCK ]; then
         echo "The Rock $ROCK directory already exists, good"
      else
         echo "Add the Rock $ROCK directory"
         mkdir $ROCKS_DIR/$ROCK
      fi
      if [ -L $ROCKS_DIR/$ROCK/cvs-1 ]; then
         echo "Remove existing link $ROCKS_DIR/$ROCK/cvs-1"
         rm $ROCKS_DIR/$ROCK/cvs-1
      fi
      if [ -e $ROCKS_DIR/$ROCK/cvs-1 ]; then
         echo "WARNING : $ROCKS_DIR/$ROCK/cvs-1 File exists"
         ecoo "          will not make link form :$ROCK"
      else
         echo -e "Make symbolic link from : $ROCK\nto : $ROCKS_DIR/$ROCK/cvs-1"
         ln -s `pwd`/$ROCK $ROCKS_DIR/$ROCK/cvs-1
      fi
   fi
done

#update manifest
$LUAROCKS_ADMIN make-manifest $ROCKS_DIR

exit 0
