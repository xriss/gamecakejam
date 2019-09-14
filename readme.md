
The easiest way to run these examples is via snap, the following should 
install the engine and run these examples using the gateau menu.

	snap install gamecake
	gamecakejam


Some quick and dirty (:QAD:) gamecake games, built quickly as test 
packages. You could try and play them or you could take them and use 
them as a base for your own creations. Play with them, change the 
grafix, have fun, release them, that's why they exist.

This is my attempt to recreate the experience of typing in games from 
magazines in the 80s. It was much more fun to fiddle with the code than 
to play the games.

The code lives in the lua directory of each game, change it and run it 
using gamecake. the following will bake any art assets into the data 
directory ( from the art directory ) and then run the code.

	cd lonelybird		# enter the project folder
	gamecake bake.lua	# build the art assets
	gamecake			# run the game

You will need to bake at least once before anything will run.


Alternatively you can use the gateau menu to launch each of these 
projects.

	./make
	./run

