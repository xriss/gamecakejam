-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math


module(...)


bake=function(state,game)
	game=game or {}
	game.state=state
	
	game.input={}
	game.input.volatile={}
	game.page="menu"
	game.wait=60

	local cake=state
	local opts=cake.opts
	local cake=state.cake
	local view=cake.views.create({
		parent=cake.views.get(),
		mode="clip",
		vx=opts.width,
		vy=opts.height,
		vz=opts.height*4,
		fov=0,
	})
	
	local oven=state
	local skeys=oven.rebake("wetgenes.gamecake.spew.keys").setup(1)
	local srecaps=oven.rebake("wetgenes.gamecake.spew.recaps").setup(1)
	local sscores=oven.rebake("wetgenes.gamecake.spew.scores").setup(1)
	
game.loads=function()

	state.cake.fonts.loads({1}) -- load 1st builtin font, a basic 8x8 font
	
	state.cake.images.loads({
		"splash",
		"back",
		"cone",
		"clouds",
		"plane1",
		"plane2",
		"plane3",
		"plane4",
		"pew",
		"boom",
	})

end
		
game.setup=function()
	local cake=state.cake

	game.loads()

	cake.sheets.createimg("splash"):chop(1,1)
	cake.sheets.createimg("back"):chop(1,1)
	cake.sheets.createimg("clouds"):chop(1,1)
	cake.sheets.createimg("cone"):chop(1,1)
	cake.sheets.createimg("plane1"):chop(1,1,0.5,0.5)
	cake.sheets.createimg("plane2"):chop(1,1,0.5,0.5)
	cake.sheets.createimg("plane3"):chop(1,1,0.5,0.5)
	cake.sheets.createimg("plane4"):chop(1,1,0.5,0.5)
	cake.sheets.createimg("boom"):chop(1,1,0.5,0.5)
	cake.sheets.createimg("pew"):chop(1,1,0.5,0.5)
	
end

game.clean=function()

end

game.msg=function(m)
--	print(wstr.dump(m))
		
	game.js.msg(m)
	
end

game.update=function()

--	srecaps.step()

	for i,v in pairs(game.input.volatile) do
		game.input[i]=v 
	end
	game.input.volatile={}

	if game.page=="menu" then

		if ( game.input.p1_fire or game.input.p2_fire or game.input.p3_fire or game.input.p4_fire ) and game.wait<=0 then
			game.page="play"
			game.play.reset()
		end
	else
	
		game.play.update()
	end
end

game.draw=function()
--print("draw")
	local cake=state.cake
	local opts=state.opts
	local canvas=cake.canvas
	local font=canvas.font
	local flat=canvas.flat
	local gl=state.gl
	
	cake.views.push_and_apply(view)
	canvas.gl_default() -- reset gl state
		
	gl.ClearColor(pack.argb4_pmf4(0xf000))
	gl.Clear(gl.COLOR_BUFFER_BIT+gl.DEPTH_BUFFER_BIT)

	gl.MatrixMode(gl.MODELVIEW)
	gl.LoadIdentity()
--	gl.Translate(-opts.width/2,-opts.height/2,-opts.height*2) -- top left corner is origin

	gl.PushMatrix()
	
	font.set(cake.fonts.get(1)) -- default font
	font.set_size(32,0) -- 32 pixels high
	
	if game.page=="menu" then

		gl.Color(pack.argb4_pmf4(0xffff)) -- draw drop shadow
		cake.sheets.get("splash"):draw(1,320,240,0,640,480)

		game.play.drawscore()
		
		game.wait=game.wait-1
	
	else
	
		if game.play.draw() >=10 then game.page="menu" game.wait=60 end
	end
	
	gl.PopMatrix()

	cake.views.pop_and_apply()
	
end

	require("quip.js").bake(game)

	require("quip.play").bake(game)

	return game
end

