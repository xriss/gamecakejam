-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math

local function dprint(a) print(wstr.dump(a)) end

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,game)
	local game=game or {}
	game.oven=oven
	
	game.modname=M.modname

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

	local ground=oven.rebake(oven.modgame..".ground")
	local walls=oven.rebake(oven.modgame..".walls")
	local bird=oven.rebake(oven.modgame..".bird")

	local sscores=oven.rebake("wetgenes.gamecake.spew.scores")
	local srecaps=oven.rebake("wetgenes.gamecake.spew.recaps")

	local main=oven.rebake(oven.modgame..".main")



game.back="imgs/title"

game.loads=function()

end
		
game.setup=function()

	game.loads()

	ground.setup()
	walls.setup()
	bird.setup()

--	beep.stream("game")

end

game.clean=function()

	ground.clean()
	walls.clean()
	bird.clean()

end

game.msg=function(m)

--	print(wstr.dump(m))
	
	if m.action==1 then bird.flap() end

	
end

game.update=function()

	ground.update()
	walls.update()
	bird.update()
	
end

game.draw=function()
	
	gl.ClearColor(pack.argb4_pmf4(0xf004))
	gl.Clear(gl.COLOR_BUFFER_BIT+gl.DEPTH_BUFFER_BIT)
--		sheets.get("imgs/title"):draw(1,320,240,nil,640,480)
		
	sheets.get("imgs/back"):draw(1,512/2,512/2,nil,1024,1024)
	sheets.get("imgs/day"):draw(1,512/2,512/2,nil,1024,512)

	main.clip_on()

	walls.draw()
	bird.draw()

	main.clip_off()

	ground.draw()

	sscores.draw("arcade2")

--		gui.draw()	
	
end

	return game
end
