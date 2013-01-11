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
	local sheets=cake.sheets
	
	local gui=state.rebake("hunted.gui")
	local main=state.rebake("hunted.main")

	local wscores=state.rebake("wetgenes.gamecake.spew.scores")

	local recaps=state.rebake("wetgenes.gamecake.spew.recaps")



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

	if gui.msg(m) then return end -- gui can eat msgs
	
end

menu.update=function()

	gui.update()

	if recaps.get("fire_set") then -- start on spacebar

		gui.hooks("click",{id="start"})

	end
	
end

menu.draw=function()
	
	sheets.get(menu.back):draw(1,240,240,nil,480,480)
	
	wscores.draw("arcade2")

	gui.draw()	

end

	return menu
end
