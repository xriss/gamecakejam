-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math


--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,game)
	local game=game or {}
	game.oven=oven
	oven.game=game
	
	local cake=oven.cake
	local opts=oven.opts
	local canvas=cake.canvas
	local font=canvas.font
	local flat=canvas.flat
	local gl=oven.gl

	local skeys=oven.rebake("wetgenes.gamecake.spew.keys")
	local srecaps=oven.rebake("wetgenes.gamecake.spew.recaps")
	skeys.setup({max_up=1}) -- also calls srecaps.setup
	
	local view=cake.views.create({
		parent=cake.views.get(),
		mode="full",
		vx=opts.width,
		vy=opts.height,
		vz=opts.height*4,
		fov=1/4,
	})

	game.modname=M.modname
		
	game.input={}
	game.input.volatile={}
	game.page="menu"
	game.wait=60
	
	game.last_score=0
	game.best_score=0
	
	game.gui=oven.rebake("gagano.gui")

game.loads=function()

	cake.fonts.loads({1,"Vera"}) -- load 1st builtin font, a basic 8x8 font
	
	oven.cake.images.loads({
	})
	
end
		
game.setup=function()
	local cake=oven.cake
	
	game.loads()
	
	game.last=nil
	game.now=nil
	game.next=nil
	
	game.gui.setup()
	
	game.next=oven.rebake("gagano.game_menu")
--	game.next=oven.rebake("gagano.game_play")
	
	game.change()
end

function game.change()

-- handle oven changes

	if game.next then
	
		if game.now and game.now.clean then
			game.now.clean()
		end
		
		game.last=game.now
		game.now=game.next
		game.next=nil
		
		if game.now and game.now.setup then
			game.now.setup()
		end
		
	end
	
end		

game.clean=function()

	if game.now and game.now.clean then
		game.now.clean()
	end

end

game.msg=function(m)
--	print(wstr.dump(m))

	view.msg(m) -- fix mouse coords
	
	if skeys.msg(m) then m.skeys=true end -- flag this msg as handled by skeys

	if game.now and game.now.msg then
		game.now.msg(m)
	end
	
end

game.update=function()

	game.change()
	srecaps.step()
	for i,v in pairs(game.input.volatile) do
		game.input[i]=v 
	end
	game.input.volatile={}

	if game.now and game.now.update then
		game.now.update()
	end

end

game.draw=function()
	
	cake.views.push_and_apply(view)
	canvas.gl_default() -- reset gl state
		
	gl.ClearColor(pack.argb4_pmf4(0xf000))
	gl.Clear(gl.COLOR_BUFFER_BIT+gl.DEPTH_BUFFER_BIT)

	gl.MatrixMode(gl.MODELVIEW)
	gl.LoadIdentity()
	gl.Translate(-opts.width/2,-opts.height/2,-opts.height*2) -- top left corner is origin

	gl.PushMatrix()
	
	font.set(cake.fonts.get(1)) -- default font
	font.set_size(32,0) -- 32 pixels high

	if game.now and game.now.draw then
		game.now.draw()
	end
	
	gl.PopMatrix()
	
	cake.views.pop_and_apply()

end
		
	return game
end

