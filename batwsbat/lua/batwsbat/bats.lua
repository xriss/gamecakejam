-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math


--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,bats)
	bats=bats or {}
	bats.modname=M.modname
	
	local gl=oven.gl
	local cake=oven.cake
	local opts=oven.opts
	local canvas=cake.canvas
	local layouts=cake.layouts
	local font=canvas.font
	local flat=canvas.flat


	
bats.loads=function()
	
end
		
bats.setup=function()

	bats.loads()
	
	bats.fingers={}
	bats.fingers[0]={}  -- key state
	bats.fingers[-1]={} -- key up
	bats.fingers[ 1]={} -- key down
	
	bats[1]=require(oven.modgame..".bat").bake(oven,{idx=1}).setup()
	bats[2]=require(oven.modgame..".bat").bake(oven,{idx=2}).setup()

end

bats.finger_on=function(id)
	return bats.fingers[0][id] -- or bats.fingers[0][id]
end
bats.finger_off=function(id)
	return bats.fingers[-1][id] or (not bats.fingers[0][id])
end

bats.clean=function()

	for i=1,#bats do
		bats[i].clean()
		bats[i]=nil
	end

end

bats.msg=function(m)
--	print(wstr.dump(m))

	if m.class=="mouse" then
		local id
		if m.x<400 and m.y<250 then id=1 end
		if m.x<400 and m.y>250 then id=2 end
		if m.x>400 and m.y<250 then id=3 end
		if m.x>400 and m.y>250 then id=4 end
		
		if id then
			if m.action==1 then
				bats.fingers[0][id]=true
				bats.fingers[1][id]=true
			elseif m.action==-1 then
				bats.fingers[0][id]=false
				bats.fingers[-1][id]=true
			end
		end
		
	end

	for i=1,#bats do
		bats[i].msg(m)
	end
	
end

bats.update=function()

	for i=1,#bats do
		bats[i].update()
	end

	-- clear transition states
	bats.fingers[-1]={} -- key up
	bats.fingers[ 1]={} -- key down
end

bats.draw=function()
	
	for i=1,#bats do
		bats[i].draw()
	end
	
end
		
	return bats
end

