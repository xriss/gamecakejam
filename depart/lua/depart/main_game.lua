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
	local bikes=oven.rebake(oven.modgame..".bikes")

	local sscores=oven.rebake("wetgenes.gamecake.spew.scores")
	local srecaps=oven.rebake("wetgenes.gamecake.spew.recaps")

	local layout=cake.layouts.create{}


game.loads=function()

end
		
game.setup=function()

	game.loads()


	ground.setup()
	
	bikes.setup()
	
	for i=1,10 do
		local px=((math.random(512)/256)-1)*128*3
		local py=((math.random(512)/256)-1)*128
		bikes.insert(nil,{px=px,py=py})
	end

--	beep.stream("game")

end

game.clean=function()

--	bikes.clean()

end

game.msg=function(m)

--	print(wstr.dump(m))
	
end

game.update=function()

	ground.update()
	bikes.update()

end

game.draw=function()
	

--	sheets.get("imgs/day"):draw(1,512,256,nil,1024,512)

	ground.draw()
	
	bikes.draw()
	
end

	return game
end
