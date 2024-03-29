-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math


--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,main)
	main=main or {}
	main.modname=M.modname
	
	oven.modgame="gthang"
	
	local gl=oven.gl
	local cake=oven.cake
	local opts=oven.opts
	local canvas=cake.canvas
	local font=canvas.font
	local fonts=cake.fonts
	local flat=canvas.flat
	local sheets=cake.sheets

	local view=cake.views.create({
		parent=cake.views.get(),
		mode="full",
		vx=opts.width,
		vy=opts.height,
		vz=8192,
--		fov=0.5,
--		fov_scale2d=1/opts.height,
		fov=0,
	})

	local skeys=oven.rebake("wetgenes.gamecake.spew.keys")
	local srecaps=oven.rebake("wetgenes.gamecake.spew.recaps")
	skeys.setup({max_up=2}) -- also calls srecaps.setup

	local hud=oven.rebake(oven.modgame..".hud")
	
	local beep=oven.rebake(oven.modgame..".beep")
	
main.loads=function()

	oven.cake.fonts.loads({1,"Vera"}) -- load 1st builtin font, a basic 8x8 font
	
	sheets.loads_and_chops({
		{"imgs/tits",1,1,1/2,1/2},
		{"imgs/back01",1,1,1/2,1/2},
		{"imgs/back02",1,1,1/2,1/2},
		{"imgs/wave01",1,1,1/2,1/2},
		{"imgs/ships01",1/4,1/4,1/8,1/8},
		{"imgs/bullets01",1/4,1/4,1/8,1/8},
		{"imgs/explosion01",1,1,1/2,1/2},
		{"imgs/items01",1/4,1/4,1/8,1/8},
		{"imgs/gibs01",1/4,1/4,1/8,1/8},
		{"imgs/boss01",1,1,1/2,1/2},
		
	})
	
	fonts.loads({
		"Akashi",
	})
	
	beep.loads()
	
end
		
main.setup=function()

	main.loads()
	
	main.last=nil
	main.now=nil
	main.next=nil
	
	main.next=oven.rebake(oven.modgame..".main_menu")
--	main.next=oven.rebake(oven.modgame..".main_game")
	
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

	if oven.mods["wetgenes.gamecake.mods.escmenu"].show then return end -- pause

	if main.now and main.now.update then
		main.now.update()
	end

end

main.draw=function()
	
	cake.views.push_and_apply(view)
	canvas.gl_default() -- reset gl state
		
	gl.ClearColor(pack.argb4_pmf4(0xf000))
	gl.Clear(gl.COLOR_BUFFER_BIT+gl.DEPTH_BUFFER_BIT)

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

