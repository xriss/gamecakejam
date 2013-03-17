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
	desc="A Swiss Army Knife.",
	longdesc=[[
Probably your favourite knife. An original red Victorinox Tinker, weighing in at a little over 60 grams and 90mm long. The various blades all swing out effortlessly at the slightest suggestion.
]],
	img="knife",
	asc=ascii("y"),
	can=can.sak,
	weight=1,
	metal=true,
}
a{
	name="watch",
	desc="A Swiss Wrist Watch.",
	longdesc=[[
Simple time keeping device with terrible accuracy. It seems to be counting down.
]],
	img="watch",
	asc=ascii("0"),
	can=can.watch,
	weight=1,
	lense=true,
}
a{
	name="binoculars",
	desc="A pair of Swiss Binoculars.",
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
	desc="A packet of cigarettes.",
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
	name="wood_plank",
	desc="A small plank of wood.",
	asc=ascii("~"),
	img="plank",
	can=can.item,
	weight=1,
	wood=true,
}

a{
	name="wood_log",
	desc="A friendly wooden log.",
	asc=ascii("~"),
	img="log",
	can=can.item,
	weight=1,
	wood=true,
}

a{
	name="hose",
	desc="A fire hose.",
	asc=ascii("0"),
	img="hose",
	can=can.item,
	weight=1,
	hose=true,
}

a{
	name="kettle",
	desc="A small kettle.",
	longdesc=[[
A small kettle that does not whistle no matter how hard you rub it.
]],
	asc=ascii("k"),
	img="kettle",
	can=can.item,
	weight=1,
	metal=true,
}
a{
	name="brick",
	desc="A brick like any other.",
	longdesc=[[
Cold to the touch, hard to the feel.
]],
	asc=ascii("b"),
	img="brick1",
	can=can.item,
	weight=1,
	heavy=true,
}
a{
	name="brick.1",
	desc="A brick.",
	longdesc=[[
A brick is a brick is a brick is a brick.
]],
	img="brick1",
}
a{
	name="brick.2",
	desc="A brick.",
	longdesc=[[
It has bits of other brick stuck to it.
]],
	img="brick2",
}
a{
	name="brick.3",
	desc="A brick.",
	longdesc=[[
You can build a house with these.
]],
	img="brick3",
}
a{
	name="brick.4",
	desc="A brick.",
	longdesc=[[
Just the one lonely brick.
]],
	img="brick4",
}

a{
	name="helipad",
	desc="A helipad.",
	longdesc=[[

This is just a symbol painted on the ground.

No, you may not pick it up. It realy is just paint.
]],
	img="helipad",
	asc=ascii("O"),
	can=can.look,
}

a{
	name="debri",
	desc="A small chunk of debri.",
	asc=ascii("_"),
	img="debri1",
	can=can.item,
	weight=1,
	stone=true,
}
a{
	name="debri.1",
	desc="A small chunk of debri.",
	img="debri1",
}
a{
	name="debri.2",
	desc="A tiny chunk of debri.",
	img="debri2",
}
a{
	name="debri.3",
	desc="A small bit of debri.",
	img="debri3",
}
a{
	name="debri.4",
	desc="A tiny bit of debri.",
	img="debri4",
}
a{
	name="debri.5",
	desc="A small plop of debri.",
	img="debri5",
}

end

	return items
end
