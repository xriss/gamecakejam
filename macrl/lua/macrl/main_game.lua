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

	local sheet=cake.sheets.get("imgs/tiles")
	
--	local t=yarn_canvas.tostring({table=true}) -- we want a table of strings
	
	font.set(cake.fonts.get(1))
	font.set_size(16,0)
	gl.Color(pack.argb4_pmf4(0xf5f5))
	gl.Color(pack.argb4_pmf4(0xf0a0))

	font.set(cake.fonts.get(1))
	font.set(cake.fonts.get("Vera")) -- may fail, if so it will not change nothing

	sheet:batch_start()

	-- create default blank cells

	local t={}
	
	if basket.level then
		for y=0,basket.level.yh-1 do
			for x=0,basket.level.xh-1 do
				local i=x+y*basket.level.xh
				local v=basket.level.cells[i]
				local f
				if v then
					v.image(t) -- writes into t

					if t.asc==yarn_ascii.hash then
						f=2
					elseif t.asc==yarn_ascii.dot then
						f=3
					elseif t.asc==yarn_ascii.at then
						f=4
					end
					
					if f then
						sheet:draw(f,x*16+8,y*16+8,0,16,16)
					end
				end
			end
		end
	end
	
	sheet:batch_stop()
	sheet:batch_draw()


	-- display a menu

	if yarn_menu.display then

		local top=yarn_menu.stack[#yarn_menu.stack]

		gl.Color(pack.argb4_pmf4(0xf008))
		flat.quad(0,0,640,(#yarn_menu.display+4)*16)

		gl.Color(pack.argb4_pmf4(0xf000))
		flat.quad(0+16,0+16,640-16,(#yarn_menu.display+4-1)*16)

		gl.Color(pack.argb4_pmf4(0xffff))
		
		if top.title then
			local w=font.width(top.title)
			font.set_xy(320-w/2,0)
			font.draw(top.title)
		end
		
		for i,v in ipairs(yarn_menu.display) do
			font.set_xy(16*2,(i+1)*16)
			font.draw(v.s)
		end

		font.set_xy(16*1,(yarn_menu.cursor+1)*16)
		font.draw(">")
		
	end

end

	return game
end
