-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math


module(...)
modname=(...)

bake=function(state,ship)
	local ship=ship or {}
	ship.state=state

	ship.modname=modname
	
	local shots=state.rebake("aroids.shots")
	local rocks=state.rebake("aroids.rocks")

	local game=state.game
	
ship.setup=function()
--	print("ship setup")
	
	ship.px=0
	ship.py=0
	ship.vx=0
	ship.vy=0
	ship.rz=0
	ship.siz=64/256
	ship.heat=0
end

ship.clean=function()
end

ship.update=function()

	local r=4
	local v=4
	
	local tx=-math.sin(math.pi*-ship.rz/180)
	local ty=-math.cos(math.pi*-ship.rz/180)
	
	if game.input.left then
		ship.rz=ship.rz-r
	end

	if game.input.right then
		ship.rz=ship.rz+r
	end

	if game.input.up then
		ship.vx=tx*v
		ship.vy=ty*v
	end

	if game.input.fire then
		if ship.heat<=0 then
			ship.heat=16
			shots.item_add(ship.px+tx*10,ship.py+ty*10,ship.rz,tx*5,ty*5)
		end
	end
	
	ship.heat=ship.heat-1
	
	ship.vx=ship.vx*15/16
	ship.vy=ship.vy*15/16
	
	ship.px=ship.px+ship.vx
	ship.py=ship.py+ship.vy
	
	if ship.px<-(720/2) then ship.px=ship.px+720 end
	if ship.px> (720/2) then ship.px=ship.px-720 end
	if ship.py<-(480/2) then ship.py=ship.py+480 end
	if ship.py> (480/2) then ship.py=ship.py-480 end
	

	if rocks.age>100 then
	
		for _,v in pairs(rocks.items) do
		
			local dd=(v.siz*128)*1.25
			dd=dd*dd

			local dx=v.px-ship.px
			local dy=v.py-ship.py
			
			if dx*dx + dy*dy < dd then
				game.next=state.rebake("aroids.game_menu")
			end
		
		end
	end
	
end

ship.draw=function()

	state.cake.sheets.get("imgs/ship"):draw(1,(720/2)+ship.px,(480/2)+ship.py,ship.rz,ship.siz*173,ship.siz*256)

end
	
	
	return ship
end
