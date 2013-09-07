-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math

local function dprint(a) print(wstr.dump(a)) end

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,hud)
	local hud=hud or {}
	hud.oven=oven
	
	hud.modname=M.modname

	local cake=oven.cake
	local opts=oven.opts
	local canvas=cake.canvas
	local font=canvas.font
	local flat=canvas.flat
	local gl=oven.gl
	local sheets=cake.sheets
	
	local sgui=oven.rebake("wetgenes.gamecake.spew.gui")

	local gui=oven.rebake(oven.modgame..".gui")
	local main=oven.rebake(oven.modgame..".main")
--	local beep=oven.rebake(oven.modgame..".beep")
	local bullets=oven.rebake(oven.modgame..".bullets")
	local enemies=oven.rebake(oven.modgame..".enemies")
	local explosions=oven.rebake(oven.modgame..".explosions")
	local beep=oven.rebake(oven.modgame..".beep")

	local sscores=oven.rebake("wetgenes.gamecake.spew.scores").setup(1)
	local srecaps=oven.rebake("wetgenes.gamecake.spew.recaps")

	local layout=cake.layouts.create{}



hud.loads=function()

end
		
hud.setup=function()

	sscores.reset()
	
end

hud.clean=function()

	sscores.final_score({})

end

hud.msg=function(m)

--	print (wstr.dump(m))

end

hud.update=function()

		
end

hud.draw=function()
	
	sscores.draw("arcade2")
	
end

hud.score=function(num)
	
	sscores.add(num)
	
end

hud.reset=function()

	sscores.set(0)
	
end

	return hud
end
