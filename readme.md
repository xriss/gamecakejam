Some quick and dirty (:QAD:) gamecake games, built quickly as test 
packages. You could try and play them or you could take them and use 
them as a base for your own creations. Play with them, change the 
grafix, have fun, release them, that's why they exist.

This is my attempt to recreate the experience of typing in games from 
magazines in the 80s. It was much more fun to fiddle with the code than 
to play the games.

The code lives in the lua directory of each game, change it and run it.


The gamecake engine allows these games to work on:

LINUX
-----

This is built against LSB, so the binaries should work on most distros.


WINDOWS
-------

Wine and XP compatible with the focus on wine so this can also be run
on most linux platforms.


OSX
---

This should now work fine on recent Macs.


RASPBERRY PI
------------

With or without X11, this is a native raspbian build and can be run 
from the command line. The RASPI is also "minimum required specs" if 
your machine is not as powerful as one of these then don't expect 
everything to work.


ANDROID
-------

You have a keyboard/gamepad right? Its a bit more complicated to get 
things building into an APK file but its not impossible the my lua 
repository contains the android build and scripts to make this 
happen, you will also need the my sdk repo for all the android tools.


NACL or EMSCRIPTEN
------------------

The web solution, currently chrome only.
Play online at http://play.4lfa.com/gamecake



Finally this is just the source code, if you want to run any of the 
games then you will need the engine as well. There are a number of 
ways of getting this but remember that different operating systems 
require different versions of the gamecake engine.

Via mercurial for windows/ubuntu/debian/raspi

	hg clone https://bitbucket.org/xixs/gamecakejam
	hg clone https://bitbucket.org/xixs/bin
	hg clone https://bitbucket.org/xixs/mods

This creates copies of repositories side-by-side so they may access 
files stored in each other. Then after that you can use CD to any 
game dir and use ../start or ../start.x64 or ../start.pi or 
../start.bat depending on what operating system you are on.

Also, since you now have a full checkout you may adjust the files 
in the art directory and run ../bake to update the games data files. 
(only works well in linux)

The bake.lua in each project is a lua script that performs simple 
processing of images/sounds and other game assets before copying 
them into the data directory for the game to use.

