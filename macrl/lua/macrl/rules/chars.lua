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
	name="player",
	desc="the MacGyver",
	asc=ascii("@"),
	form="char",
	player=true,
	hp=100,
	
	wheel=0,
	dam_min=1,
	dam_max=2,
	def_add=0,
	def_mul=1,
	
	can=
	{
		fight=true,
		loot=true,
		make_room_visible=true,
		operate=true,
	},
	
}

a{
	name="control",
	desc="a fat controler",
	asc=ascii("C"),
	form="char",
	hp=100,
	
	wheel=0,
	dam_min=1,
	dam_max=2,
	def_add=0,
	def_mul=1,
	
--	can=
--	{
--		fight=true,
--		loot=true,
--		make_room_visible=true,
--		operate=true,
--	},
	
}

a{
	name="control.colson",
	desc="a fat balding controler",
	img="colson",
	asc=ascii("C"),
	form="char",
}
a{
	name="control.burke",
	desc="a moustache in a suit",
	img="burke",
	asc=ascii("B"),
	form="char",
}
a{
	name="control.gantner",
	desc="an old man in a suit",
	img="gantner",
	asc=ascii("G"),
	form="char",
}

a{
	name="control.tech1",
	desc="a fat balding technician",
	img="tech1",
	asc=ascii("X"),
	form="char",
}
a{
	name="control.tech2",
	desc="a short hairy technician",
	img="tech2",
	asc=ascii("Y"),
	form="char",
}
a{
	name="control.tech3",
	desc="a tall skinny technician",
	img="tech3",
	asc=ascii("Z"),
	form="char",
}

a{
	name="console",
	desc="an keyboard and CRT",
	img="console",
	asc=ascii("="),
	form="char",
}

a{
	name="lift_vent",
	desc="a vent",
	img="vent",
	asc=ascii("#"),
	form="char",
}

end

	return items
end
