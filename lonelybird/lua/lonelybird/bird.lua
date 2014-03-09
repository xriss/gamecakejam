-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math

local function dprint(a) print(wstr.dump(a)) end

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,bird)
	local bird=bird or {}
	bird.oven=oven
	
	bird.modname=M.modname

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

	local ground=oven.rebake(oven.modgame..".ground")
	local walls=oven.rebake(oven.modgame..".walls")
--	local bird=oven.rebake(oven.modgame..".bird")

	local sscores=oven.rebake("wetgenes.gamecake.spew.scores")
	local srecaps=oven.rebake("wetgenes.gamecake.spew.recaps")


bird.loads=function()

end
		
bird.setup=function()

	bird.loads()

	bird.px=64
	bird.py=256

	bird.vy=0
	bird.ay=8/8


--	beep.stream("bird")

end

bird.clean=function()

end

bird.msg=function(m)

--	print(wstr.dump(m))

	
end

bird.flap=function()

	bird.vy=bird.vy-24
	ground.vx=ground.vx-2

end

bird.update=function()

	bird.vy=bird.vy+bird.ay
	
	bird.vy=bird.vy*14/16

	bird.py=bird.py+bird.vy

	
end

bird.draw=function()

		sheets.get("imgs/bird"):draw(1,bird.px,bird.py,bird.vy*8,64,64)
		
end

	return bird
end
