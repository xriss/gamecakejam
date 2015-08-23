-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math

local function dprint(a) print(wstr.dump(a)) end

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,stats)
	local stats=stats or {}
	stats.oven=oven
	
	stats.modname=M.modname

	local cake=oven.cake
	local opts=oven.opts
	local canvas=cake.canvas
	local font=canvas.font
	local flat=canvas.flat
	local gl=oven.gl
	local sheets=cake.sheets
	

	local gui=oven.rebake(oven.modgame..".gui")
	local main=oven.rebake(oven.modgame..".main")
	local play=oven.rebake(oven.modgame..".main_play")
--	local beep=oven.rebake(oven.modgame..".beep")

	local chars=oven.rebake(oven.modgame..".chars")
	local mon=oven.rebake(oven.modgame..".mon")
	
	local console=oven.rebake("wetgenes.gamecake.mods.console")

stats.loads=function()

end
		
stats.setup=function()

	stats.loads()

end

stats.clean=function()

	mon.clean()
	
end

stats.msg=function(m)

--	print(wstr.dump(m))

end

stats.update=function()


end

stats.draw=function()

	stats.px=16
	stats.py=32+48*3

	stats.hx=200
	stats.hy=600-stats.py-16

	gl.PushMatrix()
	gl.Translate(stats.px,stats.py,0)
	
	gl.Color(pack.argb4_pmf4(0xf010))
	flat.quad(0,0,stats.hx,stats.hy)
	gl.Color(1,1,1,1)
	
	font.set(cake.fonts.get("slkscr")) -- default font
	font.set_size(24,0)

	local x,y=0,0
	local fs=24
	
	local it=mon
	
	font.set_xy(x,y) font.draw(" HIT = "..it.hit) y=y+fs
	font.set_xy(x,y) font.draw(" ATK = "..it.atk) y=y+fs
	font.set_xy(x,y) font.draw(" DEF = "..it.def) y=y+fs
	font.set_xy(x,y) font.draw(" SPD = "..it.spd) y=y+fs
	
	
	
	gl.PopMatrix()
	gl.Color(1,1,1,1)

end

	return stats
end
