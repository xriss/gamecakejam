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
	local fonts=cake.fonts
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
	
	local number=sscores.get(1)
--	sscores.draw("arcade2")
--	print(number)
	font.set("Akashi")
	
	number=(tostring(number))
	font.set_size(42)
	font.set_xy(256-font.width(number)/2,3)
	gl.Color(1,1,1,1) 
	font.draw(number)
	
	local s="sup, wotcha doin killin mah shawties?"
	font.set_size(16)
	font.set_xy(256-font.width(s)/2,53)
	gl.Color(0,1,1,1)
	font.draw(s)
	
	
--	local s="hey, i'm talking to you. stop ignoring me!"	
--	local s="ok, so you're probably not reading this then."	
--	local s="or maybe you are but there's no possible way i can hear you. can i?"

	
end

hud.score=function(num)
	
	sscores.add(num)
	
end

hud.reset=function()

	sscores.set(0)
	
end

	return hud
end
