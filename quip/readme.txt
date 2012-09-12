QUIP is a simple single screen 4 player areana shootemup designed to be played with 4 joysticks plugged into a raspberrypi.

Its made using the gamecake framework which consists of a fat lua binary conaining many lowlevel C libraries and lua wrappers and modules some standard some custom see https://bitbucket.org/xixs/lua and https://bitbucket.org/xixs/bin for full source.

Provided is a raspbian (hard float) build called lua.raspi but the game should also run on windows/linux/android/nacl using an apropriate gamecake binary blob.

To run simply

./lua.raspi quip.lua

At the moment you will need some form of joystick to play, something that shows up in /dev/input/js0 a ps3 controller is probably the easiest option.

You can find the rest of the lua source in the lua dir and the images used as textures in data.

Simply edit any of them to create your own version...

You will need a raspberrypi running raspbian and with at least 32meg given to the GPU. Less than that and it seems to have trouble opening any GL displays. This game will run at the command prompt in full screen mode. No need to start xwindows first.

This project is made released under the MIT license so feel free to do what you want with it.
see http://leeds-hack.appspot.com/2012/ for more.


