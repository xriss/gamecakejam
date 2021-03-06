-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math

local function dprint(a) print(wstr.dump(a)) end

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,game)
	local game=game or {}
	game.oven=oven
	
	game.modname=M.modname

	local cake=oven.cake
	local opts=oven.opts
	local canvas=cake.canvas
	local font=canvas.font
	local flat=canvas.flat
	local gl=oven.gl
	local sheets=cake.sheets

	local beep=oven.rebake("hunted.beep")
	local main=oven.rebake("hunted.main")
	local gui=oven.rebake("hunted.gui")
	local cells=oven.rebake("hunted.cells")

	local wscores=oven.rebake("wetgenes.gamecake.spew.scores")

	local recaps=oven.rebake("wetgenes.gamecake.spew.recaps")


game.loads=function()

end
		
game.setup=function()

	game.count=100

	main.level=main.level+1
	
	game.loads()

	gui.setup()
	gui.page("game")
	
	cells.setup()

	beep.play("start")

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

	local ups=recaps.ups()
	
	if ups.button("up") then
		cells.move="up"
	elseif ups.button("down") then
		cells.move="down"
	elseif ups.button("left") then
		cells.move="left"
	elseif ups.button("right") then
		cells.move="right"
	else
		cells.move=nil
	end
		
	cells.update()

	wscores.update()

	gui.update()
	
	if cells.next then
		if game.count>0 then game.count=game.count-1 else
			main.next=cells.next
		end
	end

end

game.draw=function()

	sheets.get("imgs/floor"):draw(1,240,240,nil,480,480)

	cells.draw()

	wscores.draw("arcade2")

	gui.draw()

end

	return game
end
