-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math

local function dprint(a) print(wstr.dump(a)) end

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(state,game)
	local game=game or {}
	game.state=state
	
	game.modname=M.modname

	local cake=state.cake
	local opts=state.opts
	local canvas=state.canvas
	local font=canvas.font
	local flat=canvas.flat
	local gl=cake.gl
	local sheets=cake.sheets

	local gui=state.rebake("hunted.gui")
	local cells=state.rebake("hunted.cells")

	local wscores=state.rebake("wetgenes.gamecake.spew.scores")

	local recaps=state.rebake("wetgenes.gamecake.spew.recaps")


game.loads=function()

end
		
game.setup=function()

	wscores.set(1000)
	
	game.loads()

	gui.setup()
	gui.page("game")
	
	cells.setup()

end

game.clean=function()

	cells.clean()
	
	wscores.clean()
	gui.clean()

end

game.msg=function(m)

--	print(wstr.dump(m))

	if gui.msg(m) then return end -- gui can eat msgs
	
end

game.update=function()

	if recaps.get("up") then
		cells.move="up"
	elseif recaps.get("down") then
		cells.move="down"
	elseif recaps.get("left") then
		cells.move="left"
	elseif recaps.get("right") then
		cells.move="right"
	else
		cells.move=nil
	end
	
	
	cells.update()

	wscores.update()

	gui.update()

end

game.draw=function()

	sheets.get("imgs/floor"):draw(1,240,240,0,480,480)

	cells.draw()

	wscores.draw("arcade2")

	gui.draw()

end

	return game
end
