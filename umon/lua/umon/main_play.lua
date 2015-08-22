-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math

local function dprint(a) print(wstr.dump(a)) end

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,play)
	local play=play or {}
	play.oven=oven
	
	play.modname=M.modname

	local cake=oven.cake
	local opts=oven.opts
	local canvas=cake.canvas
	local font=canvas.font
	local flat=canvas.flat
	local gl=oven.gl
	local sheets=cake.sheets
	
	local sgui=oven.rebake("wetgenes.gamecake.spew.gui")

	local gui=oven.rebake(oven.modgame..".gui")
	local main=oven.rebake(oven.modgame..".main")
--	local beep=oven.rebake(oven.modgame..".beep")

	local nodes=oven.rebake(oven.modgame..".nodes")
	local world=oven.rebake(oven.modgame..".world")

	local draw_screen=oven.rebake(oven.modgame..".draw_screen")

	local sscores=oven.rebake("wetgenes.gamecake.spew.scores")
	local srecaps=oven.rebake("wetgenes.gamecake.spew.recaps")

play.loads=function()

end
		
play.setup=function()

	play.loads()


	draw_screen.setup()

	world.setup()
	nodes.setup()

--	beep.stream("play")

end

play.clean=function()

	nodes.clean()
	world.clean()

	draw_screen.clean()

end

play.mx=0
play.my=0
play.mb=0
play.msg=function(m)

--	print(wstr.dump(m))
	
	if m.class=="mouse" then
	
		play.mx=m.x
		play.my=m.y
		
		if m.keyname=="left" then
			if m.action==1 then play.mb=1 elseif m.action==-1 then play.mb=0 end
		end
	
	end
	
end

play.update=function()

	world.update()
	nodes.update()

end

play.draw=function()

	draw_screen.draw_into(function()

--	sheets.get("imgs/play_back"):draw(1,400,300,nil,800,600)

		world.draw()
		
		nodes.draw()

--	sscores.draw("arcade2")

	end)

--	gl.Scale(800/640,600/480,1)
	draw_screen.draw()

	
end

	return play
end
