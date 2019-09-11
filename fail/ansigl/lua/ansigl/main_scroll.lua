-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math

local ansi=require("ansigl.ansi")

local function dprint(a) print(wstr.dump(a)) end

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,main_scroll)
	local main_scroll=main_scroll or {}
	main_scroll.oven=oven
	
	main_scroll.modname=M.modname

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

	local chars=oven.rebake(oven.modgame..".chars")

	local layout=cake.layouts.create{}



main_scroll.loads=function()

end
		
main_scroll.setup=function()

	main_scroll.loads()
	chars.setup()

	local map=ansi.cmap({resize=true,xh=80,yh=1})
	map.y=1
	map.print(opts.ansibins[1].data)
	chars.set_map(map)
	chars.y=-oven.opts.height

end

main_scroll.clean=function()

end

main_scroll.msg=function(m)

--	print(wstr.dump(m))

	
end

main_scroll.update=function()

	chars.y=chars.y+1
	if chars.y>chars.map.yh*chars.font_h then chars.y=-oven.opts.height end
end

main_scroll.draw=function()
	
	chars.draw(0,0,oven.opts.width,oven.opts.height)

end

	return main_scroll
end
