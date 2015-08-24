-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math

local function dprint(a) print(wstr.dump(a)) end

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,world)
	local world=world or {}
	world.oven=oven
	
	world.modname=M.modname

	local cake=oven.cake
	local opts=oven.opts
	local canvas=cake.canvas
	local font=canvas.font
	local flat=canvas.flat
	local gl=oven.gl
	local sheets=cake.sheets
	

	local gui=oven.rebake(oven.modgame..".gui")
	local main=oven.rebake(oven.modgame..".main")
	local play=oven.rebake(oven.modgame..".main_play")
	local beep=oven.rebake(oven.modgame..".beep")

	local chars=oven.rebake(oven.modgame..".chars")
	local mon=oven.rebake(oven.modgame..".mon")
	
	local console=oven.rebake("wetgenes.gamecake.mods.console")

world.loads=function()

end
		
world.setup=function()

	world.loads()
	
	mon.setup()
	chars.setup()

end

world.clean=function()

	mon.clean()
	chars.clean()
	
end

world.msg=function(m)

--	print(wstr.dump(m))

end

world.update=function()

	mon.update()
	chars.update()

end

world.draw=function()

	world.px=800/2
	world.py=16+144/2

	gl.PushMatrix()
	gl.Translate(world.px,world.py,0)
	
	if world.scene=="rest" then
		sheets.get("imgs/rest_01"):draw(3,0,0,nil,256*3,48*3)
		sheets.get("imgs/rest_01"):draw(2,0,0,nil,256*3,48*3)
	else
		sheets.get("imgs/world_01"):draw(3,0,0,nil,256*3,48*3)
		sheets.get("imgs/world_01"):draw(2,0,0,nil,256*3,48*3)
	end
	
	chars.draw()
	mon.draw()
	
	if world.scene=="rest" then
		sheets.get("imgs/rest_01"):draw(1,0,0,nil,256*3,48*3)
	else
		sheets.get("imgs/world_01"):draw(1,0,0,nil,256*3,48*3)
	end
	
	gl.PopMatrix()
	gl.Color(1,1,1,1)
end

-- goto rest scene
world.rest=function()

	mon.goto_rest()
	chars.clean()
	world.scene="rest"

	beep.stream("rest")
	
end

-- goto fight scene
world.fight=function()
	chars.goto_fight()
	mon.goto_fight()
	world.scene=nil
	
	beep.stream("play")

end


	return world
end
