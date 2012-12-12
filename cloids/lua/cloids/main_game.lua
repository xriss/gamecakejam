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
	local sheets=cake.sheets
	local opts=state.opts
	local canvas=state.canvas
	local font=canvas.font
	local flat=canvas.flat
	local gl=cake.gl
	
	local gui=state.rebake("cloids.gui")

	local ship=state.rebake("cloids.ship")

game.loads=function()

end
		
game.setup=function()

	game.px=0
	game.py=0
	game.but=false

	game.loads()

--	gui.setup()
--	gui.page("game")

	ship.setup()

end

game.clean=function()

--	gui.clean()

	ship.clean()
	
end

game.msg=function(m)

--	print(wstr.dump(m))

	if m.class=="mouse" then
	
		game.px=m.x-(720/2)
		game.py=m.y-(480/2)
		if m.action==1 then
			game.but=true
		elseif m.action==-1 then
			game.but=false
		end
	
	end

--	if gui.msg(m) then return end -- gui can eat msgs
	
end

game.update=function()

--	gui.update()
	ship.update()

end

game.draw=function()
		
	sheets.get("imgs/gameback"):draw(1,720/2,480/2)

	ship.draw()

--	gui.draw()

end

	return game
end
