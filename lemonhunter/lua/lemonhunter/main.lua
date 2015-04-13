-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math


--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(state,main)
	local oven=state
	local main=main or {}
	main.state=state
	
	local cake=state.cake
	local opts=state.opts
	local canvas=cake.canvas
	local font=canvas.font
	local flat=canvas.flat
	local gl=state.gl

	local skeys=oven.rebake("wetgenes.gamecake.spew.keys")
	local srecaps=oven.rebake("wetgenes.gamecake.spew.recaps")
	skeys.setup({max_up=1}) -- also calls srecaps.setup
		
	local layout=cake.layouts.create{}

	main.modname=M.modname
	
-- a substate
--	main.subs=require("wetgenes.gamecake.state").bake({
--		master=state,
--	})
	
	main.input={}
	main.input.volatile={}
	main.page="menu"
	main.wait=60
	
	main.last_score=0
	main.best_score=0
	
main.loads=function()

	state.cake.fonts.loads({1}) -- load 1st builtin font, a basic 8x8 font
	
	state.cake.images.loads({
	})
	
end
		
main.setup=function()
	local cake=state.cake

	main.loads()
	
	main.last=nil
	main.now=nil
	main.next=nil

-- preload everything
	state.rebake("lemonhunter.main_menu").loads()
	state.rebake("lemonhunter.main_play").loads()
	
	
	main.next=state.rebake("lemonhunter.main_menu")
	
	main.change()
end

function main.change()

-- handle state changes

	if main.next then
	
		if main.now and main.now.clean then
			main.now.clean()
		end
		
		main.last=main.now
		main.now=main.next
		main.next=nil
		
		if main.now and main.now.setup then
			main.now.setup()
		end
		
	end
	
end		

main.clean=function()

	if main.now and main.now.clean then
		main.now.clean()
	end

end

main.msg=function(m)
--	print(wstr.dump(m))

	if m.xraw and m.yraw then	-- we need to fix raw x,y numbers
		m.x,m.y=layout.xyscale(m.xraw,m.yraw)	-- local coords, 0,0 is center of screen
		m.x=m.x+(720/2)
		m.y=m.y+(480/2)
	end

	if skeys.msg(m) then m.skeys=true end -- flag this msg as handled by skeys

	if main.now and main.now.msg then
		main.now.msg(m)
	end
	
end

main.update=function()

	main.change()

	srecaps.step()
	
	for i,v in pairs(main.input.volatile) do
		main.input[i]=v 
	end
	main.input.volatile={}

	if main.now and main.now.update then
		main.now.update()
	end

end

main.draw=function()
	
	layout.viewport() -- did our window change?
	layout.project23d(opts.width,opts.height,1/4,opts.height*4)
	canvas.gl_default() -- reset gl state
		
	gl.ClearColor(pack.argb4_pmf4(0xf000))
	gl.Clear(gl.COLOR_BUFFER_BIT+gl.DEPTH_BUFFER_BIT)

	gl.MatrixMode(gl.PROJECTION)
	gl.LoadMatrix( layout.pmtx )

	gl.MatrixMode(gl.MODELVIEW)
	gl.LoadIdentity()
	gl.Translate(-opts.width/2,-opts.height/2,-opts.height*2) -- top left corner is origin

	gl.PushMatrix()
	
	font.set(cake.fonts.get(1)) -- default font
	font.set_size(32,0) -- 32 pixels high

	if main.now and main.now.draw then
		main.now.draw()
	end
	
	gl.Color(pack.argb4_pmf4(0xffff))

	font.set(cake.fonts.get(1))
	font.set_size(32,0)
	local s=main.last_score..""
	local sw=font.width(s)
	font.set_xy( 180-(sw/2)-60 ,8)
	font.draw(s)

	local s=main.best_score..""
	local sw=font.width(s)
	font.set_xy( 360+180-(sw/2)+60 ,8)
	font.draw(s)
	
		
	gl.PopMatrix()
	
end
		
	return main
end

