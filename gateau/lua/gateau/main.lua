-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local wsbox=require("wetgenes.sandbox")
local wzips=require("wetgenes.zips")

local tardis=require("wetgenes.tardis")	-- matrix/vector math


--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,main)
	main=main or {}
	main.modname=M.modname
	
	oven.modgame="gateau"
	
	local gl=oven.gl
	local cake=oven.cake
	local opts=oven.opts
	local canvas=cake.canvas
	local layouts=cake.layouts
	local font=canvas.font
	local flat=canvas.flat

	local layout=layouts.push_child{} -- we shall have a child layout to fiddle with

	local launch=oven.rebake("gateau.launch")

	local skeys=oven.rebake("wetgenes.gamecake.spew.keys")
	local srecaps=oven.rebake("wetgenes.gamecake.spew.recaps")
	skeys.setup({max_up=1}) -- also calls srecaps.setup
	
main.loads=function()

	oven.cake.fonts.loads({1}) -- load 1st builtin font, a basic 8x8 font
	
	local t=wzips.readfile("data/gateau/all.lua")
--print(t)
	main.dats=wsbox.lson(t)
	main.list={} for n,v in pairs(main.dats) do table.insert(main.list,v) end
	table.sort(main.list,function(a,b) return a.id < b.id end)
	
--print(wstr.dump(main.list))


	oven.cake.sheets.loads_and_chops({
		{"imgs/pimoroni_icon",1,1,0.5,0.5},
	})
	
	for i,v in ipairs(main.list) do
		oven.cake.sheets.loads_and_chops({
			{"gateau/"..v.id.."/icon",1,1,0.5,0.5},
			{"gateau/"..v.id.."/screen",1,1,0.5,0.5},
		})
	end
	
end
		
main.setup=function()

	main.loads()
	
	main.last=nil
	main.now=nil
	main.next=nil
	
	main.next=oven.rebake(oven.modgame..".main_menu")
	
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
		m.x=m.x+(opts.width/2)
		m.y=m.y+(opts.height/2)
	end

	if skeys.msg(m) then m.skeys=true end -- flag this msg as handled by skeys

	if main.now and main.now.msg then
		main.now.msg(m)
	end
	
end

main.update=function()

	main.change()
	srecaps.step()

	if oven.mods["wetgenes.gamecake.mods.escmenu"].show then return end -- pause

	if main.now and main.now.update then
		main.now.update()
	end

end

main.draw=function()
	
	layout.apply( opts.width,opts.height,1/4,opts.height*4 )
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
	
end
		
	return main
end
