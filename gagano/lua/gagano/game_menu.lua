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

	local game=oven.game
	local cake=oven.cake
	local sheets=cake.sheets
	local opts=oven.opts
	local canvas=cake.canvas
	local font=canvas.font
	local flat=canvas.flat
	local gl=oven.gl
	
	local gui=oven.game.gui

	print("menu",oven.game,oven.game.gui)

	
menu.loads=function()

	sheets.loads_and_chops{
		{"imgs/splash",1,1,0.5,0.5},
	}
	
end
		
menu.setup=function()

	if game.best_score < game.last_score then
		game.best_score = game.last_score
	end

	menu.loads()

	gui.page("menu")
end

menu.clean=function()

end

menu.msg=function(m)

--	print(wstr.dump(m))

	if gui.msg(m) then return end -- gui can eat msgs
	
end

menu.update=function()

	gui.update()

end

menu.draw=function()
		
	sheets.get("imgs/splash"):draw(1,720/2,480/2)
	
	gui.draw()


	font.set(cake.fonts.get(1))
	font.set_size(32,0)
	local s=game.last_score..""
	local sw=font.width(s)
	font.set_xy( 180-(sw/2)-60 ,480-32)
	font.draw(s)

	local s=game.best_score..""
	local sw=font.width(s)
	font.set_xy( 360+180-(sw/2)+60 ,480-32)
	font.draw(s)
	
end

	return menu
end
