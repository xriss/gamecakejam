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
	local canvas=state.canvas
	local font=canvas.font
	local flat=canvas.flat
	local gl=cake.gl
	local sheets=cake.sheets
	
	local gui=state:rebake("lemonhunter.gui")
	local hunter=state:rebake("lemonhunter.hunter")
	local stake=state:rebake("lemonhunter.stake")
	local level=state:rebake("lemonhunter.level")


play.loads=function(state)

	sheets.loads_and_chops{
		{"imgs/stake",1,1,0.5,0.5},
		{"imgs/hunter",1,1,0.5,0.5},
		{"imgs/gameback",1,1,0.5,0.5},
	}
	
end
		
play.setup=function(state)

	play.loads(state)

	gui.setup()
	gui.page("play")

	level.setup()
	hunter.setup()
	stake.setup()

end

play.clean=function(state)

	stake.clean()
	hunter.clean()
	level.clean()
	gui.clean()

end

play.msg=function(state,m)

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

play.update=function(state)

	gui.update()

	level.update()
	hunter.update()
	stake.update()

end

play.draw=function(state)
		

	level.draw()
	hunter.draw()
	stake.draw()

	gui.draw()

end

	return play
end
