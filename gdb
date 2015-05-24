BASEDIR=$( cd "$( dirname "$0" )" && pwd )
cd ./$1
GAMEDIR=$PWD

gdb --args $BASEDIR/../bin/dbg/gamecake.x64 $GAMEDIR/lua/init.lua $*

