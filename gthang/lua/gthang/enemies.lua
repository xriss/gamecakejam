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
	local ships=oven.rebake(oven.modgame..".ships")
	local explosions=oven.rebake(oven.modgame..".explosions")
	local beep=oven.rebake(oven.modgame..".beep")
	local items=oven.rebake(oven.modgame..".items")
	local hud=oven.rebake(oven.modgame..".hud")
	local stars=oven.rebake(oven.modgame..".stars")

	local srecaps=oven.rebake("wetgenes.gamecake.spew.recaps")

	local enemy={}


	
enemy.setup=function(it,opt)

	it.die=enemy.die
	
	it.px=opt.px or 256
	it.py=opt.py or 128
	it.rz=0

	it.vx=0
	it.vy=0

	it.speed=1.75
	it.countdown=0
	it.cool=0

	it.rgb={math.random(),math.random(),math.random()}
	
	it.flava=opt.flava or "dart"
	it.aim=0
	
	it.collide=40
	
	it.score=enemies.level
	
	    if it.flava=="dart"    then it.score=it.score* 5
	elseif it.flava=="vader"   then it.score=it.score*25
	elseif it.flava=="seeker"  then it.score=it.score*30
	elseif it.flava=="blocker" then it.score=it.score* 1
	end
	
	
	if it.flava=="seeker" then
		it.collide=20
		it.speed=it.speed*2.5
	end	

end

enemy.clean=function(it)

end

enemy.update=function(it)

	if it.flava=="dead" then return end

	for i,v in ipairs(enemies.tab) do
		if v~=it and it.flava~="blocker" and v.flava~="blocker" then
			local dx=v.px-it.px
			local dy=v.py-it.py
			local dd=dx*dx+dy*dy
			
			if dd<64*64 then
				local  d=math.sqrt(dd)
				
				if d==0 then d=1 end
				
				dx=dx/d
				dy=dy/d
				
				it.vx=it.vx-(dx*0.25)
				it.vy=it.vy-(dy*0.25)
			end
		end
	end
	
	if it.flava=="dart" then
		it.vx=it.vx*0.95
		it.vy=(it.vy*15+it.speed)/16
	elseif it.flava=="vader" then
		it.vx=it.vx*0.95
		if it.py<100 then
			it.vy=(it.vy*15+it.speed)/16
		elseif it.py>150 then
			it.vy=(it.vy*15-it.speed)/16
		end
	elseif it.flava=="seeker" then
		it.vx=it.vx*0.95
		it.vy=(it.vy*15+it.speed)/16
	elseif it.flava=="bomb1" then
		it.vx=it.vx*0.5
		if it.py<100 then
			it.vy=(it.vy*15+it.speed)/8
		elseif it.py>150 then
			it.vy=(it.vy*15-it.speed)/8
		end
	elseif it.flava=="blocker" then
		if not it.master then
			for i,v in ipairs(enemies.tab) do
				if v.flava=="vader" then
					it.master=v
					break
				end
			end
		end
		if it.master then
			local dx=it.master.px-it.px
			local dy=it.master.py-it.py
			local dd=dx*dx+dy*dy
			local  d=math.sqrt(dd)
			
			if d==0 then d=1 end
			
			local vx=0.3*((dx/d))
			local vy=0.3*((dy/d))
			
			if d>32 then
				it.vx=it.vx+vx
				it.vy=it.vy+vy
			end
			if it.vx*it.vx>6*6 then
				it.vx=(it.vx*15)/16
			end
			if it.vy*it.vy>6*6 then
				it.vy=(it.vy*15)/16
			end
			if it.master.flava=="dead" then
				it.master=nil
			end
		else it:die()
		end
	end
	
	it.px=it.px+it.vx
	it.py=it.py+it.vy
	
	if it.py>768+64 then it.py=it.py-(768+64) end
	
	if it.px>512-it.collide then
		it.px = 512-it.collide
		if it.vx>0 then it.vx=-it.vx end
	end
	
	if it.px<0+it.collide then
		it.px = 0+it.collide
		if it.vx<0 then it.vx=-it.vx end
	end
	
	if it.flava=="dart" then
		it.countdown=it.countdown-1
		if it.countdown<=0 then
			it.countdown=(math.random(60,240))
			it.vx = it.vx+((math.random(0,100)/50)-1)*8
			it.vy = it.vy+((math.random(0,100)/50)-1)*8
		end
	elseif it.flava=="vader" then
		if it.vx>0 then
			it.vx=it.vx+0.1
		else
			it.vx=it.vx-0.1
		end	
--[[	elseif it.flava=="bomb1" then
		if it.vx>100 then
			it.vx=it.vx+0.1
		else
			it.vx=it.vx-0.1
		end	
]]	elseif it.flava=="seeker" then
		it.countdown=it.countdown-1
		if it.countdown<=0 then
			local ship=ships[math.random(1,2)] -- pick random ship
			local dx=ship.px-it.px
			local dy=ship.py-it.py
			local dd=dx*dx+dy*dy
			local  d=math.sqrt(dd)
			
			if d==0 then d=1 end
			
			local vx=8*((dx/d))
			local vy=8*((dy/d))
			
			it.countdown=(math.random(30,90))
			it.vx = it.vx+vx
			it.vy = it.vy+vy
		end
	end
	
	if it.flava=="dart" then
		it.cool=it.cool-1
		
		if it.cool<=0 then
			local ship=ships[math.random(1,2)] -- pick random ship
			local dx=ship.px-it.px
			local dy=ship.py-it.py
			local dd=dx*dx+dy*dy
			local  d=math.sqrt(dd)
			
			if d==0 then d=1 end
			
			local vx=8*((dx/d)+math.random()-0.5)
			local vy=8*((dy/d)+math.random()-0.5)
			
			if vx>1 then vx=1 end
			if vx<-1 then vx=-1 end
			if vy<2 then vy=2 end
			
			bullets.add{px=it.px,py=it.py+32,vy=vy,vx=vx,flava="enemy",owner="dart"}
			it.cool=math.random(100,200)
		end
	elseif it.flava=="vader" then
		it.cool=it.cool-1
		
		if it.cool<=0 then
			it.cool=10
			it.aim=it.aim+(math.pi/16)
			if it.aim>math.pi*2 then it.aim=it.aim+(math.pi*2) end
			
			local vx=-math.sin(it.aim)*8
			local vy=math.cos(it.aim)*8
			
			bullets.add{px=it.px,py=it.py,vy=vy,vx=vx,aim=it.aim,flava="enemy",owner="vader"}
		end
	end
	
end

enemy.die=function(it)

	if it.flava=="vader" then
		local t={"splitshot","singleshot","sureshot","smartbomb"}
		items.add({px=it.px,py=it.py,vx=0,vy=5,flava=(t[math.random(1,#t)])})
	end
	
	it.flava="dead"
	explosions.gibs({px=it.px, py=it.py})
--	enemies.add({px=math.random(0,512),	py=-math.random(0,512)})
	hud.score(it.score)
	
	local t={"die","die","die"}
	beep.play(t[math.random(1,#t)])

end

enemy.draw=function(it)
	
	if it.flava=="dart" then
		local image=sheets.get("imgs/ships01")
		gl.Color(it.rgb[1],it.rgb[2],it.rgb[3],1) 
		
		image:draw(2,it.px,it.py,it.rz,64,64)
	elseif it.flava=="vader" then
		local image=sheets.get("imgs/ships01")
		gl.Color(1,1,1,1) 
		
		image:draw(3,it.px,it.py,it.rz,64,64)
	elseif it.flava=="seeker" then
		local image=sheets.get("imgs/ships01")
		gl.Color(1,1,1,1) 
		
		image:draw(4,it.px,it.py,it.rz,32,32)
	elseif it.flava=="blocker" then
		local image=sheets.get("imgs/ships01")
		gl.Color(1,1,1,1) 
		
		image:draw(5,it.px,it.py,it.rz,32,32)
	elseif it.flava=="boss1" then
		local image=sheets.get("imgs/boss01")
		gl.Color(1,1,1,1) 
		
		image:draw(1,it.px,it.py,it.rz,512,512)
	end

end

enemies.loads=function()

end
		
enemies.setup=function()
	enemies.timer=0

	enemies.level=0
	
	enemies.tab = {}

end

enemies.wave=function()

	enemies.level=enemies.level+1
	stars.alpha=0.85
	
	local cx=math.random(0,512)
	
--	enemies.add({px=256, py=0, flava="boss1"})
	
	for i=1,(5+enemies.level) do
		if enemies.level%2==1 then
			enemies.add({px=math.random(cx-64,cx+64), py=math.random(-128,-64)})
		else enemies.add({px=math.random(cx-64,cx+64), py=math.random(-128,-64), flava="blocker"})
		end
	end
	
	if enemies.level%2==0 then
		enemies.add({px=math.random(cx-64,cx+64), py=math.random(-128,-64), flava="vader"})
	end
	
	if enemies.level%5==0 then
		enemies.add({px=math.random(cx-64,cx+64), py=math.random(-128,-64), flava="vader"})
	end
	
	for i=1,math.floor((enemies.level-1)/2) do
		enemies.add({px=math.random(cx-64,cx+64), py=math.random(-128,-64), flava="seeker"})
	end
	
	if enemies.level>1 then
		local t=((30*60)-enemies.timer)/(30*60)
		
		if t>0 then
			hud.score(math.floor(t*1000*enemies.level))
		end
	end
	enemies.timer=0
	
	beep.play("newwave")
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
	enemies.timer=enemies.timer+1

	local count=0
	for i=#enemies.tab,1,-1 do
		local it=enemies.tab[i]
		enemy.update(it)
		if it.flava=="dead" then
			table.remove(enemies.tab,i)
		end
		if it.flava~="blocker" then
			count=count+1
		end
	end
	
	if count==0 then
		enemies.wave()
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
