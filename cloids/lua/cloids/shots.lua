-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(state,shots)
	local shots=shots or {}
	shots.state=state

	
	local game=state.rebake("cloids.main_game")
	local beep=state.rebake("cloids.beep")
		
shots.setup=function()

	shots.items={}

end

shots.clean=function()
end

shots.add=function(tab)
	local it={}
	
	it.px=tab.px or 0
	it.py=tab.py or 0
	it.vx=tab.vx or 0
	it.vy=tab.vy or 0
	it.rz=tab.rz or 0
	it.siz=1
	it.age=0
	
	beep.play("shoot")

	shots.items[ #shots.items+1 ]=it
	return it
end

shots.update=function()

local maxage=150

	for i=1,#shots.items do
		if i>#shots.items then break end
		
		local it=shots.items[i]
		
		it.age=it.age+1
		
		if it.age>maxage-50 then it.siz=(maxage-it.age)/50 end
		
		if it.age>maxage then it.dead=true end
		
--		it.vx=it.vx*31/32
--		it.vy=it.vy*31/32

		it.px=it.px+it.vx
		it.py=it.py+it.vy
		
		if it.px<-360 then it.px=-360 if it.vx<0 then it.vx=it.vx*-1 end end
		if it.px> 360 then it.px= 360 if it.vx>0 then it.vx=it.vx*-1 end end
		if it.py<-240 then it.py=-240 if it.vy<0 then it.vy=it.vy*-1 end end
		if it.py> 240 then it.py= 240 if it.vy>0 then it.vy=it.vy*-1 end end
		
		if it.dead then -- hacks
			table.remove(shots.items,i)
			i=i-1
		end
	end

end

shots.draw=function()

	for i,it in ipairs(shots.items) do

state.cake.sheets.get("imgs/shoot"):draw(1,(720/2)+it.px,(480/2)+it.py,it.rz,it.siz*32,it.siz*32)
	
	end


end
	
	
	return shots
end
