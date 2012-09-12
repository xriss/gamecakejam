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

	local game=state.game


	local ship=state:rebake("aroids.ship")
	

play.setup=function(state)

	state.cake.sheets:loads_and_chops{
		{"imgs/ship",1,1,0.5,0.5},
	}
	
	ship.setup(state)
	
end


play.clean=function(state)

	ship.clean(state)
	
end


play.update=function(state)


	ship.update(state)

end
play.draw=function(state)

	local canvas=state.canvas
	local font=canvas.font

	font:set_size(32,0) -- 32 pixels high

	font:set_xy(100,100)
	font:draw("This is a play.")

	ship.draw(state)


end



	return play
end

