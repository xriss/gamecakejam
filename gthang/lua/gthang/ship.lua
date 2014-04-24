-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math

local function dprint(a) print(wstr.dump(a)) end

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,ship)
	local ship=ship or {}
	ship.oven=oven
	
	ship.modname=M.modname

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
	local enemies=oven.rebake(oven.modgame..".enemies")
	local explosions=oven.rebake(oven.modgame..".explosions")
	local beep=oven.rebake(oven.modgame..".beep")

	local srecaps=oven.rebake("wetgenes.gamecake.spew.recaps")

	local layout=cake.layouts.create{}



ship.loads=function()

end
		
ship.setup=function()

	ship.px=256
	ship.py=(768-32)-96
	ship.rz=0

	ship.vx=0
	ship.vy=0

	ship.left=false
	ship.right=false
	ship.fire=false
	ship.cool=0

	ship.speed=1.75
	ship.state="alive"
	
	ship.power=nil
	
	ship.mouse  =false
	ship.mouse_x=0
	ship.mouse_y=0
	
end

ship.clean=function()

end

ship.msg=function(m)

--	print (wstr.dump(m))
	
	if m.class == "mouse" then
		ship.mouse 	= true
		ship.px     = m.x
		ship.mouse_y= m.y
			
		if m.action == 1 then
			ship.fire = true			
		elseif m.action == -1 then
			ship.fire  = false
			ship.left  = false
			ship.right = false			
		end
			
	end
	
	if m.class == "key" then
		
		ship.mouse = false
		
		if m.keyname == "left" then
			
			if m.action == 1 then
				ship.left = true
			elseif m.action == -1 then
				ship.left = false
			end
			
		end
		
		if m.keyname == "right" then
			
			if m.action == 1 then
				ship.right = true
			elseif m.action == -1 then
				ship.right = false
			end
			
		end
		
		if m.keyname == "space" then
			
			if m.action == 1 then
				ship.fire = true
			elseif m.action == -1 then
				ship.fire = false
			end
			
		end
		
	end

end

ship.update=function()

	if ship.state=="dead" then
		ship.dead=ship.dead+1
		ship.rz=ship.dead
		if ship.dead>240 then
			main.next=oven.rebake(oven.modgame..".main_menu")
		end
		return
	end
	
--[[	if ship.fire and ship.mouse then
		if ship.mouse_x<=ship.px-20 then
			ship.left  = true
			ship.right = false
		elseif ship.mouse_x>=ship.px+20 then
			ship.left  = false
			ship.right = true	
		else
			ship.left  = false
			ship.right = false
		end
	end
]]
	if ship.left or srecaps.get("left") then
	
		if ship.vx>0 then ship.vx=0 end
		
		ship.vx = ship.vx-ship.speed
	elseif ship.right or srecaps.get("right") then
	
		if ship.vx<0 then ship.vx=0 end
		
		ship.vx = ship.vx+ship.speed
	end
	
	ship.vx = ship.vx*0.9
	ship.px = ship.px+ship.vx
	
	if ship.px>512 then
		ship.px = 512
		
		if ship.vx>0 then ship.vx=-ship.vx end
		
	end
	
	if ship.px<0 then
		ship.px = 0
		
		if ship.vx<0 then ship.vx=-ship.vx end
		
	end
	
	ship.cool=ship.cool-1
	
	if ship.fire or srecaps.get("fire") then
		if ship.cool<=0 then
			ship.cool=32
			
			if ship.power=="splitshot" then
				ship.cool=32
				bullets.add{px=ship.px,py=ship.py-32,vx=-4,vy=-8+math.random(),flava="ship"}
				bullets.add{px=ship.px,py=ship.py-32,vx=4,vy=-8+math.random(),flava="ship"}
			end

			if ship.power=="sureshot" then
				ship.cool=48
				bullets.add{px=ship.px-64,py=ship.py-32,vx=0,vy=-8+math.random(),flava="ship"}
				bullets.add{px=ship.px+64,py=ship.py-32,vx=0,vy=-8+math.random(),flava="ship"}
				bullets.add{px=ship.px-32,py=ship.py-32,vx=0,vy=-8+math.random(),flava="ship"}
				bullets.add{px=ship.px+32,py=ship.py-32,vx=0,vy=-8+math.random(),flava="ship"}
			end
			
			if ship.power=="singleshot" then
				ship.cool=16
			end
		
			bullets.add{px=ship.px,py=ship.py-32,vy=-8+math.random(),flava="ship"}
			beep.play("shoot")
		end
	end
	
	for i,v in ipairs(enemies.tab) do
		local dx=ship.px-v.px
		local dy=ship.py-v.py
		
		if dx*dx+dy*dy<=32*32 then
			ship.die()
			v.die(v)
			return
		end
	end
	
end

ship.draw=function()
	
	if ship.state=="dead" then return end
	local image=sheets.get("imgs/ships01")
	
	image:draw(1,ship.px,ship.py,ship.rz,64,64)
	
	local image=sheets.get("imgs/items01")
	gl.Color(1,1,1,1)
	
	if ship.power=="splitshot" then
		image:draw(5,ship.px,ship.py,ship.rz,64,64)
	elseif ship.power=="singleshot" then
		image:draw(6,ship.px,ship.py,ship.rz,64,64)
	elseif ship.power=="sureshot" then
		image:draw(7,ship.px,ship.py,ship.rz,64,64)
	end
end

ship.die=function()

	if ship.power then
		ship.power=nil
		explosions.gibs({px=ship.px, py=ship.py, gibs="ship"})
		beep.play("die1")
		return
	end

	if ship.state=="dead" then return end
	ship.state="dead"
	ship.dead=0
	
	explosions.gibs({px=ship.px, py=ship.py, gibs="ship"})
	beep.play("die1")
	beep.play("over")

end

	return ship
end
