-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math

local function dprint(a) print(wstr.dump(a)) end

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,bullets)
	local bullets=bullets or {}
	bullets.oven=oven
	
	bullets.modname=M.modname

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
	local explosions=oven.rebake(oven.modgame..".explosions")
	local beep=oven.rebake(oven.modgame..".beep")

	local sscores=oven.rebake("wetgenes.gamecake.spew.scores")
	local srecaps=oven.rebake("wetgenes.gamecake.spew.recaps")
	local console=oven.rebake("wetgenes.gamecake.mods.console")

	local layout=cake.layouts.create{}

	local bullet={}


	
bullet.setup=function(it,opt)

	it.px=opt.px or 256
	it.py=opt.py or 128
	it.rz=0

	it.vx=opt.vx or 0
	it.vy=opt.vy or 0

	it.speed=1.75
	it.countdown=120

	it.flava=opt.flava or "ship"
	
	if opt.aim then
		it.rz=180*opt.aim/math.pi
	end
	
	it.owner=opt.owner or "ship"

end

bullet.clean=function(it)

end

bullet.update=function(it)

	it.py = it.py+it.vy
	it.px = it.px+it.vx
	
	if it.py>768 	then it.flava="dead" return end
	if it.py<0 		then it.flava="dead" return end
	if it.px>512 	then it.flava="dead" return end
	if it.px<0 		then it.flava="dead" return end
	
	if it.flava=="ship" then
		for i,v in ipairs(enemies.tab) do
			local dx=it.px-v.px
			local dy=it.py-v.py
			
			if dx*dx+dy*dy<=v.collide*v.collide then
				it.flava="dead"
				v.die(v)
				return
			end
		end
	elseif it.flava=="enemy" and ship.state~="dead" then
		local dx=it.px-ship.px
		local dy=it.py-ship.py
		
		if dx*dx+dy*dy<=30*30 then
			it.flava="dead"
			ship.die()
			return
		end
	end
	
end

bullet.draw=function(it)
	
	local image=sheets.get("imgs/bullets01")
	
	if it.owner=="ship" then
		gl.Color(1/2,0,1,1)
		image:draw(2,it.px,it.py,it.rz,64,64)
	elseif it.owner=="dart" then
		gl.Color(1,0,1/2,1)
		image:draw(1,it.px,it.py,it.rz,64,64)
	elseif it.owner=="vader" then
		gl.Color(math.random(),math.random(),math.random(),1)
		image:draw(3,it.px,it.py,it.rz,64,64)
	end

end


bullets.loads=function()

end
		
bullets.setup=function()

bullets.tab = {}


end

bullets.clean=function()

	for i,v in ipairs(bullets.tab) do
		bullet.clean(v)
	end

end

bullets.msg=function(m)

--	print (wstr.dump(m))
	

end

bullets.update=function()
		
	for i=#bullets.tab,1,-1 do
		local it=bullets.tab[i]
		bullet.update(it)
		if it.flava=="dead" then
			table.remove(bullets.tab,i)
		end
	end
	
end

bullets.draw=function()

	for i,v in ipairs(bullets.tab) do
		bullet.draw(v)
	end
	
	gl.Color(1,1,1,1)
	
	console.display ("bullets "..#bullets.tab)
	
end

bullets.add=function(opt)

	local it2={}
	bullet.setup(it2,opt)
	bullets.tab[#bullets.tab+1]=it2

end

bullets.remove=function(it)

	for i,v in ipairs(bullets.tab) do
		if v==it then
			table.remove(bullets.tab,i)
			return
		end
	end

end

	return bullets
end
