-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math

local function dprint(a) print(wstr.dump(a)) end

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,ships)
	local ships=ships or {}
	ships.oven=oven
	
	ships.modname=M.modname

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



ships.msg=function()
end
ships.loads=function()
end
ships.setup=function()
	ships[1]=(ships[1] or ships.ship()).setup({idx=1})
	ships[2]=(ships[2] or ships.ship()).setup({idx=2})

end
ships.clean=function()
	for i,ship in ipairs(ships) do ship.clean() end
end
ships.update=function()
	for i,ship in ipairs(ships) do ship.update() end
	if ships[1].state=="dead" and ships[2].state=="dead" then
		if ships[1].dead>240 and ships[2].dead>240 then
			main.next=oven.rebake(oven.modgame..".main_menu")
		end
		return
	end
end
ships.draw=function()
	for i,ship in ipairs(ships) do ship.draw() end
end

-- create a new ship
ships.ship=function(ship)
ship=ship or {}
		
ship.setup=function(opts)

	ship.idx=opts.idx

	ship.argb=0xffffffff

	ship.px=ship.idx*256-128
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
	
	if ship.idx==2 then
		ship.argb=0xffff44ff
		ship.state="spawn"
		ship.spawn=0
		ship.py=768
	end

	return ship
end

ship.clean=function()

end

ship.update=function()

	local ups=srecaps.ups(ship.idx)
	local axis=ups.axis()
	
	if ups.button("mouse_left_set") then
		ship.mouse 	= true
	end

	if ship.mouse then
		ship.px     = axis.mx
		ship.mouse_y= axis.my
	end

	if ups.button("left_set") then
		ship.mouse = false
		ship.left = true
	end
	if ups.button("left_clr") then
		ship.left = false
	end

	if ups.button("right_set") then
		ship.mouse = false
		ship.right = true
	end
	if ups.button("right_clr") then
		ship.right = false
	end

	if ups.button("fire_set") then -- mouse buttons also set fire key
		ship.fire = true
	end
	if ups.button("fire_clr") then
		ship.fire = false
	end



	if ship.state=="dead" then
		ship.dead=ship.dead+1
--		ship.rz=ship.dead
		return
	end

	if ship.state=="spawn" then
		ship.spawn=ship.spawn+1
		if ship.spawn>512 then -- gave up and died (slow fade out, press fire to start)
			ship.state="dead"
			ship.dead=ship.spawn
		end
	end

	if ship.left then
	
		if ship.vx>0 then ship.vx=0 end
		
		ship.vx = ship.vx-ship.speed
		
	elseif ship.right then
	
		if ship.vx<0 then ship.vx=0 end
		
		ship.vx = ship.vx+ship.speed
	end
	
	ship.vx = ship.vx*0.9
	ship.px = ship.px+ship.vx
	
	if ship.state~="spawn" then -- do not fix height of spawn

		ship.vy = ship.vy*0.9
		if ship.vy*ship.vy < 0.001 then ship.vy=0 end
		ship.py = ship.py+ship.vy
		if ship.py>((768-32)-96)+1 then
			ship.vy=ship.vy-0.5
		elseif ship.py<((768-32)-96)-1 then
			ship.vy=ship.vy+0.5
		end

	end
	
	if ship.px>512 then
		ship.px = 512
		
		if ship.vx>0 then
			ship.vx=-ship.vx
		end
		
	end
	
	if ship.px<0 then
		ship.px = 0
		
		if ship.vx<0 then
			ship.vx=-ship.vx
		end
		
	end
	
	ship.cool=ship.cool-1
	
	if ship.fire then
		if ship.cool<=0 then
			ship.cool=32
			
			if ship.state=="spawn" then -- enter game on first shot
				ship.state="alive"
			end
			
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
	
	if ship.state~="spawn" then -- do not die during spawn
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
	
	for i,v in ipairs(ships) do
		if v~=ship and v.state=="alive" then
			local vv=v.vx*v.vx+v.vy*v.vy
			local ss=ship.vx*ship.vx+ship.vy*ship.vy
			local dx=ship.px-v.px
			local dy=ship.py-v.py
			
			
			if dx*dx+dy*dy<=32*32 then
				if ship.vx>0 and v.px>ship.px then
					v.vx=v.vx+ship.vx
					ship.vx=-ship.vx
					local d=math.sqrt(dx*dx+dy*dy) if d<1/256 then d=1/256 end
					ship.px=v.px+(34*dx/d)
					ship.py=v.py+(34*dy/d)
				elseif ship.vx<0 and v.px<ship.px then
					v.vx=v.vx+ship.vx
					ship.vx=-ship.vx
					local d=math.sqrt(dx*dx+dy*dy) if d<1/256 then d=1/256 end
					ship.px=v.px+(34*dx/d)
					ship.py=v.py+(34*dy/d)
				end

				local d=0
				if		v.py>ship.py	then	d=-1
				elseif	v.py<ship.py	then	d=1
				elseif	ss>vv			then	d=-1
										else	d=1		end
				if d~=0 then
					ship.vy=ship.vy+math.sqrt(ss+vv)*(-0.25*d)
					v.vy=v.vy+math.sqrt(ss+vv)*(0.25*d)
				end
			end
		end
	end
	
end

ship.draw=function()
	
	if ship.state=="dead" then return end
	local image=sheets.get("imgs/ships01")
	
	gl.Color(gl.C8(ship.argb))

	if ship.state=="spawn" then
		local r,g,b,a=gl.C8(ship.argb)
		local m=(512-ship.spawn)/512
		if m<0 then m=0 end
		gl.Color(r*m,g*m,b*m,a*m)
	end

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

ship.live=function(it)
	ship.px=it.px
	ship.py=it.py
	ship.state="spawn"
	ship.dead=0
	ship.spawn=0
	beep.play("power")
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

	return ships
end
