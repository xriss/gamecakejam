-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local wstring=require("wetgenes.string")


--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(basket,items)
	items=items or {}
	items.modname=M.modname
	
local function ascii(a) return string.byte(a,1) end

local can=basket.rebake(basket.modgame..".rules.can")

-----------------------------------------------------------------------------
-- setup items into attrs
-----------------------------------------------------------------------------
function items.setup()

local a=basket.call.add

a{
	name="cell",
}
a{
	name="wall",
}
a{
	name="floor",
}

a{
	name="wood_chair",
	desc="a small wooden chair",
	asc=ascii("~"),
	form="item",
	can=can.item,
	weight=1,
	wood=true,
}

a{
	name="wood_plank",
	desc="a small plank of wood",
	asc=ascii("~"),
	form="item",
	can=can.item,
	weight=1,
	wood=true,
}

a{
	name="wood_log",
	desc="a friendly wooden log",
	asc=ascii("~"),
	form="item",
	can=can.item,
	weight=1,
	wood=true,
}

a{
	name="helipad",
	desc="a helipad",
	img="helipad",
	asc=ascii("O"),
	form="item",
}

end

	return items
end
