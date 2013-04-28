-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math


--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,bat)
	bat=bat or {}
	bat.modname=M.modname
	
	local gl=oven.gl
	local cake=oven.cake
	local opts=oven.opts
	local canvas=cake.canvas
	local layouts=cake.layouts
	local font=canvas.font
	local flat=canvas.flat


	
bat.loads=function()
	
end
		
bat.setup=function()

	bat.loads()


	bat.sx=20
	bat.sy=20*8

	if bat.idx==1 then
	
		bat.px=0+40
		bat.py=250
		
	else
	
		bat.px=800-40
		bat.py=250
		
	end


	return bat
end


bat.clean=function()


end

bat.msg=function(m)
--	print(wstr.dump(m))

	
end

bat.update=function()

	bat.py=bat.py+1

end

bat.draw=function()
	
	local sx=bat.sx*0.5
	local sy=bat.sy*0.5

	flat.tristrip("xyz",{	
		bat.px-sx,bat.py-sy,0,
		bat.px+sx,bat.py-sy,0,
		bat.px-sx,bat.py+sy,0,
		bat.px+sx,bat.py+sy,0,
	})

end
		
	return bat
end

