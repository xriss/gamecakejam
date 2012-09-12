-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math



module(...)
modname=(...)

bake=function(state,rocks)
	local rocks=rocks or {}
	rocks.state=state

	rocks.modname=modname
	
	local game=state.game

	local shots=state:rebake("aroids.shots")

	
rocks.setup=function(state)
	print("rocks setup")
	
	rocks.items={}
	
	for i=1,1 do
	
		local px=math.random(0,720)
		local py=math.random(0,480)
		local rz=math.random(0,360)
		local vr=math.random(100,200)/100
		local vx=math.random(100,500)/100
		local vy=math.random(100,500)/100
		local sz=256/256
		rocks.item_add(px,py,rz,vx,vy,vr,sz)
	
	end

		
end

rocks.item_del=function(it)
	rocks.items[it]=nil
end

rocks.item_new=function()

	local it={}
	
	it.update=rocks.item_update
	it.draw=rocks.item_draw
	it.del=rocks.item_del
	it.splode=rocks.item_splode
	
	it.px=0
	it.py=0
	it.rz=0
	it.vx=0
	it.vy=0
	it.vr=0
	it.age=0
	it.siz=64/256
	
	rocks.items[it]=it
	
	return it
end

rocks.item_add=function(px,py,rz,vx,vy,vr,sz)

	local it=rocks.item_new()
	
	it.px=px
	it.py=py
	it.rz=rz
	it.vx=vx
	it.vy=vy
	it.vr=vr
	it.siz=sz
	
	return it
end

rocks.item_update=function(it)

	it.px=it.px+it.vx
	it.py=it.py+it.vy
	
	if it.px<-(720/2) then it.px=it.px+720 end
	if it.px> (720/2) then it.px=it.px-720 end
	if it.py<-(480/2) then it.py=it.py+480 end
	if it.py> (480/2) then it.py=it.py-480 end
	
	it.age=it.age+1
	
	it.rz=it.rz+it.vr
	
	local dd=(it.siz*128)
	dd=dd*dd
	
	for _,v in pairs(shots.items) do
	
		local dx=v.px-it.px
		local dy=v.py-it.py
		
		if dx*dx + dy*dy < dd then
			v:del()
			it:splode()
			break
		end
	
	end
	
end

rocks.item_splode=function(it)

	for i=1,2 do
	
		local px=it.px
		local py=it.py
		local rz=math.random(0,360)
		local vr=math.random(100,200)/100
		local vx=math.random(100,500)/100
		local vy=math.random(100,500)/100
		local sz=it.siz*3/4
		rocks.item_add(px,py,rz,vx,vy,vr,sz)	

	end
	
	it:del()
	
end

rocks.item_draw=function(it)

	state.cake.sheets:get("imgs/chick3"):draw(1,(720/2)+it.px,(480/2)+it.py,it.rz,it.siz)
	
end


rocks.clean=function(state)
end

rocks.update=function(state)

	for _,v in pairs(rocks.items) do
		v:update()
	end

end

rocks.draw=function(state)

	for _,v in pairs(rocks.items) do
		v:draw()
	end
	
end
	
	
	return rocks
end
