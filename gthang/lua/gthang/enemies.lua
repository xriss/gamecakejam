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
	local bullets=oven.rebake(oven.modgame..".bullets")
	local ship=oven.rebake(oven.modgame..".ship")

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
it.countdown=120
it.cool=math.random(100,200)

it.rgb={math.random(),math.random(),math.random()}

end

enemy.clean=function(it)

end

enemy.update=function(it)

	it.vx = it.vx*0.95
	it.py = it.py+it.speed
	
	if it.py>1000 then it.py=it.py-1256 end
	if it.px>(512+128) then it.px=it.px-(512+256) end
	if it.px<(0-128) then it.px=it.px+(512+256) end
	
	it.countdown=it.countdown-1
	if it.countdown<=0 then
		it.countdown=(math.random(60,240))
		it.vx = ((math.random(0,100)/50)-1)*8
	end
	
	it.px=it.px+it.vx
	
	it.cool=it.cool-1
	
	if it.cool<=0 then
		local dx=ship.px-it.px
		local dy=ship.py-it.py
		local dd=dx*dx+dy*dy
		local  d=math.sqrt(dd)
		
		if d==0 then d=1 end
		
		bullets.add{px=it.px,py=it.py+32,vy=8*((dy/d)+math.random()-0.5),vx=8*((dx/d)+math.random()-0.5),flava="enemy"}
		it.cool=math.random(100,200)
	end	
	
end

enemy.draw=function(it)
	
	local image=sheets.get("imgs/bad01")
	gl.Color(it.rgb[1],it.rgb[2],it.rgb[3],1) 
	
	image:draw(1,it.px,it.py,it.rz,64,64)

end


enemies.loads=function()

end
		
enemies.setup=function()

local sx=85
local sy=64
local sya=-128

enemies.tab = {}
enemies.add({px=0*sx,	py=sya+1*sy})
enemies.add({px=1*sx,	py=sya+2*sy})
enemies.add({px=2*sx,	py=sya+3*sy})
enemies.add({px=3*sx,	py=sya+4*sy})
enemies.add({px=4*sx,	py=sya+3*sy})
enemies.add({px=5*sx,	py=sya+2*sy})
enemies.add({px=6*sx,	py=sya+1*sy})

-- for i=1,100 do
-- 	enemies.add({px=math.random(0,512),	py=math.random(0,512)})
-- end


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
	
	gl.Color(1,1,1,1)
	
end

enemies.add=function(opt)

	local it2={}
	enemy.setup(it2,opt)
	enemies.tab[#enemies.tab+1]=it2

end

enemies.remove=function(it)

	for i,v in ipairs(enemies.tab) do
		if v==it then
			table.remove(enemies.tab,i)
			return
		end
	end

end

	return enemies
end
