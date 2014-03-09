-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math

local function dprint(a) print(wstr.dump(a)) end

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,ground)
	local ground=ground or {}
	ground.oven=oven
	
	ground.modname=M.modname

	local cake=oven.cake
	local opts=oven.opts
	local canvas=cake.canvas
	local font=canvas.font
	local flat=canvas.flat
	local gl=oven.gl
	local sheets=cake.sheets
	
	
	local gui=oven.rebake(oven.modgame..".gui")
	local main=oven.rebake(oven.modgame..".main")
--	local beep=oven.rebake(oven.modgame..".beep")

	local sscores=oven.rebake("wetgenes.gamecake.spew.scores")
	local srecaps=oven.rebake("wetgenes.gamecake.spew.recaps")


ground.loads=function()

end
		
ground.setup=function()

	ground.loads()


	ground.px=0
	ground.vx=-4

end

ground.clean=function()

end

ground.msg=function(m)

--	print(wstr.dump(m))

	
end

ground.update=function()

	if ground.vx*ground.vx > 4 then ground.vx=ground.vx*31/32 end

	ground.px=ground.px+ground.vx
	ground.bx=(1024*math.floor(ground.px/1024))
	
end

ground.draw=function()

-- simple wrapping background

	sheets.get("imgs/back"):draw(1,ground.px-1024-ground.bx,512/2,nil,1024,512)
	sheets.get("imgs/back"):draw(1,ground.px     -ground.bx,512/2,nil,1024,512)
	sheets.get("imgs/back"):draw(1,ground.px+1024-ground.bx,512/2,nil,1024,512)
		
end

	return ground
end
