Some quick and dirty gamecake games, built quickly as test packages. 
You could try and play them or you could take them and use them as a 
base for your own creations. Play with them, change the grafix, have 
fun, release them, that's why they exist.

This is my attempt to recreate the experience of typing in games from 
magazines in the 80s. It was much more fun to fiddle with the code than 
to play the games.

The code lives in the lua directory of each game, change it and run it.


The GameCake engine allows these games to work on:

LINUX
My main build is tested on ubuntu (technically xubuntu).

WINDOWS
Wine and XP compatible with the focus on wine.

RASPBERRY PI
With or without X11, this is a native raspbian build and can be run 
from the commandline.
The RASPI is also "minimum required specs" if your machine is not as 
powerful as one of these then don't expect everything to work.

ANDROID You have a keyboard/gamepad right? Its a bit more 
complicated to get things building into an APK file but its not 
impossible the my lua repository contains the android build and 
scripts to make this happen, you will also need the my sdk repo for 
all the android tools.

NACL
The web solution, currently chrome only.
Play online at http://play.4lfa.com/gamecake

The exact state of these platforms is currently in a state of flux due 
to on going development.

The windows build should always work under wine so it is perversely the 
most compatible cross platform build. 

Finally this is just the source code, if you want to check out something
that runs easily then use the following hg commands

hg clone https://bitbucket.org/xixs/public.gamecakejam



