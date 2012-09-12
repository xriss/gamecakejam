-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math



module(...)
modname=(...)

bake=function(state,shots)
	local shots=shots or {}
	shots.state=state

	shots.modname=modname
	
	local game=state.game

	
shots.setup=function(state)
	print("shots setup")
	
	shots.items={}
		
end

shots.item_del=function(it)
	shots.items[it]=nil
end

shots.item_new=function()

	local it={}
	
	it.update=shots.item_update
	it.draw=shots.item_draw
	it.del=shots.item_del
	
	it.px=0
	it.py=0
	it.rz=0
	it.vx=0
	it.vy=0
	it.age=0
	it.siz=128/256
	
	shots.items[it]=it
	
	return it
end

shots.item_add=function(px,py,rz,vx,vy)

	local it=shots.item_new()
	
	it.px=px
	it.py=py
	it.rz=rz
	it.vx=vx
	it.vy=vy
	
	return it
end

shots.item_update=function(it)

	it.px=it.px+it.vx
	it.py=it.py+it.vy
	
	if it.px<-(720/2) then it.px=it.px+720 end
	if it.px> (720/2) then it.px=it.px-720 end
	if it.py<-(480/2) then it.py=it.py+480 end
	if it.py> (480/2) then it.py=it.py-480 end
	
	it.age=it.age+1
	
	if it.age>100 then
		it:del()
	end
	
end

shots.item_draw=function(it)

	state.cake.sheets:get("imgs/bullet3"):draw(1,(720/2)+it.px,(480/2)+it.py,it.rz,it.siz)
	
end


shots.clean=function(state)
end

shots.update=function(state)

	for _,v in pairs(shots.items) do
		v:update()
	end

end

shots.draw=function(state)

	for _,v in pairs(shots.items) do
		v:draw()
	end
	
end
	
	
	return shots
end
