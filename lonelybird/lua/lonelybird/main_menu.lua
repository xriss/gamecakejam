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

	local sscores=oven.rebake("wetgenes.gamecake.spew.scores")
	local srecaps=oven.rebake("wetgenes.gamecake.spew.recaps")



menu.back="imgs/title"

menu.loads=function()

end
		
menu.setup=function()

	main.day=math.random(1,2)

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
	
	if sgui.active then

		layout.viewport() -- clear clip area

		gl.Clear(gl.COLOR_BUFFER_BIT+gl.DEPTH_BUFFER_BIT)

		sgui.draw()	
	else

	if main.day==1 then
		sheets.get("imgs/day"):draw(1,512/2,512/2,nil,1024,512)
	else
		sheets.get("imgs/night"):draw(1,512/2,512/2,nil,1024,512)
	end


		sheets.get("imgs/ground"):draw(1,512/2,512/2,nil,1024,512)
		sheets.get("imgs/title"):draw(1,512/2,512/2,nil,512,512)
		
		sscores.draw("arcade2")

		sheets.get("imgs/back"):draw(1,512/2,512/2,nil,1024,1024)

		gui.draw()	

	end
	
end

	return menu
end
