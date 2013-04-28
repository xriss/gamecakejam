-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math


--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,ball)
	ball=ball or {}
	ball.modname=M.modname
	
	local gl=oven.gl
	local cake=oven.cake
	local opts=oven.opts
	local canvas=cake.canvas
	local layouts=cake.layouts
	local font=canvas.font
	local flat=canvas.flat


	
ball.loads=function()
	
end
		
ball.setup=function()

	ball.loads()
	
	ball.px=400
	ball.py=250

	ball.sx=20
	ball.sy=20

	return ball
end


ball.clean=function()


end

ball.msg=function(m)
--	print(wstr.dump(m))

	
end

ball.update=function()


end

ball.draw=function()

	local sx=ball.sx*0.5
	local sy=ball.sy*0.5

	flat.tristrip("xyz",{	
		ball.px-sx,ball.py-sy,0,
		ball.px+sx,ball.py-sy,0,
		ball.px-sx,ball.py+sy,0,
		ball.px+sx,ball.py+sy,0,
	})
	
end
		
	return ball
end

