-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math


module(...)
modname=(...)

bake=function(state,game)
	local game=game or {}
	game.state=state
	state.game=game
	
	game.modname=modname
	
-- a substate
	game.subs=require("wetgenes.gamecake.state").bake({
		master=state,
	})
	
	game.input={}
	game.input.volatile={}
	
	
--	local cards=state:rebake("dike.cards")
--	local stacks=state:rebake("dike.stacks")
--	local items=state:rebake("dike.items")
	
	
game.loads=function(state)

	state.cake.fonts:loads({1}) -- load 1st builtin font, a basic 8x8 font
	
	state.cake.images:loads({
	})
	
end
		
game.setup=function(state)
	local cake=state.cake

	game.loads(state)
	
	game.last=nil
	game.now=nil
	game.next=nil
	
	game.next=state:rebake("aroids.game_menu")
	
	
	game.change()
end

function game.change()

-- handle state changes

	if game.next then
	
		if game.now and game.now.clean then
			game.now.clean(state)
		end
		
		game.last=game.now
		game.now=game.next
		game.next=nil
		
		if game.now and game.now.setup then
			game.now.setup(state)
		end
		
	end
	
end		

game.clean=function(state)

	if game.now and game.now.clean then
		game.now.clean(state)
	end

end

game.msg=function(state,m)
--	print(wstr.dump(m))
	
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
		elseif m.keyname=="space" then
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
		game.now.msg(state,m)
	end
	
end

game.update=function(state)

	game.change()

	for i,v in pairs(game.input.volatile) do
		game.input[i]=v 
	end
	game.input.volatile={}

	if game.now and game.now.update then
		game.now.update(state)
	end

--	game.play.update(state)

end

game.draw=function(state)
--print("draw")
	local cake=state.cake
	local opts=state.opts
	local canvas=state.canvas
	local font=canvas.font
	local flat=canvas.flat
	local gl=cake.gl
	
	canvas:viewport() -- did our window change?
	canvas:project23d(opts.width,opts.height,1/4,opts.height*4)
	canvas:gl_default() -- reset gl state
		
	gl.ClearColor(pack.argb4_pmf4(0xf000))
	gl.Clear(gl.COLOR_BUFFER_BIT+gl.DEPTH_BUFFER_BIT)

	gl.MatrixMode(gl.PROJECTION)
	gl.LoadMatrix( canvas.pmtx )

	gl.MatrixMode(gl.MODELVIEW)
	gl.LoadIdentity()
	gl.Translate(-opts.width/2,-opts.height/2,-opts.height*2) -- top left corner is origin

	gl.PushMatrix()
	
	font:set(cake.fonts:get(1)) -- default font
	font:set_size(32,0) -- 32 pixels high

	if game.now and game.now.draw then
		game.now.draw(state)
	end
	
--	gl.Color(pack.argb4_pmf4(0xffff)) -- draw drop shadow
--	cake.sheets:get("splash"):draw(1,0,0,0,1,1)
	
	gl.PopMatrix()
	
end
		
	return game
end

