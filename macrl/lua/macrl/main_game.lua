-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math

local function dprint(a) print(wstr.dump(a)) end

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,game)
	game=game or {}
	game.modname=M.modname

	local gl=oven.gl
	local cake=oven.cake
	local opts=oven.opts
	local canvas=cake.canvas
	local font=canvas.font
	local flat=canvas.flat
	
	local gui=oven.rebake(oven.modgame..".gui")
	local main=oven.rebake(oven.modgame..".main")
	local basket=main.basket
	local yarn_canvas=basket.rebake("yarn.canvas")
	local yarn_menu=basket.rebake("yarn.menu")
	local yarn_ascii=basket.rebake("yarn.ascii")
	local yarn_levels=basket.rebake("yarn.levels")
	local code=basket.rebake(oven.modgame..".rules.code")

game.loads=function()

end
		
game.setup=function()

	game.loads()

end

game.clean=function()

end

game.msg=function(m)

--	print(wstr.dump(m))

	basket.msg(m)
	
end

game.update=function()

	yarn_menu.update()

end

game.draw=function()

	local sheet0=cake.sheets.get("imgs/tiles.6x6")
	local sheet1=cake.sheets.get("imgs/tiles")
	
--	local t=yarn_canvas.tostring({table=true}) -- we want a table of strings
	
	font.set(cake.fonts.get(1))
	font.set_size(16,0)
	gl.Color(pack.argb4_pmf4(0xf5f5))
	gl.Color(pack.argb4_pmf4(0xf0a0))

	gl.Color(pack.argb4_pmf4(0xffff))

	font.set(cake.fonts.get(1))
	font.set(cake.fonts.get("Vera")) -- may fail, if so it will not change nothing

	sheet0:batch_start()
	sheet1:batch_start()

	-- create default blank cells

	local t={}
	
	if basket.level then
		for y=0,basket.level.yh-1 do
			for x=0,basket.level.xh-1 do
				local i=x+y*basket.level.xh
				local v=basket.level.cells[i]
				local f
				if v then
					v.img(t) -- writes into t

					if t.img=="colson" then
						f=4
					elseif t.img=="burke" then
						f=4
					elseif t.img=="gantner" then
						f=4
					elseif t.img=="tech1" then
						f=4
					elseif t.img=="tech2" then
						f=4
					elseif t.img=="tech3" then
						f=4
					elseif t.img=="rubble" then
						f=7
					elseif t.img=="console" then
						f=9
					elseif t.img=="helipad" then
						f=10
					elseif t.img=="vent" then
						f=11
					elseif t.asc==yarn_ascii.hash then
						f=2
					elseif t.asc==yarn_ascii.dot then
						f=3
					elseif t.asc==yarn_ascii.at then
						f=20
					end
					
					if f then
						sheet0:draw(f,x*16+8,y*16+8,0,16,16)
					end
				end
			end
		end
	end
	
	sheet0:batch_stop()
	sheet0:batch_draw()

	sheet1:batch_stop()
	sheet1:batch_draw()

	-- display a menu

	if yarn_menu.display then

		local xw=16
		local ys=((480-32)-((#yarn_menu.display+4)*16))/2
		local top=yarn_menu.stack[#yarn_menu.stack]

		gl.Color(pack.argb4_pmf4(0xf008))
		flat.quad(0+160-xw-24,ys+0-8,640-160+xw+24,ys+(#yarn_menu.display+4)*16+8)

		gl.Color(pack.argb4_pmf4(0xf000))
		flat.quad(0+160-xw,ys+0+16,640-160+xw,ys+(#yarn_menu.display+4-1)*16)

		gl.Color(pack.argb4_pmf4(0xffff))
		
		if top.title then
			local w=font.width(top.title)
			font.set_xy(320-w/2,ys+0-6)
			font.draw(top.title)
		end
		
		for i,v in ipairs(yarn_menu.display) do
			font.set_xy(160-xw+16*2,ys+(i+1)*16-4)
			font.draw(v.s)
		end

		font.set_xy(160-xw+16*1,ys+(yarn_menu.cursor+1)*16-4)
		font.draw(">")
		
	end

	local s=basket.get_msg()
	local w=font.width(s)
	font.set_xy(320-w/2,480-32)
	font.draw(s)

	local w=basket.player.isholding("watch")
	if w and w.is.equiped then
		local s=code.time_remaining().." remaining"
		local w=font.width(s)
		gl.Color(pack.argb4_pmf4(0xf888))
		font.set_xy(320-w/2,480-16)
		font.draw(s)
	end
end

	return game
end
