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
	local opts=state.opts
	local canvas=cake.canvas
	local font=canvas.font
	local flat=canvas.flat
	local gl=state.gl
	local sheets=cake.sheets
	local sounds=cake.sounds
	
	local main=state.rebake("lemonhunter.main")
	local gui=state.rebake("lemonhunter.gui")
	local hunter=state.rebake("lemonhunter.hunter")
	local stake=state.rebake("lemonhunter.stake")
	local level=state.rebake("lemonhunter.level")
	local lemons=state.rebake("lemonhunter.lemons")


play.loads=function()

	sheets.loads_and_chops{
		{"imgs/stake",1,1,0.5,0.5},
		{"imgs/hero",1,1,0.5,0.5},
		{"imgs/lemon",1,1,0.5,0.5},
		{"imgs/lemondie",1,1,0.5,0.5},
		{"imgs/gameback",1,1,0.5,0.5},
	}
	
	sounds.loads{
		"sfx/die",
		"sfx/beep",
		"sfx/shoot",
	}

end
		
play.setup=function()

	play.loads()

	gui.setup()
	gui.page("play")

	level.setup()
	hunter.setup()
	stake.setup()
	lemons.setup()
	
	play.score=0

end

play.clean=function()

	lemons.clean()
	stake.clean()
	hunter.clean()
	level.clean()
	gui.clean()

end

play.msg=function(m)

--	print(wstr.dump(m))

	if gui.msg(m) then return end -- gui can eat msgs

	if m.x and m.y then
		hunter.mx=m.x
		hunter.my=m.y
		
		if m.class=="mouse" and m.action==1 and m.keycode==1 then
			hunter.do_click=true
		end
	end
	
end

play.update=function()

	gui.update()

	level.update()
	hunter.update()
	stake.update()
	lemons.update()
	
	main.last_score=play.score

end

play.add_score=function(num)

	play.score=play.score+num

end

play.draw=function()
		

	level.draw()
	hunter.draw()
	lemons.draw()
	stake.draw()

	gui.draw()

	



end

	return play
end
