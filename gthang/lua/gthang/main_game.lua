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
	local ships=oven.rebake(oven.modgame..".ships")
	local enemies=oven.rebake(oven.modgame..".enemies")
	local bullets=oven.rebake(oven.modgame..".bullets")
	local explosions=oven.rebake(oven.modgame..".explosions")
	local beep=oven.rebake(oven.modgame..".beep")
	local items=oven.rebake(oven.modgame..".items")
	local hud=oven.rebake(oven.modgame..".hud")

	local srecaps=oven.rebake("wetgenes.gamecake.spew.recaps")




game.back="imgs/title"

game.loads=function()

end
		
game.setup=function()

	game.loads()

	gui.setup()
	gui.page("game")
	hud.setup()
	
	stars.setup()
	ships.setup()
	enemies.setup()
	bullets.setup()
	explosions.setup()
	items.setup()

	beep.stream("game")

end

game.clean=function()

	gui.clean()
	hud.clean()
	
	stars.clean()
	ships.clean()
	enemies.clean()
	bullets.clean()
	explosions.clean()
	items.clean()

end

game.msg=function(m)

	gui.msg(m)
	
	ships.msg(m)
	enemies.msg(m)
	
end

game.update=function()

	gui.update()
	hud.update()
	
	stars.update()
	ships.update()
	enemies.update()
	bullets.update()
	explosions.update()
	items.update()
	
end

game.draw=function()

	stars.draw()
	ships.draw()
	enemies.draw()
	bullets.draw()
	explosions.draw()
	items.draw()
	
	hud.draw()

	gui.draw()
	
end

	return game
end
