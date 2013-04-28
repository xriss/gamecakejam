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
	
	bats[1]=require(oven.modgame..".bat").bake(oven,{idx=1}).setup()
	bats[2]=require(oven.modgame..".bat").bake(oven,{idx=2}).setup()

end


bats.clean=function()

	for i=1,#bats do
		bats[i].clean()
		bats[i]=nil
	end

end

bats.msg=function(m)
--	print(wstr.dump(m))

	for i=1,#bats do
		bats[i].msg(m)
	end
	
end

bats.update=function()

	for i=1,#bats do
		bats[i].update()
	end

end

bats.draw=function()
	
	for i=1,#bats do
		bats[i].draw()
	end
	
end
		
	return bats
end

