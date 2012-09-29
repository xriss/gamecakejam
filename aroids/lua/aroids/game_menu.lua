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
	
	local canvas=state.canvas
	local font=canvas.font
	local cake=state.cake
	local gl=cake.gl
	local game=state.game


play.setup=function(state)

	state.cake.sheets.loads_and_chops{
		{"imgs/title",1,1,0.5,0.5},
	}
	
	play.age=0
	
end


play.clean=function(state)
end


play.update=function(state)

	play.age=play.age+1
	
	if play.age>100 then
		if game.input.fire then -- click to start
			game.level=1
			game.score=0
			game.next=state:rebake("aroids.game_play")
		end
	end
end


play.draw=function(state)


	state.cake.sheets.get("imgs/title"):draw(1,720/2,480/2)


	gl.Color(pack.argb4_pmf4(0xf000))

	font.set_size(32,0) -- 32 pixels high

	font.set_xy(0,0)
	font.draw("Level: "..game.level.." Score: "..game.score)
	
		
	
end



	return play
end

