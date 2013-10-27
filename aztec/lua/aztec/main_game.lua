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

	local runner=oven.rebake(oven.modgame..".runner")
	local chuckers=oven.rebake(oven.modgame..".chuckers")


	local sscores=oven.rebake("wetgenes.gamecake.spew.scores")
	local srecaps=oven.rebake("wetgenes.gamecake.spew.recaps")

	local layout=cake.layouts.create{}



game.back="imgs/title"

game.loads=function()

end
		
game.setup=function()

	game.loads()

--	gui.setup()
	gui.page("game")


	runner.setup()
	chuckers.setup()

--	beep.stream("game")

end

game.clean=function()

	runner.clean()
	chuckers.clean()

--	gui.clean()

end

game.msg=function(m)

--	print(wstr.dump(m))

--	if sgui.active then
--		sgui.msg(m)	
--	else
--		gui.msg(m)
--	end
	
end

game.update=function()

	chuckers.update()
	runner.update()

--	if sgui.active then
--		sgui.update()	
--	else
--		gui.update()
--	end
	
end

game.draw=function()
		
	sheets.get("imgs/background"):draw(1,320,240,nil,640,480)

	chuckers.draw()
	runner.draw()

--	sheets.get("imgs/ships01"):draw(1,320,240,nil,64,64)


	sscores.draw("arcade2")
	
end

	return game
end
