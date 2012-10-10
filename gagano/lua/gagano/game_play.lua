-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math

local function dprint(a) print(wstr.dump(a)) end

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(state,play)
	local play=play or {}
	play.state=state
	
	play.modname=M.modname

	local cake=state.cake
	local sheets=cake.sheets
	local opts=state.opts
	local canvas=state.canvas
	local font=canvas.font
	local flat=canvas.flat
	local gl=cake.gl
	
	local gui=state.game.gui

	local ship=state:rebake("gagano.ship")
	
play.loads=function(state)

	sheets.loads_and_chops{
		{"imgs/splash",1,1,0.5,0.5},
		{"imgs/ship",1,1,0.5,0.5},
		{"imgs/sub",1,1,0.5,0.5},
		{"imgs/shark",1,1,0.5,0.5},
	}
	
end
		
play.setup=function(state)

	play.loads(state)

	gui.page("play")
	
	ship.setup()
end

play.clean=function(state)

	ship.clean()
end

play.msg=function(state,m)

--	print(wstr.dump(m))

	if gui.msg(m) then return end -- gui can eat msgs

	if m.x and m.y then
		ship.gx=m.x
		ship.gy=m.y
	end
		
end

play.update=function(state)

	gui.update()

	ship.update()

end

play.draw=function(state)
		
--	sheets.get("imgs/splash"):draw(1,720/2,480/2)
	
	ship.draw()

	gui.draw()

end

	return play
end
