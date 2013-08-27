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
	local stars=oven.rebake(oven.modgame..".stars")
	local ship=oven.rebake(oven.modgame..".ship")
	local enemies=oven.rebake(oven.modgame..".enemies")
	local bullets=oven.rebake(oven.modgame..".bullets")
	local explosions=oven.rebake(oven.modgame..".explosions")
	local beep=oven.rebake(oven.modgame..".beep")
	local items=oven.rebake(oven.modgame..".items")

	local sscores=oven.rebake("wetgenes.gamecake.spew.scores")
	local srecaps=oven.rebake("wetgenes.gamecake.spew.recaps")

	local layout=cake.layouts.create{}



game.back="imgs/title"

game.loads=function()

end
		
game.setup=function()

	game.loads()

	gui.setup()
	gui.page("game")
	
	stars.setup()
	ship.setup()
	enemies.setup()
	bullets.setup()
	explosions.setup()
	items.setup()
	
	sscores.reset()

	beep.stream("game")

end

game.clean=function()

	gui.clean()
	
	stars.clean()
	ship.clean()
	enemies.clean()
	bullets.clean()
	explosions.clean()
	items.clean()
	
	sscores.final_score({})

end

game.msg=function(m)

	gui.msg(m)
	
	ship.msg(m)
	enemies.msg(m)
	
end

game.update=function()

	gui.update()
	
	stars.update()
	ship.update()
	enemies.update()
	bullets.update()
	explosions.update()
	items.update()
	
end

game.draw=function()

	stars.draw()
	ship.draw()
	enemies.draw()
	bullets.draw()
	explosions.draw()
	items.draw()
	
	sscores.draw("arcade2")

	gui.draw()
	
end

	return game
end
