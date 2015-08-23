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
--	local beep=oven.rebake(oven.modgame..".beep")

	local sscores=oven.rebake("wetgenes.gamecake.spew.scores")
	local srecaps=oven.rebake("wetgenes.gamecake.spew.recaps")

	local draw_screen=oven.rebake(oven.modgame..".draw_screen")

--	local layout=cake.layouts.create{}


menu.loads=function()

end
		
menu.setup=function()

	menu.loads()

--	gui.setup()
--	gui.page("menu")

--	beep.stream("menu")

end

menu.clean=function()

--	gui.clean()

end

menu.msg=function(m)

--	print(wstr.dump(m))

--[[
	if sgui.active then
		sgui.msg(m)	
	else
		gui.msg(m)
	end
]]
	
	if m.action==1 then
		main.next=oven.rebake(oven.modgame..".main_play")
	end
	
end

menu.update=function()

--	if sgui.active then
--		sgui.update()	
--	else
--		gui.update()
--	end
	
end

menu.draw=function()
	
--	if sgui.active then

	--	layout.viewport() -- clear clip area

--		gl.ClearColor(pack.argb4_pmf4(0xf004))
--		gl.Clear(gl.COLOR_BUFFER_BIT+gl.DEPTH_BUFFER_BIT)

--		sgui.draw()	
--	else
	
		draw_screen.draw_into(function()

			sheets.get("imgs/splash"):draw(1,400,300,nil,800,600)
			
--			sscores.draw("arcade2")

--			gui.draw()	

		end)
		draw_screen.draw()
	
--	end
	
end

	return menu
end
