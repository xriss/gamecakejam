-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math


--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,items)
	items=items or {}
	items.modname=M.modname

	local gl=oven.gl
	local cake=oven.cake
	local opts=oven.opts
	local canvas=cake.canvas
	local layouts=cake.layouts
	local font=canvas.font
	local flat=canvas.flat
	local sheets=cake.sheets

	local bikes=oven.rebake(oven.modgame..".bikes")
	
items.loads=function()

end
		
items.setup=function()

	items.loads()
	
	items.list={}
	
	items.vx=-1
	items.vy=0
end


items.clean=function()

	items.list=nil
end

items.msg=function(m)

end


items.update=function()
	
	for i=#items.list,1,-1 do local v=items.list[i]
		v:update()
		if v.remove_from_list then -- set this flag to remove from list
			table.remove(items.list,i) -- safe to do as we iterate backwards
		end
	end
	
-- easy just to sort the items to fix the draw order
	table.sort(items.list,function(a,b)
		return a.py > b.py
	end)
	
end

items.draw=function()
	
	gl.PushMatrix()
	gl.Translate(bikes.px,bikes.py,0)
		
	for i=#items.list,1,-1 do local v=items.list[i]
		v:draw()
	end
	
	gl.PopMatrix()

end
	
	return items
end

