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
	local canvas=cake.canvas
	local font=canvas.font
	local flat=canvas.flat
	local gl=state.gl
	
	local gui=state.rebake("cloids.gui")

	local ship=state.rebake("cloids.ship")
	local shots=state.rebake("cloids.shots")
	local grapes=state.rebake("cloids.grapes")
	local splats=state.rebake("cloids.splats")
	
	local beep=state.rebake("cloids.beep")
	beep.loads()

	local wscores=state.rebake("wetgenes.gamecake.spew.scores")
	
game.loads=function()

end
		
game.setup=function()

	game.px=0
	game.py=0
	game.but=false

	game.loads()

--	gui.setup()
--	gui.page("game")


	wscores.set(1000)
--	wscores.add(1000)
	
	ship.setup()
	shots.setup()
	grapes.setup()
	splats.setup()
	
	local	px=math.random(-360,360)
	local	py=math.random(-240,240)

	local colors={
		0xcf00,
		0xcff0,
		0xc0f0,
		0xc0ff,
		0xc00f,
	}

	for i=1,32 do
		grapes.add({
			px=px+math.random(-100,100)/100,
			py=py+math.random(-100,100)/100,
			vx=math.random(-100,100)/100,
			vy=math.random(-100,100)/100,
			rz=math.random(0,360),
			argb=colors[math.random(1,#colors)],
			})
	end

end

game.clean=function()

--	gui.clean()

	wscores.clean()
	ship.clean()
	shots.clean()
	grapes.clean()
	splats.clean()
	
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

	wscores.update()

--	gui.update()
	ship.update()
	shots.update()
	grapes.update()
	splats.update()
	
	wscores.add(-1)

end

game.draw=function()
		
	sheets.get("imgs/gameback"):draw(1,720/2,480/2)

	splats.draw()
	ship.draw()
	grapes.draw()
	shots.draw()

--	gui.draw()

	wscores.draw("arcade2")

end

	return game
end
