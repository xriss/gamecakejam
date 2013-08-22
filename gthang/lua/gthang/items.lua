-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math

local function dprint(a) print(wstr.dump(a)) end

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,items)
	local items=items or {}
	items.oven=oven
	
	items.modname=M.modname

	local cake=oven.cake
	local opts=oven.opts
	local canvas=cake.canvas
	local font=canvas.font
	local flat=canvas.flat
	local gl=oven.gl
	local sheets=cake.sheets
	
	local sgui=oven.rebake("wetgenes.gamecake.spew.gui")

	local gui=oven.rebake(oven.modgame..".gui")
	local main=oven.rebake(oven.modgame..".main")
--	local beep=oven.rebake(oven.modgame..".beep")
	local enemies=oven.rebake(oven.modgame..".enemies")
	local ship=oven.rebake(oven.modgame..".ship")
	local explosions=oven.rebake(oven.modgame..".explosions")
	local beep=oven.rebake(oven.modgame..".beep")

	local sscores=oven.rebake("wetgenes.gamecake.spew.scores")
	local srecaps=oven.rebake("wetgenes.gamecake.spew.recaps")
	local console=oven.rebake("wetgenes.gamecake.mods.console")

	local layout=cake.layouts.create{}

	local item={}


	
item.setup=function(it,opt)

	it.px=opt.px or 256
	it.py=opt.py or 128
	it.rz=0

	it.vx=opt.vx or 0
	it.vy=opt.vy or 0
	
	it.flava=opt.flava or "splitshot"

end

item.clean=function(it)

end

item.update=function(it)

	it.px=it.px+it.vx
	it.py=it.py+it.vy
	
	if it.py>768 	then it.flava="dead" return end
	if it.py<0 		then it.flava="dead" return end
	if it.px>512 	then it.flava="dead" return end
	if it.px<0 		then it.flava="dead" return end
	
	local dx=it.px-ship.px
	local dy=it.py-ship.py
	
	if dx*dx+dy*dy<=48*48 then
		ship.power=it.flava
		sscores.add(enemies.level*1000)
		beep.play("power")
		it.flava="dead"
		return
	end
	
end

item.draw=function(it)
	local image=sheets.get("imgs/power01")
	
	if it.flava=="splitshot" then
		gl.Color(1,0,0,1)
	end
	if it.flava=="singleshot" then
		gl.Color(0,1,0,1)
	end
	if it.flava=="sureshot" then
		gl.Color(0,0,1,1)
	end

	image:draw(1,it.px,it.py,it.rz,64,64)
	
end


items.loads=function()

end
		
items.setup=function()

items.tab = {}


end

items.clean=function()

	for i,v in ipairs(items.tab) do
		item.clean(v)
	end

end

items.msg=function(m)

--	print (wstr.dump(m))
	

end

items.update=function()
		
	for i=#items.tab,1,-1 do
		local it=items.tab[i]
		item.update(it)
		if it.flava=="dead" then
			table.remove(items.tab,i)
		end
	end
	
end

items.draw=function()

	for i,v in ipairs(items.tab) do
		item.draw(v)
	end
	
	gl.Color(1,1,1,1)
	
	console.display ("items "..#items.tab)
	
end

items.add=function(opt)

	local it2={}
	item.setup(it2,opt)
	items.tab[#items.tab+1]=it2

end

items.remove=function(it)

	for i,v in ipairs(items.tab) do
		if v==it then
			table.remove(items.tab,i)
			return
		end
	end

end

	return items
end
