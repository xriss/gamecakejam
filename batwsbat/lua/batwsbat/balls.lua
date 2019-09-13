-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math


--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,balls)
	balls=balls or {}
	balls.modname=M.modname
	
	local gl=oven.gl
	local cake=oven.cake
	local opts=oven.opts
	local canvas=cake.canvas
	local font=canvas.font
	local flat=canvas.flat


	
balls.loads=function()
	
end
		
balls.setup=function()

	balls.loads()
	
	balls[1]=require(oven.modgame..".ball").bake(oven,{idx=1}).setup()

end


balls.clean=function()

	for i=1,#balls do
		balls[i].clean()
		balls[i]=nil
	end

end

balls.msg=function(m)
--	print(wstr.dump(m))

	for i=1,#balls do
		balls[i].msg()
	end
	
end

balls.update=function()

	for i=1,#balls do
		balls[i].update()
	end

end

balls.draw=function()
	
	for i=1,#balls do
		balls[i].draw()
	end
	
end
		
	return balls
end

