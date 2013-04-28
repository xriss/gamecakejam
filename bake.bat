set BASEDIR=%~dp0
set GAMEDIR=%CD%

%BASEDIR%/../bin/dbg/lua.exe %GAMEDIR%/bake.lua
