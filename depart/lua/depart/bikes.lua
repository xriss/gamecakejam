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

	local bike={}
	
bikes.loads=function()

end
		
bikes.setup=function()

	bikes.loads()
	
	bikes.list={}
	
	bikes.px=512
	bikes.py=128*3
	
end


bikes.clean=function()

end

bikes.msg=function(m)

end

bikes.update=function()
	
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
				draw_index=1,
			},
			{
				px= 18,
				py=-26,
				rz=0,
				draw_size=32,
				draw_index=1,
			},
		}
		bike.avatar={
				px=0,
				py=-48,
				rz=0,
				draw_size=64,
				draw_index=opts.avatar or 2,
		}
		
		bike.px=opts.px or 0
		bike.py=opts.py or 0
		bike.rz=0

		bike.vx=opts.vx or 0
		bike.vy=opts.vy or 0
		
		return bike		
	end

	bike.clean=function(bike)

	end

	bike.update=function(bike)
	
		local friction=254/256
		
		local ax=(-bike.px)/512
		local ay=(-bike.py)/512
		local dd=ax*ax + ay*ay
		ax=ax*dd*4
		ay=ay*dd*4
		
		for i,v in ipairs(bikes.list) do -- push away from all close bikes
			if v~=bike then -- skip self
				local dx=v.px-bike.px
				local dy=v.py-bike.py
				local dd=dx*dx+dy*dy
				if dd<64*64 then -- push away when close
					local d=math.sqrt(dd)
					dx=dx/d
					dy=dy/d
					local p=(64-d)/128
					ax=ax-dx*p
					ay=ay-dy*p
				end
			end
		end
		
		bike.vx=bike.vx+ax
		bike.vy=bike.vy+ay
		
		bike.vx=bike.vx*friction
		bike.vy=bike.vy*friction

		bike.px=bike.px+bike.vx
		bike.py=bike.py+bike.vy
		
		local lx=512-32
		local ly=192-32
		if bike.px<-lx then bike.vx= math.abs(bike.vx) end
		if bike.px> lx then bike.vx=-math.abs(bike.vx) end
		if bike.py<-ly then bike.vy= math.abs(bike.vy) end
		if bike.py> ly then bike.vy=-math.abs(bike.vy) end
		
		for i,wheel in ipairs(bike.wheels) do
			wheel.rz=(wheel.rz+8)%360
		end
		
	end

	bike.draw=function(bike)

		local image=sheets.get("imgs/bikes")
		
		gl.PushMatrix()
		gl.Translate(bike.px,bike.py,0)
		
		for i,v in ipairs{bike.wheels[1],bike.wheels[2],bike.avatar} do
			image:draw(v.draw_index,v.px,v.py,v.rz,v.draw_size,v.draw_size)
		end
	
		gl.PopMatrix()
	end
	
	return bike:setup(opts)
end

	return bikes
end

