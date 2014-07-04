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
	local beep=oven.rebake(oven.modgame..".beep")

	local ground=oven.rebake(oven.modgame..".ground")
	local bikes=oven.rebake(oven.modgame..".bikes")
	local players=oven.rebake(oven.modgame..".players")
	local hud=oven.rebake(oven.modgame..".hud")

	local sscores=oven.rebake("wetgenes.gamecake.spew.scores")
	local srecaps=oven.rebake("wetgenes.gamecake.spew.recaps")

	local layout=cake.layouts.create{}


game.loads=function()

end
		
game.setup=function()

	game.loads()

	hud.setup()
	ground.setup()
	
	bikes.setup()
	players.reset() -- maybe remember old avatar? but forget everything else it is a new game
	game.testbike=nil
	for i=1,12 do
		local px=((math.random(512)/256)-1)*128
		local py=((math.random(512)/256)-1)*128
		local bike=bikes.insert(nil,{px=px,py=py,avatar=(i%12)+5,wheel=(i%4)+1})
		bike.set_bounce(math.random(4),math.random(4),math.random(4))
		game.testbike=game.testbike or bike
	end

--	beep.stream("game")

end

game.clean=function()

--	bikes.clean()

end

game.msg=function(m)

	
	if m.class=="mouse" and m.action==-1 then
	
--		print(wstr.dump(m))
		
		local x=m.x-512
		local y=m.y-256
		
		local bike=game.testbike
		
--		bike.vx=bike.vx+(x/32)
--		bike.vy=bike.vy+(y/32)
--		bike.set_bounce(math.random(4),math.random(4),math.random(4))

	end
	
end

game.update=function()

	hud.update()
	ground.update()
	bikes.update()

end

game.draw=function()
	

--	sheets.get("imgs/day"):draw(1,512,256,nil,1024,512)

	ground.draw()
	
	bikes.draw()

	hud.draw()
	
end

	return game
end
