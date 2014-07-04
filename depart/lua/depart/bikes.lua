-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math


--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,bikes)
	bikes=bikes or {}
	bikes.modname=M.modname

	local gl=oven.gl
	local cake=oven.cake
	local opts=oven.opts
	local canvas=cake.canvas
	local layouts=cake.layouts
	local font=canvas.font
	local flat=canvas.flat
	local sheets=cake.sheets

	local ground=oven.rebake(oven.modgame..".ground")
	local items=oven.rebake(oven.modgame..".items")
	local beep=oven.rebake(oven.modgame..".beep")

--	local bike={}
	
bikes.loads=function()

end
		
bikes.setup=function()

	bikes.loads()
	
	bikes.list={}
	
	bikes.px=512   - 128
	bikes.py=512+64-192-16
	
	bikes.pulse_time=0
	
end


bikes.clean=function()

	bikes.list=nil
end

bikes.msg=function(m)

end

bikes.get_player_a_bike=function()
	if not bikes.list then return end
	local pos={}
	for i,v in ipairs(bikes.list) do
		if not v.player then
			pos[#pos+1]=v
		end
	end
	if not pos[1] then return end
	return pos[ math.random(#pos) ]
end

bikes.update=function()
	
	bikes.pulse_time=(bikes.pulse_time+1)%120
	
	bikes.pulse_scale=1-(bikes.pulse_time/120)

	if bikes.pulse_time==0 then
--		ground.vx=ground.vx-16

		if math.random(100) < 75 then
			items.insert(nil,nil)--{px=512+256,py=60,vx=-1,vy=0,draw_index=1,draw_size=64})
		end
	end
	
	for i=#bikes.list,1,-1 do local v=bikes.list[i]
		v:update()
		if v.remove_from_list then -- set this flag to remove from list
			table.remove(bikes.list,i) -- safe to do as we iterate backwards
		end
	end
	
-- easy just to sort the bikes to fix the draw order
	table.sort(bikes.list,function(a,b)
		return a.py > b.py
	end)
	
end

bikes.draw=function()
	
	gl.PushMatrix()
	gl.Translate(bikes.px,bikes.py,0)
		
	for i=#bikes.list,1,-1 do local v=bikes.list[i]
		v:draw()
	end
	
	gl.PopMatrix()

end
	
bikes.insert=function(bike,opts)
	bike=bike or bikes.create(nil,opts)
	bikes.remove(bike)
	table.insert(bikes.list,bike)
	return bike
end

bikes.remove=function(bike)
	for i=#bikes.list,1,-1 do local v=bikes.list[i]
		if bike==v then
			table.remove(bikes.list,i)
		end
	end
end

bikes.create=function(bike,opts)

	bike=bike or {}

	bike.setup=function(bike,opts)
	
		bike.wheels={
			{
				px=-18,
				py=-24,
				rz=0,
				draw_size=32,
				draw_index=opts.wheel or 2,
				bounce=1,
				bouncev=0,
			},
			{
				px= 18,
				py=-26,
				rz=0,
				draw_size=32,
				draw_index=opts.wheel or 2,
				bounce=2,
				bouncev=0,
			},
		}
		bike.avatar={
				px=0,
				py=-48,
				rz=0,
				draw_size=64,
				draw_index=opts.avatar or 5,
				bounce=3,
				bouncev=0,
		}
		
		bike.px=opts.px or 0
		bike.py=opts.py or 0
		bike.rz=0

		bike.vx=opts.vx or 0
		bike.vy=opts.vy or 0
		
		bike.score=0
		
		bike.sfx1=string.format("%03d",(math.random(32768)%18)+1) -- pick a random
		bike.sfx2=string.format("%03d",(math.random(32768)%18)+1) -- pick a random
		
		return bike		
	end

	bike.clean=function(bike)

	end

local bounce=function(it)
	it.bouncev=it.bouncev - (it.bounce*(1/16))
	it.bouncev=it.bouncev*(254/256)
	it.bounce=it.bounce+it.bouncev
end

	bike.set_bounce=function(a,b,c)
		bike.wheels[1].bounce=c
		bike.wheels[2].bounce=b
		bike.avatar.bounce=a
	end

	bike.update=function(bike)
	
		local function b() bike.set_bounce(math.random(4),math.random(4),math.random(4)) end

		local friction=252/256
		
		local ax=(-bike.px)/(1024*4)
		local ay=0--(-bike.py)/512
--		local dd=ax*ax + ay*ay
--		ax=ax*dd*4
--		ay=ay*dd*4

		local ppyd=90
		local ppyi=math.floor(bike.py/ppyd)*ppyd
		local ppyf=(bike.py%ppyd)-(ppyd/2)
		if ppyf*ppyf < 8*8 then ppyf=0 end -- clamp center
		ay=ay + (-2*ppyf/ppyd)
		
		local howclose=90
		for i,v in ipairs(bikes.list) do -- push away from all close bikes
			if v~=bike then -- skip self
				local dx=v.px-bike.px
				local dy=v.py-bike.py
				local dd=dx*dx+dy*dy
				if dd<howclose*howclose then -- push away when close
					local d=math.sqrt(dd)
					dx=dx/d
					dy=dy/d
					local p=(howclose-d)/64
					ax=ax-dx*p
					ay=ay-dy*p
				end
			end
		end
		
		bike.vx=bike.vx+ax
		bike.vy=bike.vy+ay
		
		if bikes.pulse_time==0 then
			if bike.player then bike.rotation=bike.player.rotation b() else bike.rotation=nil end
			bike.rotation_pulse=5+((256-bike.px)/256)
		end
		
		if bike.rotation and bike.rotation_pulse then
			local rc=math.cos(math.pi*bike.rotation/180)
			local rs=math.sin(math.pi*bike.rotation/180)
			bike.vx=bike.vx+(rc*bike.rotation_pulse)
			bike.vy=bike.vy+(rs*bike.rotation_pulse)
			bike.rotation_pulse=bike.rotation_pulse*2/4
		end
		
		bike.vx=bike.vx*friction
		bike.vy=bike.vy*friction

		bike.px=bike.px+bike.vx
		bike.py=bike.py+bike.vy
		
		local lx=512-32
		local ly=180
		if bike.px<-lx then bike.px=-lx bike.vx= (math.abs(bike.vx)+1) b() beep.play(bike.sfx2) end
		if bike.px> lx then bike.px= lx bike.vx=-(math.abs(bike.vx)+1) b() beep.play(bike.sfx2) end
		if bike.py<-ly then bike.py=-ly bike.vy= (math.abs(bike.vy)+1) b() beep.play(bike.sfx2) end
		if bike.py> ly then bike.py= ly bike.vy=-(math.abs(bike.vy)+1) b() beep.play(bike.sfx2) end
		
		for i,wheel in ipairs(bike.wheels) do
			wheel.rz=(wheel.rz+8)%360
		end
		
		bounce(bike.wheels[1])
		bounce(bike.wheels[2])
		bounce(bike.avatar)
		
	end

	bike.draw=function(bike)

		local color=sheets.get("imgs/bikes")
		local grey=sheets.get("imgs/bots")
		
		gl.PushMatrix()
		gl.Translate(bike.px,bike.py,0)
		gl.Scale(2,2,1)
		
		for i,v in ipairs{bike.wheels[1],bike.wheels[2],bike.avatar} do
			local image=grey
			if bike.player then image=color end
			image:draw(v.draw_index,v.px,v.py+v.bounce,v.rz+v.bounce*4,v.draw_size,v.draw_size)
		end
	
		gl.PopMatrix()
	end
	
	return bike:setup(opts)
end

	return bikes
end

