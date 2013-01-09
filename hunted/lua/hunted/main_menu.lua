-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math

local function dprint(a) print(wstr.dump(a)) end

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(state,menu)
	local menu=menu or {}
	menu.state=state
	
	menu.modname=M.modname

	local cake=state.cake
	local opts=state.opts
	local canvas=state.canvas
	local font=canvas.font
	local flat=canvas.flat
	local gl=cake.gl
	
	local gui=state.rebake("hunted.gui")


menu.loads=function()

end
		
menu.setup=function()

	menu.loads()

	gui.setup()
	gui.page("menu")

end

menu.clean=function()

	gui.clean()

end

menu.msg=function(m)

--	print(wstr.dump(m))

	if gui.msg(m) then return end -- gui can eat msgs
	
end

menu.update=function()

	gui.update()

end

menu.draw=function()
		
	gui.draw()

end

	return menu
end