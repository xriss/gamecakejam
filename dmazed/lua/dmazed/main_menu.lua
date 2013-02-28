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
	
	local wgui=oven.rebake("wetgenes.gamecake.spew.gui")

	local gui=oven.rebake("dmazed.gui")
	local main=oven.rebake("dmazed.main")

	local wscores=oven.rebake("wetgenes.gamecake.spew.scores")

	local recaps=oven.rebake("wetgenes.gamecake.spew.recaps")

	local layout=cake.layouts.create{}



menu.back="imgs/title"

menu.loads=function()

end
		
menu.setup=function()

	menu.loads()

	gui.setup()
	gui.page("menu")

	local qq=cake.sounds.queues[1]
	if not qq.oggs then
		qq.ogg_loop=true
		qq.state="play_queue"
		qq.oggs={"oggs/hunted"}
		qq.gain=0.75
		qq.pitch=1
	end

end

menu.clean=function()

	gui.clean()

end

menu.msg=function(m)

--	print(wstr.dump(m))

	if wgui.active then
		wgui.msg(m)	
	else
		gui.msg(m)
	end
	
end

menu.update=function()

	if wgui.active then
		wgui.update()	
	else
		gui.update()

		if recaps.get("fire_set") then -- start on spacebar

			gui.hooks("click",{id="start"})

		end
	end
	
end

menu.draw=function()
	
	if wgui.active then

		layout.viewport() -- clear clip area

		gl.ClearColor(pack.argb4_pmf4(0xf004))
		gl.Clear(gl.COLOR_BUFFER_BIT+gl.DEPTH_BUFFER_BIT)

		wgui.draw()	
	else
		sheets.get(menu.back):draw(1,240,240,nil,480,480)
		
		wscores.draw("arcade2")

		gui.draw()	
	end
	
end

	return menu
end
