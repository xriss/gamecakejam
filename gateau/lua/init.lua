#!/usr/local/bin/gamecake

local luapath,apppath=require("apps").default_paths(debug.getinfo(1,"S").source:match("^@(.*[/\\])")) -- default search paths so things can easily be found
if luapath then print("Using lua found at : "..luapath.."lua/") end
if apppath then print("Using app found at : "..apppath) end

local global=require("global") -- prevent accidental global use

local opts={
	times=true, -- request simple time keeping samples
	name="gateau",
	width=640,	-- display basics
	height=480,
--	show="full",
	title="gateau",
	start="gateau.main", -- rebake this mod
	fps=60,
	... -- include commandline opts
}

math.randomseed( os.time() ) -- try and randomise a little bit better

-- setup oven with vanilla cake setup and save as a global value
global.oven=require("wetgenes.gamecake.oven").bake(opts).preheat()

-- this will busy loop or hand back control depending on the system we are running on, eitherway opts.start will run next 
return oven:serv()
