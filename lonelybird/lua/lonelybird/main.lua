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
	
	oven.modgame="lonelybird"
	
	local gl=oven.gl
	local cake=oven.cake
	local opts=oven.opts
	local canvas=cake.canvas
	local font=canvas.font
	local flat=canvas.flat
	local sheets=cake.sheets

	local view=cake.views.create({
		parent=cake.views.get(),
		mode="full",
		vx=opts.width,
		vy=opts.height,
		vz=opts.height*4,
		fov=0,
	})

	local sscores=oven.rebake("wetgenes.gamecake.spew.scores").setup(1)

	local skeys=oven.rebake("wetgenes.gamecake.spew.keys")
	local srecaps=oven.rebake("wetgenes.gamecake.spew.recaps")
	skeys.setup({max_up=1}) -- also calls srecaps.setup


	local beep=oven.rebake(oven.modgame..".beep")

	
main.loads=function()

	oven.cake.fonts.loads({1,"Vera"}) -- load 1st builtin font, a basic 8x8 font

	oven.cake.fonts.loads({"awesome"})
	
	sheets.loads_and_chops({
		{"imgs/postcode",1/8,1/3,0,0},		
		{"imgs/back",1,1,1/2,1/2},		
		{"imgs/day",1,1,1/2,1/2},		
		{"imgs/txt",1,1,1/2,1/2},
		{"imgs/tap",1,1,1/2,1/2},
		{"imgs/gameover",1,1,1/2,1/2},
		{"imgs/night",1,1,1/2,1/2},
		{"imgs/ground",1,1,1/2,1/2},		
		{"imgs/title",1,1,1/2,1/2},		
		{"imgs/graves",1/12,1/2,1/24,1/4},		
		{"imgs/bird",1/4,1,1/8,1/2},		
	})


	oven.cake.images.loads({
	})
	
	beep.loads()


end
		
main.setup=function()

	main.loads()
	
	main.last=nil
	main.now=nil
	main.next=nil
	
	local csv=oven.rebake(oven.modgame..".csv")
	csv.setup()

--	main.next=oven.rebake(oven.modgame..".main_menu")
	main.next=oven.rebake(oven.modgame..".main_intro")
	
	main.change()
	
	main.frame=0
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

	main.frame=(main.frame+1)%60

	main.change()

--	srecaps.step()

	if oven.mods["wetgenes.gamecake.mods.escmenu"].show then return end -- pause

	if main.now and main.now.update then
		main.now.update()
	end

end

-- enable/disable screen clipping
main.clip_on=function()
--	layout.apply( opts.width,opts.height,1/4,opts.height*4,"clip")
end

main.clip_off=function()
--	layout.apply( opts.width,opts.height,1/4,opts.height*4)
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

