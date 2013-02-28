-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math


module(...)
modname=(...)

bake=function(state,play)
	local play=play or {}
	play.state=state

	play.modname=modname


	local cake=state.cake
	local canvas=cake.canvas
	local font=canvas.font


	local game=state.game


	local ship=state.rebake("aroids.ship")
	local shots=state.rebake("aroids.shots")
	local rocks=state.rebake("aroids.rocks")
	

play.setup=function()

	state.cake.sheets.loads_and_chops{
		{"imgs/back",1,1,0.5,0.5},
		{"imgs/ship",1,1,0.5,0.5},
		{"imgs/bullet3",1,1,0.5,0.5},
		{"imgs/chick3",1,1,0.5,0.5},
		{"imgs/chick2",1,1,0.5,0.5},
		{"imgs/chick1",1,1,0.5,0.5},
	}
	
	ship.setup()
	shots.setup()
	rocks.setup()
	
end


play.clean=function()

	ship.clean()
	shots.clean()
	rocks.clean()
	
end


play.update=function()


	ship.update()
	shots.update()
	rocks.update()
		
end
play.draw=function()


	cake.sheets.get("imgs/back"):draw(1,720/2,480/2)

	font.set_size(32,0) -- 32 pixels high
	font.set_xy(0,0)
	font.draw("Level: "..game.level.." Score: "..game.score)

	ship.draw()
	shots.draw()
	rocks.draw()


end



	return play
end

