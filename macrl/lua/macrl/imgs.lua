-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require


local function print(...) _G.print(...) end

local wstr=require("wetgenes.string")
local pack=require("wetgenes.pack")

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M


M.names={
	["colson"]		={	1,	2,	2},
	["burke"]		={	1,	2,	1},
	["gantner"]		={	1,	3,	2},
	["tech1"]		={	1,	3,	0},
	["tech2"]		={	1,	4,	3},
	["tech3"]		={	1,	6,	3},

	["tech4"]		={	1,	6,	3},
	["tech5"]		={	1,	6,	3},
	["tech6"]		={	1,	6,	3},

	["rubble1"]		={	1,	11,	3},
	["rubble2"]		={	1,	12,	3},
	["rubble3"]		={	1,	13,	3},
	["rubble4"]		={	1,	14,	3},
	["rubble5"]		={	1,	15,	3},
	["console"]		={	1,	8,	0},
	["helipad"]		={	1,	9,	0},
	["vent"]		={	1,	10,	0},	

	["dark"]		={	0,	0,	0},	
	["wall"]		={	0,	1,	0},	
	["floor"]		={	0,	2,	0},	
	
	["macgyver"]	={	1,	3,	1},
	["item"]		={	1,	4,	0},	
	["bigitem"]		={	1,	6,	0},	
	
	["binoculars"]	={	1,	8,	1},
	["plank"]		={	1,	9,	1},	
	["chair"]		={	1,	10,	1},
	["watch"]		={	1,	9,	2},	
	["log"]			={	1,	8,	2},
	["brick1"]		={	1,	10,	2},	
	["brick2"]		={	1,	11,	2},	
	["brick3"]		={	1,	12,	2},	
	["brick4"]		={	1,	13,	2},	
	["cabinet"]		={	1,	8,	3},
	["kettle"]		={	1,	9,	3},
	["lazer"]		={	1,	10,	3},

	["crate"]		={	1,	8,	3},
	["debri1"]		={	1,	11,	3},
	["debri2"]		={	1,	12,	3},
	["debri3"]		={	1,	13,	3},
	["debri4"]		={	1,	11,	4},
	["debri5"]		={	1,	12,	4},

}

