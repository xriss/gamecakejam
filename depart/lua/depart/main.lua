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
	
	oven.modgame="depart"
	
	local gl=oven.gl
	local cake=oven.cake
	local opts=oven.opts
	local canvas=cake.canvas
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

	local skeys=oven.rebake("wetgenes.gamecake.spew.keys")
	local srecaps=oven.rebake("wetgenes.gamecake.spew.recaps")
	local sscores=oven.rebake("wetgenes.gamecake.spew.scores")
	
	local serv=oven.rebake(oven.modgame..".serv")
	local bikes=oven.rebake(oven.modgame..".bikes")
	local players=oven.rebake(oven.modgame..".players")
	
	local beep=oven.rebake(oven.modgame..".beep")

	skeys.setup(1)
	srecaps.setup(1)
	sscores.setup(1)
	
main.loads=function()

	cake.fonts.loads({1,"Vera"}) -- load 1st builtin font, a basic 8x8 font
	
	cake.sheets.loads_and_chops{
		{"imgs/title",1,1,0.5,0.5},
		{"imgs/sky",1,1,0.5,0.5},
		{"imgs/road",1,1,0.5,0.5},
		{"imgs/trees1",1,1,0.5,0.5},
		{"imgs/trees2",1,1,0.5,0.5},
		{"imgs/bikes",1/4,1/4,1/8,1/8},
		{"imgs/bots",1/4,1/4,1/8,1/8},
		{"imgs/items",1/4,1/4,1/8,1/8},
	}
	
	beep.loads()
	
end
		
main.setup=function()

	main.loads()
	
	main.last=nil
	main.now=nil
	main.next=nil
	
	main.next=oven.rebake(oven.modgame..".main_menu")
	
	main.change()
	
	bikes.setup()
	players.setup()
	serv.setup() -- start a web server on another thread...

	beep.stream()

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
	
	serv.update() -- check for socket data
	players.update()

	main.change()
	
--	srecaps.step()

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

