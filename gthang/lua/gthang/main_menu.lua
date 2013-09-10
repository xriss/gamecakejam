-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math

local function dprint(a) print(wstr.dump(a)) end

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,menu)
	local menu=menu or {}
	menu.oven=oven
	
	menu.modname=M.modname

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
	local beep=oven.rebake(oven.modgame..".beep")
	local hud=oven.rebake(oven.modgame..".hud")

	local srecaps=oven.rebake("wetgenes.gamecake.spew.recaps")
	local sscores=oven.rebake("wetgenes.gamecake.spew.scores")

	local layout=cake.layouts.create{}



menu.back="imgs/title"

menu.loads=function()

end
		
menu.setup=function()

	menu.loads()

	gui.setup()
	gui.page("menu")

	beep.stream("menu")

end

menu.clean=function()

	gui.clean()

end

menu.msg=function(m)

--	print(wstr.dump(m))

	if sgui.active then
		sgui.msg(m)	
	else
		gui.msg(m)
	end
	
end

menu.update=function()

	if sgui.active then
		sgui.update()	
	else
		gui.update()
	end
	
end

menu.draw=function()
	local image=sheets.get("imgs/tits")
	
	image:draw(1,256,384,0,512,768)
	
	if sgui.active then

		layout.viewport() -- clear clip area

		gl.ClearColor(pack.argb4_pmf4(0xf004))
		gl.Clear(gl.COLOR_BUFFER_BIT+gl.DEPTH_BUFFER_BIT)

		sgui.draw()	
	else
--		sheets.get("imgs/title"):draw(1,320,240,nil,640,480)
		
--		hud.draw()

		gui.draw()	
		
		local s=(tostring(sscores.high))
		local h="HIGH SCORE"
		font.set("Akashi")
		font.set_size(42)
		font.set_xy(256-font.width(s)/2,20)
		gl.Color(1,1,1,1) 
		font.draw(s)
		font.set_size(18)
		font.set_xy(256-font.width(h)/2,5)
		gl.Color(0.3,0.7,0.7,1) 
		font.draw(h)
		
	end
	
	
end

	return menu
end
