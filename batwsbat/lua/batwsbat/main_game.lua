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

	local balls=oven.rebake(oven.modgame..".balls")
	local bats=oven.rebake(oven.modgame..".bats")

	local gui=oven.rebake(oven.modgame..".gui")
	local main=oven.rebake(oven.modgame..".main")
--	local beep=oven.rebake(oven.modgame..".beep")

	local sscores=oven.rebake("wetgenes.gamecake.spew.scores")
	local srecaps=oven.rebake("wetgenes.gamecake.spew.recaps")

	local layout=cake.layouts.create{}



game.back="imgs/title"

game.loads=function()

end
		
game.setup=function()

	game.loads()

--	beep.stream("game")

	bats.setup()
	balls.setup()

end

game.clean=function()

	bats.clean()
	balls.clean()

end

game.msg=function(m)

--	print(wstr.dump(m))

	bats.msg(m)

end

game.update=function()

	bats.update()
	balls.update()
	
end

game.draw=function()

	gl.Color(0,0.25,0,0)


	local px=400
	local py=10

	local sx=400
	local sy=10
	
	local sx2=sx+2
	local sy2=sy+2

	local px2=400
	local py2=500-10

	flat.tristrip("xyz",{	
		px-sx,py-sy,0,
		px+sx,py-sy,0,
		px-sx,py+sy,0,
		px+sx,py+sy,0,
		px+sx,py+sy,0,

		px-sx2,py-sy2,0,
		px-sx2,py-sy2,0,
		px+sx2,py-sy2,0,
		px-sx2,py+sy2,0,
		px+sx2,py+sy2,0,
		px+sx2,py+sy2,0,

		px2-sx,py2-sy,0,
		px2-sx,py2-sy,0,
		px2+sx,py2-sy,0,
		px2-sx,py2+sy,0,
		px2+sx,py2+sy,0,
		px2+sx,py2+sy,0,

		px2-sx2,py2-sy2,0,
		px2-sx2,py2-sy2,0,
		px2+sx2,py2-sy2,0,
		px2-sx2,py2+sy2,0,
		px2+sx2,py2+sy2,0,
	})
	
	
	bats.draw()
	balls.draw()

		
	sscores.draw("arcade2")


end

	return game
end
