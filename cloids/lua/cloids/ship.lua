-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(state,ship)
	local ship=ship or {}
	ship.state=state

	
	local game=state.rebake("cloids.main_game")
	
ship.setup=function()
--	print("ship setup")
	
	ship.px=0
	ship.py=0
	ship.vx=0
	ship.vy=0
	ship.rz=0
	ship.siz=128/256
	ship.heat=0
end

ship.clean=function()
end

ship.update=function()

	if game.but then
	
		ship.px=game.px
		ship.py=game.py
	
	end

end

ship.draw=function()

	state.cake.sheets.get("imgs/ship"):draw(1,(720/2)+ship.px,(480/2)+ship.py,ship.rz,ship.siz*128,ship.siz*128)

end
	
	
	return ship
end
