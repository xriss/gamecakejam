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
	
--	wheel=0,
--	dam_min=1,
--	dam_max=2,
--	def_add=0,
--	def_mul=1,
	
	can=
	{
--		fight=true,
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
	can=can.talk,
}

a{
	name="control.colson",
	desc="Andy Colson",
	longdesc="This fat balding controler looks exactly like another fat balding controler you know.",
	img="colson",
	asc=ascii("C"),
	form="char",
	chat={
		["welcome"]={
			text=[[We have people trapped down there who need your help.]],
			says={{say="OK",text="OK"}},
		},
	},
}
a{
	name="control.burke",
	desc="Dr. Charlie Burke",
	img="burke",
	asc=ascii("B"),
	form="char",
	longdesc="The moustache catches your eye and distracts you from all the other details.",
	chat={
		["welcome"]={
			text=[[We have people trapped down there who need your help.]],
			says={{say="how",text="How does it stand right now?"}},
		},
		["how"]={
			text=[[Well, Marlowe's fine, Steubens was unconscious for a while but he's coming around, we've been unable to maintain any communication for more than a few seconds at a time.]],
			says={"OK."},
		},
	},
}
a{
	name="control.gantner",
	desc="Ed Gantner",
	longdesc="An old man in a suit, one of your few surviving friends",
	img="gantner",
	asc=ascii("G"),
	form="char",
	chat={
		["welcome"]={
			text=[[
Charlie Burke, is director of the lab and will be able to answer all you questions.
			
Thanks for coming Mac and I know If anyone can help us, it will be you.
]],
			says={{say="OK",text="OK"}},
		},
	},
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
	name="rubble",
	desc="a pile of rubble",
	longdesc=[[

A large pile of rubble blocks your way.
]],
	img="rubble",
	asc=ascii("X"),
	form="char",
	can=can.look,
}

a{
	name="console",
	desc="a keyboard and CRT",
	longdesc=[[
	
Before you is a state of the art computer interface circa 1984.

Probably best not to mess with it. These seem capable of exploding at the slightest malfunction.
]],
	img="console",
	asc=ascii("="),
	form="char",
	can=can.look,
}

a{
	name="lift_vent",
	desc="a vent",
	img="vent",
	longdesc=[[
	
Set into the dirt is a strong steel grate mounted in concrete.

This leads down the lift shaft which is the only available entrance into the Kiva complex.
]],
	asc=ascii("#"),
	form="char",
	can=can.look,
}

end

	return items
end
