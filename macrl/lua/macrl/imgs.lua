-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require


local function print(...) _G.print(...) end

local wstr=require("wetgenes.string")
local pack=require("wetgenes.pack")

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M


M.names={
	["colson"]		={	0,	5,	0},
	["burke"]		={	0,	5,	0},
	["gantner"]		={	0,	5,	0},
	["tech1"]		={	0,	5,	0},
	["tech2"]		={	0,	5,	0},
	["tech3"]		={	0,	5,	0},

	["rubble"]		={	0,	8,	0},
	["console"]		={	0,	9,	0},
	["helipad"]		={	0,	10,	0},
	["vent"]		={	0,	11,	0},	
}

