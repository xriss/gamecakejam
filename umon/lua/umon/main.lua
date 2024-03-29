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
	
	oven.modgame="umon"
	
	local gl=oven.gl
	local cake=oven.cake
	local opts=oven.opts
	local canvas=cake.canvas
	local images=cake.images
	local font=canvas.font
	local flat=canvas.flat

	local view=cake.views.create({
		parent=cake.views.get(),
		mode="full",
		vx=opts.width,
		vy=opts.height,
		vz=opts.height*4,
		fov=0,
	})

	local skeys=oven.rebake("wetgenes.gamecake.spew.keys").setup(1)
	local srecaps=oven.rebake("wetgenes.gamecake.spew.recaps").setup(1)
	local sscores=oven.rebake("wetgenes.gamecake.spew.scores").setup(1)

	local draw_screen=oven.rebake(oven.modgame..".draw_screen")
	local beep=oven.rebake(oven.modgame..".beep")
	
main.loads=function()

	oven.cake.fonts.loads({1}) -- load 1st builtin font, a basic 8x8 font
	oven.cake.fonts.loads({"slkscr"}) 
	
	images.TEXTURE_MIN_FILTER=gl.NEAREST
	images.TEXTURE_MAG_FILTER=gl.NEAREST
	oven.cake.sheets.loads_and_chops({

-- pixel style

		{"imgs/mon_01",1/4,1/4,0.5/4,0.5/4},
		{"imgs/mon_02",1/4,1/4,0.5/4,0.5/4},
		{"imgs/char_01",1/8,1/16,0.5/8,0.5/16},		
		{"imgs/icon_01",1/4,1/4,0.5/4,0.5/4},		
		{"imgs/butt_01",1/4,1/2,0.5/4,0.5/2},		
		{"imgs/world_01",1/1,1/3,0.5/1,0.5/3},		
		{"imgs/rest_01",1/1,1/3,0.5/1,0.5/3},		

	})
	images.TEXTURE_MIN_FILTER=nil
	images.TEXTURE_MAG_FILTER=nil

	oven.cake.sheets.loads_and_chops({

-- smooth style

		{"imgs/overlay1",1/1,1/1,0.5/1,0.5/1},		
		{"imgs/overlay2",1/1,1/1,0.5/1,0.5/1},		


		{"imgs/map_01",1/1,1/1,0.5/1,0.5/1},		
		{"imgs/splash",1/1,1/1,0.5/1,0.5/1},		
		{"imgs/title_back",1/1,1/1,0.5/1,0.5/1},		
		{"imgs/play_back",1/1,1/1,0.5/1,0.5/1},		

	})
	
	beep.loads()

end
		
main.setup=function()

	main.loads()
	
	main.last=nil
	main.now=nil
	main.next=nil
	
	draw_screen.setup()

	main.next=oven.rebake(oven.modgame..".main_menu")
--	main.next=oven.rebake(oven.modgame..".main_play")
	
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

--	srecaps.step()
	
	main.change()

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
	
--	cake.views.pop_and_apply()

end
		
	return main
end

