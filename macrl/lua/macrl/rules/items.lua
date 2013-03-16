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
	can=can.watch,
	weight=1,
	lense=true,
}
a{
	name="binoculars",
	desc="a pair of Swiss Binoculars",
	longdesc=[[
A twitchers best friend.
]],
	img="binoculars",
	asc=ascii(","),
	can=can.item,
	weight=1,
	lense=true,
}
a{
	name="cigs",
	desc="a packet of cigarettes",
	longdesc=[[
One day these will be considered a thought crime.
]],
	img="cigs",
	asc=ascii("0"),
	can=can.item,
	weight=1,
	smoke=true,
}

a{
	name="wood_chair",
	desc="a small wooden chair",
	asc=ascii("~"),
	can=can.item,
	weight=1,
	wood=true,
}

a{
	name="wood_plank",
	desc="a small plank of wood",
	asc=ascii("~"),
	can=can.item,
	weight=1,
	wood=true,
}

a{
	name="wood_log",
	desc="a friendly wooden log",
	asc=ascii("~"),
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
	can=can.look,
}

end

	return items
end
