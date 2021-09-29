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
	local sheets=cake.sheets
	local opts=state.opts
	local canvas=cake.canvas
	local font=canvas.font
	local flat=canvas.flat
	local gl=state.gl
	
	local skeys=oven.rebake("wetgenes.gamecake.spew.keys")
	local srecaps=oven.rebake("wetgenes.gamecake.spew.recaps")
	skeys.setup({max_up=1}) -- also calls srecaps.setup
	
	local view=cake.views.create({
		parent=cake.views.get(),
		mode="full",
		vx=opts.width,
		vy=opts.height,
		vz=opts.height*4,
		fov=0,
	})
	
	main.modname=M.modname
	
	local wscores=state.rebake("wetgenes.gamecake.spew.scores")
	wscores.setup(1)
	
-- a substate
--	main.subs=require("wetgenes.gamecake.oven").bake({
--		master=state,
--	})
	
	main.input={}
	main.input.volatile={}
	main.page="menu"
	main.wait=60
	
	
	
main.loads=function()

	cake.fonts.loads({1,"Vera"}) -- load 1st builtin font, a basic 8x8 font
	
	state.cake.images.loads({
	})
	
	sheets.loads_and_chops{
		{"imgs/ship",1,1,0.5,0.5},
		{"imgs/shoot",1,1,0.5,0.5},
		{"imgs/grape",1,1,0.5,0.5},
		{"imgs/splat",1,1,0.5,0.5},
		
		{"imgs/cured",1,1,0.5,0.5},
		{"imgs/nocure",1,1,0.5,0.5},
		{"imgs/title",1,1,0.5,0.5},
		{"imgs/gameback",1,1,0.5,0.5},
	}
		
end
		
main.setup=function()
	local cake=state.cake

	main.loads()
	
	main.last=nil
	main.now=nil
	main.next=nil
	
	main.next=state.rebake("cloids.main_menu")
	
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

	view.msg(m) -- fix mouse coords
	
--	if skeys.msg(m) then m.skeys=true end -- flag this msg as handled by skeys

	if main.now and main.now.msg then
		main.now.msg(m)
	end
	
end

main.update=function()

	main.change()

--	srecaps.step()
	
	for i,v in pairs(main.input.volatile) do
		main.input[i]=v 
	end
	main.input.volatile={}

	if main.now and main.now.update then
		main.now.update()
	end

end

main.draw=function()
	
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

	if main.now and main.now.draw then
		main.now.draw()
	end
	
	gl.PopMatrix()
	
	cake.views.pop_and_apply()
end
		
	return main
end

