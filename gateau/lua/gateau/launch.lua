-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require


local function print(...) _G.print(...) end

local wwin=require("wetgenes.win") -- system independent helpers
local wstr=require("wetgenes.string")
local pack=require("wetgenes.pack")
local bake=require("wetgenes.bake")

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M


M.bake=function(oven,launch)

	launch=launch or {} 
	launch.modname=M.modname


	launch.run=function(id)
		bake.writefile(wwin.files_prefix.."launch",[[
./gamecake gamecake.cake ]]..id..[[.cake fullscreen
		]])
	end
	
	
	return launch
end
