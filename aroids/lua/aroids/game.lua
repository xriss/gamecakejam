-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math


module(...)
modname=(...)

bake=function(oven,game)
	local game=game or {}
	game.oven=oven
	oven.game=game
	
	game.modname=modname
	
-- a substate
--	game.subs=require("wetgenes.gamecake.oven").bake({
--		master=oven,
--	})
	
	game.input={}
	game.input.volatile={}

	local cake=oven.cake
	local opts=oven.opts
	local canvas=cake.canvas
	local font=canvas.font
	local flat=canvas.flat
	local gl=oven.gl
	local view=cake.views.create({
		parent=cake.views.get(),
		mode="clip",
		vx=opts.width,
		vy=opts.height,
		vz=opts.height*4,
		fov=0,
	})

	local skeys=oven.rebake("wetgenes.gamecake.spew.keys")
	local srecaps=oven.rebake("wetgenes.gamecake.spew.recaps")
	skeys.setup({max_up=1}) -- also calls srecaps.setup
	
	
--	local cards=state.rebake("dike.cards")
--	local stacks=state.rebake("dike.stacks")
--	local items=state.rebake("dike.items")
	
	
game.loads=function()

	oven.cake.fonts.loads({1}) -- load 1st builtin font, a basic 8x8 font
	
	oven.cake.images.loads({
	})
	
end
		
game.setup=function()

	game.loads()
	
	game.last=nil
	game.now=nil
	game.next=nil
	
	game.next=oven.rebake("aroids.game_menu")
	
	game.level=1
	game.score=0
	
	game.change()
end

function game.change()

-- handle state changes

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

--	if skeys.msg(m) then m.skeys=true end -- flag this msg as handled by skeys


	if m.class=="key" then
		local name
		if m.keyname=="up" then
			name="up"
		elseif m.keyname=="down" then
			name="down"
		elseif m.keyname=="left" then
			name="left"
		elseif m.keyname=="right" then
			name="right"
		elseif m.keyname=="space" or m.keyname=="control_l" then
			name="fire"
		end
		if name then
			if m.action==1 then
				game.input.volatile[name]=true
			end
			if m.action==-1 then
				game.input.volatile[name]=false
			end
		end
	end
	
--	game.js.msg(m)

	if game.now and game.now.msg then
		game.now.msg(m)
	end
	
end

game.update=function()

	game.change()
--	srecaps.step()

	for i,v in pairs(game.input.volatile) do
		game.input[i]=v 
	end
	game.input.volatile={}

	if game.now and game.now.update then
		game.now.update()
	end

--	game.play.update()

end

game.draw=function()
--print("draw")
	
	cake.views.push_and_apply(view)
	canvas.gl_default() -- reset gl state
		
	gl.ClearColor(pack.argb4_pmf4(0xf000))
	gl.Clear(gl.COLOR_BUFFER_BIT+gl.DEPTH_BUFFER_BIT)

	gl.MatrixMode(gl.MODELVIEW)
	gl.LoadIdentity()
--	gl.Translate(-opts.width/2,-opts.height/2,-opts.height*2) -- top left corner is origin

	gl.PushMatrix()
	
	font.set(cake.fonts:get(1)) -- default font
	font.set_size(32,0) -- 32 pixels high

	if game.now and game.now.draw then
		game.now.draw()
	end
	
--	gl.Color(pack.argb4_pmf4(0xffff)) -- draw drop shadow
--	cake.sheets:get("splash"):draw(1,0,0,0,1,1)
	
	gl.PopMatrix()

	cake.views.pop_and_apply()
	
end
		
	return game
end

