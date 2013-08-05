-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math

local function dprint(a) print(wstr.dump(a)) end

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,enemies)
	local enemies=enemies or {}
	enemies.oven=oven
	
	enemies.modname=M.modname

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

	local sscores=oven.rebake("wetgenes.gamecake.spew.scores")
	local srecaps=oven.rebake("wetgenes.gamecake.spew.recaps")

	local layout=cake.layouts.create{}

	local enemy={}


	
enemy.setup=function(it,opt)

it.px=opt.px or 256
it.py=opt.py or 128
it.rz=0

it.vx=0
it.vy=0

it.speed=1.75

end

enemy.clean=function(it)

end

enemy.update=function(it)


	
end

enemy.draw=function(it)
	
	local image=sheets.get("imgs/bad01")
	
	image:draw(1,it.px,it.py,it.rz,64,64)

end


enemies.loads=function()

end
		
enemies.setup=function()

local sx=85
local sy=64

enemies.tab = {}
enemies.add({px=0*sx,	py=1*sy})
enemies.add({px=1*sx,	py=2*sy})
enemies.add({px=2*sx,	py=3*sy})
enemies.add({px=3*sx,	py=4*sy})
enemies.add({px=4*sx,	py=3*sy})
enemies.add({px=5*sx,	py=2*sy})
enemies.add({px=6*sx,	py=1*sy})


end

enemies.clean=function()

	for i,v in ipairs(enemies.tab) do
		enemy.clean(v)
	end

end

enemies.msg=function(m)

--	print (wstr.dump(m))
	

end

enemies.update=function()

	for i,v in ipairs(enemies.tab) do
		enemy.update(v)
	end
	
end

enemies.draw=function()

	for i,v in ipairs(enemies.tab) do
		enemy.draw(v)
	end
	
end

enemies.add=function(opt)

	local it2={}
	enemy.setup(it2,opt)
	enemies.tab[#enemies.tab+1]=it2

end

	return enemies
end
