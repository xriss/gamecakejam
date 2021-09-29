-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,main)
	local main=main or {}
	
	local cake=oven.cake
	local opts=oven.opts
	local canvas=cake.canvas
	local sheets=cake.sheets
	
	local font=canvas.font
	local flat=canvas.flat

	local gl=oven.gl

	local view=cake.views.create({
		parent=cake.views.get(),
		mode="full",
		vx=opts.width,
		vy=opts.height,
		vz=opts.height*4,
		fov=0,
	})

	main.modname=M.modname
	
	local skeys=oven.rebake("wetgenes.gamecake.spew.keys")
	local srecaps=oven.rebake("wetgenes.gamecake.spew.recaps")
	skeys.setup({max_up=1,swipe=true}) -- also calls srecaps.setup

	local scores=oven.rebake("wetgenes.gamecake.spew.scores").setup(1)

	local wscores=oven.rebake("wetgenes.gamecake.spew.scores")
	wscores.setup(1)

	local beep=oven.rebake("hunted.beep")

main.loads=function()

	beep.loads()

	oven.cake.fonts.loads({1,"Vera"}) -- load 1st builtin font, a basic 8x8 font
--	oven.cake.images.loads({
--	})
	sheets.loads_and_chops{
		{"imgs/floor",1,1,0.5,0.5},
		{"imgs/block",1,1,0.5,0.5},
		{"imgs/egg1",1,1,0.5,0.5},
		{"imgs/egg2",1,1,0.5,0.5},
		{"imgs/hero",1,1,0.5,0.5},
		{"imgs/herodie",1,1,0.5,0.5},
		{"imgs/alien",1,1,0.5,0.5},
		{"imgs/aliendie",1,1,0.5,0.5},
		{"imgs/title",1,1,0.5,0.5},
		{"imgs/end",1,1,0.5,0.5},
	}
	
end
		
main.setup=function()

	main.loads()
	
	main.last=nil
	main.now=nil
	main.next=nil
	
	print(opts[2])
	if opts[2]=="game" then
		main.next=oven.rebake("hunted.main_game")
	else
		main.next=oven.rebake("hunted.main_menu")
	end
	main.change()
end

function main.change()

-- handle oven changes

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
	
--	skeys.msg(m) -- translate into controls

	if main.now and main.now.msg then
		main.now.msg(m)
	end
	
end

main.update=function()

	main.change()
	
--	srecaps.step()
	
	if oven.mods["wetgenes.gamecake.mods.escmenu"].show then return end -- pause

--	if recaps.get("fire_set") then print("fire") end

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
	gl.Translate(-opts.width/2,-opts.height/2,-opts.height*2) -- top left corner is origin

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

