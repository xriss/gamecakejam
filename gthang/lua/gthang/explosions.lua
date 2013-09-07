-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math

local function dprint(a) print(wstr.dump(a)) end

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,explosions)
	local explosions=explosions or {}
	explosions.oven=oven
	
	explosions.modname=M.modname

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
	local enemies=oven.rebake(oven.modgame..".enemies")
	local ship=oven.rebake(oven.modgame..".ship")

	local srecaps=oven.rebake("wetgenes.gamecake.spew.recaps")

	local layout=cake.layouts.create{}

	local explosion={}


	
explosion.setup=function(it,opt)

	it.flava=opt.flava or "boom"

	if it.flava=="boom"	then
		it.px=opt.px or 256
		it.py=opt.py or 128
		it.rz=opt.rz or 0
		it.rv=math.random(-25,25)
		it.sz=math.random(100,120)
		
		it.t=0
		
		it.sx=opt.sx or 256
		it.sy=opt.sy or 256
		
		it.a=0
	elseif	it.flava=="gib" then
		it.px=opt.px or 256
		it.py=opt.py or 128
		it.rz=opt.rz or 0
		
		it.t=0
		
		it.vx=opt.vx or 0
		it.vy=opt.vy or 0
		it.rv=opt.rv or 0
		it.id=opt.id or 1
		
		it.sx=opt.sx or 32
		it.sy=opt.sy or 32
		it.life=opt.life or 60
	end

end

explosion.clean=function(it)

end

explosion.update=function(it)

	if it.flava=="boom"	then
		
		it.t=it.t+1		
		it.rz=it.rz+it.rv
		it.sx=it.sx*it.sz/128
		it.sy=it.sy*it.sz/128
		it.a =(1-(it.t/30))*0.75
				
		if it.t>30 then it.flava="dead" end
	elseif	it.flava=="gib" then
		
		it.t=it.t+1	
		it.px=it.px+it.vx
		it.py=it.py+it.vy
		it.rz=it.rz+it.rv
		
		it.a =(1-(it.t/it.life))
		if it.t>it.life then it.flava="dead" end
	end
	
	
end

explosion.draw=function(it)
	
	if it.flava=="boom"	then
		local image=sheets.get("imgs/explosion01")
		gl.Color(it.a,it.a,it.a,0)
		image:draw(1,it.px,it.py,it.rz,it.sx,it.sy)
	elseif	it.flava=="gib" then
		local image=sheets.get("imgs/gibs01")
		gl.Color(it.a,it.a,it.a,0)
		image:draw(it.id,it.px,it.py,it.rz,it.sx,it.sy)
	end

end


explosions.loads=function()

end
		
explosions.setup=function()

explosions.tab = {}

end

explosions.clean=function()

	for i,v in ipairs(explosions.tab) do
		explosion.clean(v)
	end

end

explosions.msg=function(m)
	

end

explosions.update=function()

	for i=#explosions.tab,1,-1 do
		local it=explosions.tab[i]
		explosion.update(it)
		if it.flava=="dead" then
			table.remove(explosions.tab,i)
		end
	end
	
end

explosions.draw=function()

	for i,v in ipairs(explosions.tab) do
		explosion.draw(v)
	end
	
	gl.Color(1,1,1,1)
	
end

explosions.add=function(opt)

	local it2={}
	explosion.setup(it2,opt)
	explosions.tab[#explosions.tab+1]=it2

end

explosions.gibs=function(opt)

	explosions.add(opt)
	
	for i=1,8 do
		opt.flava="gib"
		opt.vx=math.random(-16,16)/8
		opt.vy=math.random(-16,16)/8
		opt.rv=math.random(-16,16)
		
		if opt.gibs=="ship" then
			opt.id=math.random(9,16)
			opt.sx=math.random(32,64)
			opt.sy=math.random(32,64)
			opt.vx=opt.vx/2
			opt.vy=opt.vy/2
			opt.rv=opt.rv/2
			opt.life=120
		else
			opt.id=math.random(1,8)
			opt.sx=math.random(16,32)
			opt.sy=math.random(16,32)
		end
		explosions.add(opt)
	end

end

explosions.remove=function(it)

	for i,v in ipairs(explosions.tab) do
		if v==it then
			table.remove(explosions.tab,i)
			return
		end
	end

end

	return explosions
end
