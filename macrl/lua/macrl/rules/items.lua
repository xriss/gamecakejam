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
	name="sak",
	desc="a Swiss Army Knife",
	longdesc=[[

Probably your favourite knife. An original red Victorinox Tinker, weighing in at a little over 60 grams and 90mm long. The various blades all swing out effortlessly at the slightest sugestion.
]],
	img="knife",
	asc=ascii("y"),
	form="item",
	can=can.sak,
	weight=1,
	metal=true,
}
a{
	name="watch",
	desc="a Swiss Wrist Watch",
	longdesc=[[

Simple time keeping device with a terrible accuracy. It seems to be counting down.
]],
	img="watch",
	asc=ascii("0"),
	form="item",
	can=can.watch,
	weight=1,
	metal=true,
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
	longdesc=[[

This is just a symbol painted on the ground.

No, you may not pick it up. It realy is just paint.
]],
	img="helipad",
	asc=ascii("O"),
	form="item",
	can=can.look,
}

end

	return items
end
