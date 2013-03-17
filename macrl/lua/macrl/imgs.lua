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

	["rubble"]		={	0,	6,	0},
	["console"]		={	0,	8,	0},
	["helipad"]		={	0,	9,	0},
	["vent"]		={	0,	10,	0},	

	["dark"]		={	0,	0,	0},	
	["wall"]		={	0,	1,	0},	
	["floor"]		={	0,	2,	0},	
	
	["macgyver"]	={	1,	3,	1},
	["item"]		={	1,	4,	0},	
	["bigitem"]		={	1,	6,	0},	

}

