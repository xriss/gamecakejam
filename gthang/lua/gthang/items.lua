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

	

end

item.clean=function(it)

end

item.update=function(it)

	
	
end

item.draw=function(it)
	
	

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
