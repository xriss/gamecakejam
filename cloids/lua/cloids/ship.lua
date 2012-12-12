-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(state,ship)
	local ship=ship or {}
	ship.state=state

	
	local game=state.rebake("cloids.main_game")
	local shots=state.rebake("cloids.shots")
	local grapes=state.rebake("cloids.grapes")
	
		
ship.setup=function()
--	print("ship setup")
	
	ship.px=0
	ship.py=0
	ship.vx=0
	ship.vy=0
	ship.rz=0
	ship.siz=128/256
	ship.heat=0
end

ship.clean=function()
end

ship.update=function()

	if ship.heat>0 then ship.heat=ship.heat-1 end

	if game.but and ship.heat<=0 then
	
--		ship.px=game.px
--		ship.py=game.py
		
		local dx=game.px-ship.px
		local dy=game.py-ship.py
		
		local dd=dx*dx + dy*dy
		local d=math.sqrt(dd)
		if d==0 then d=1 end
		
		local nx=dx/d
		local ny=dy/d
		
		local r=math.atan2(dy,dx)
		
		ship.rz=180 + (r/math.pi*180)
		
		ship.vx=ship.vx-(nx*4)
		ship.vy=ship.vy-(ny*4)
		
		ship.heat=16
		
		shots.add({
			px=ship.px,
			py=ship.py,
			vx=nx*6,
			vy=ny*6,
			rz=ship.rz,
			})
	
	end
	
	ship.vx=ship.vx*31/32
	ship.vy=ship.vy*31/32
	
	ship.px=ship.px+ship.vx
	ship.py=ship.py+ship.vy
	
	if ship.px<-360 then ship.px=-360 if ship.vx<0 then ship.vx=ship.vx*-2 end end
	if ship.px> 360 then ship.px= 360 if ship.vx>0 then ship.vx=ship.vx*-2 end end
	if ship.py<-240 then ship.py=-240 if ship.vy<0 then ship.vy=ship.vy*-2 end end
	if ship.py> 240 then ship.py= 240 if ship.vy>0 then ship.vy=ship.vy*-2 end end

end

ship.draw=function()

	state.cake.sheets.get("imgs/ship"):draw(1,(720/2)+ship.px,(480/2)+ship.py,ship.rz,ship.siz*128,ship.siz*128)

end
	
	
	return ship
end
