#!/usr/local/bin/gamecake

local global=require("global") -- prevent accidental global use

local opts={
	times=true, -- request simple time keeping samples
	
	width=854,	-- display basics
	height=480,
--	show="full",
	title="drift",
	start="drift.main", -- rebake this mod
	fps=60,
	... -- include commandline opts
}

require("apps").default_paths() -- default search paths so things can easily be found

math.randomseed( os.time() ) -- try and randomise a little bit better

-- setup oven with vanilla cake setup and save as a global value
global.oven=require("wetgenes.gamecake.oven").bake(opts).preheat()

-- this will busy loop or hand back control depending on the system we are running on, eitherway opts.start will run next 
return oven:serv()
