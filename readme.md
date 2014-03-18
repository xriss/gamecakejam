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
My main build is tested on ubuntu (technically xubuntu).

WINDOWS
-------
Wine and XP compatible with the focus on wine.

RASPBERRY PI
------------
With or without X11, this is a native raspbian build and can be run 
from the commandline.
The RASPI is also "minimum required specs" if your machine is not as 
powerful as one of these then don't expect everything to work.

ANDROID
-------
You have a keyboard/gamepad right? Its a bit more complicated to get 
things building into an APK file but its not impossible the my lua 
repository contains the android build and scripts to make this 
happen, you will also need the my sdk repo for all the android tools.

NACL
----
The web solution, currently chrome only.
Play online at http://play.4lfa.com/gamecake


The exact state of these platforms is currently in a state of flux due 
to on going development.

The windows build should always work under wine so it is perversely the 
most compatible cross platform build. 

Finally this is just the source code, if you want to run any of the 
games then you will need the engine as well. There are a number of 
ways of getting this but remember that different operating systems 
require different versions of the gamecake engine.


Via PPA for Ubuntu.

	sudo add-apt-repository ppa:kriss-o/gamecake
	sudo apt-get update
	sudo apt-get install gamecake

then you may CD into a any game directory and start the just by 
running "gamecake", you must be in the right directory for gamecake to 
know which game you want to run



Via mercurial for windows/ubuntu/debian/raspberrypi

	hg clone https://bitbucket.org/xixs/gamecakejam
	hg clone https://bitbucket.org/xixs/bin
	hg clone https://bitbucket.org/xixs/mods

This creates copys of repositories side-by-side so they may access 
files stored in each other. Then after that you can use CD to any 
game dir and use ../start or ../start.x64 or ../start.pi or 
../start.bat depending on what operating system you are on.

Also, since you now have a full checkout you may adjust the files 
in the art directory and run ../bake to update the games data files. 
(only works well in linux)

The bake.lua in each project is a lua script that perfroms simple 
processing of images/sounds and other game assests before copying 
them into the data directory for the game to use.

