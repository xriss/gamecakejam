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
	local layout=cake.layouts.create{}
	
	local font=canvas.font
	local flat=canvas.flat

	local gl=oven.gl

	main.modname=M.modname
		
	
	local keys=oven.rebake("wetgenes.gamecake.spew.keys").setup(1)
	local recaps=oven.rebake("wetgenes.gamecake.spew.recaps").setup(1)
	local scores=oven.rebake("wetgenes.gamecake.spew.scores").setup(1)

	local wscores=oven.rebake("wetgenes.gamecake.spew.scores")
	wscores.setup(1)

	local beep=oven.rebake("dmazed.beep")

main.loads=function()

	beep.loads()

	oven.cake.fonts.loads({1}) -- load 1st builtin font, a basic 8x8 font
--	oven.cake.images.loads({
--	})
	sheets.loads_and_chops{
		{"imgs/walls",1/6,1/4,0,0},
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
		{"imgs/items",1/2,1/2,1/4,1/4},
	}
	
end
		
main.setup=function()

	main.loads()
	
	main.last=nil
	main.now=nil
	main.next=nil
	
	print(opts[2])
	if opts[2]=="game" then
		main.next=oven.rebake("dmazed.main_game")
	else
		main.next=oven.rebake("dmazed.main_menu")
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

	if m.xraw and m.yraw then	-- we need to fix raw x,y numbers
		m.x,m.y=layout.xyscale(m.xraw,m.yraw)	-- local coords, 0,0 is now center of screen
		m.x=m.x+(opts.width/2)
		m.y=m.y+(opts.height/2)
	end
	
	keys.msg(m) -- translate into controls

	if main.now and main.now.msg then
		main.now.msg(m)
	end
	
end

main.update=function()

	main.change()
	
	recaps.step()
	
--	if recaps.get("fire_set") then print("fire") end

	if main.now and main.now.update then
		main.now.update()
	end

end

main.draw=function()
	
	canvas.gl_default() -- reset gl state

	layout.viewport() -- select fullscreen
	
	gl.ClearColor(pack.argb4_pmf4(0xf000))
	gl.Clear(gl.COLOR_BUFFER_BIT+gl.DEPTH_BUFFER_BIT)

	layout.viewport(opts.width,opts.height) -- set clip area
	layout.project23d(opts.width,opts.height,1/4,opts.height*4) -- build projection

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
	
	gl.PopMatrix()
	
end
		
	return main
end

