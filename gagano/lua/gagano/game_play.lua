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
	local sounds=cake.sounds
	local sheets=cake.sheets
	local opts=state.opts
	local canvas=state.canvas
	local font=canvas.font
	local flat=canvas.flat
	local gl=cake.gl
	
	local game=state.game
	local gui=state.game.gui

	local ship=state.rebake("gagano.ship")
	local nmes=state.rebake("gagano.nmes")
	local shots=state.rebake("gagano.shots")
	
play.loads=function()

	sheets.loads_and_chops{
		{"imgs/splash",1,1,0.5,0.5},
		{"imgs/starfield",1,1,0.5,0.5},
		{"imgs/ship",1,1,0.5,0.5},
		{"imgs/sub",1,1,0.5,0.5},
		{"imgs/shark",1,1,0.5,0.5},
		{"imgs/bullet",1,1,0.5,0.5},
		{"imgs/boom",1,1,0.5,0.5},
	}
	
	sounds.loads{
		"sfx/die",
		"sfx/beep",
		"sfx/shoot",
	}

end
		
play.setup=function()

	play.score=0

	play.loads()

	gui.page("play")
	
	shots.setup()
	ship.setup()
	nmes.setup()
end

play.clean=function()

	shots.clean()
	ship.clean()
	nmes.clean()
end

play.msg=function(m)

--	print(wstr.dump(m))

	if gui.msg(m) then return end -- gui can eat msgs

	if m.x and m.y then
		ship.gx=m.x
		ship.gy=m.y
		
		if m.class=="mouse" and m.action==1 and m.keycode==1 then
			ship.do_shot=true
		end
	end
		
end

play.update=function()

	gui.update()

	shots.update()
	nmes.update()
	ship.update()

end

play.draw=function()
		
	sheets.get("imgs/starfield"):draw(1,720/2,480/2)
	
	nmes.draw()
	ship.draw()
	shots.draw()

	gui.draw()
	
	game.last_score=play.score
	
	font.set(cake.fonts.get(1))
	font.set_size(32,0)
	local s=game.last_score..""
	local sw=font.width(s)
	font.set_xy( 180-(sw/2)-60 ,480-32)
	font.draw(s)

	local s=game.best_score..""
	local sw=font.width(s)
	font.set_xy( 360+180-(sw/2)+60 ,480-32)
	font.draw(s)

end

	return play
end
