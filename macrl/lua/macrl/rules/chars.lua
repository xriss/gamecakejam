-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local wstring=require("wetgenes.string")


--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(basket,items)
	items=items or {}
	items.modname=M.modname

local yarn_attrs=basket.rebake("yarn.attrs")
	
local function ascii(a) return string.byte(a,1) end

local can=basket.rebake(basket.modgame..".rules.can")
local code=basket.rebake(basket.modgame..".rules.code")

local sscores=basket.oven.rebake("wetgenes.gamecake.spew.scores")

-----------------------------------------------------------------------------
-- setup items into attrs
-----------------------------------------------------------------------------
function items.setup()

local a=basket.call.add

a{
	name="player",
	desc="the MacGyver",
	img="macgyver",
	asc=ascii("@"),
	big=true,
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
	big=true,
	hp=100,
	can=can.talk,
}

a{
	name="control.colson",
	desc="Andy Colson",
	longdesc="This fat balding controler looks exactly like another fat balding controler you know.",
	img="colson",
	asc=ascii("C"),
	big=true,
	chat={
		["welcome"]=function(it,by)
			if basket.level.is["got_cigs"] then -- he only has one pack of cigs to give
				return it.is.chat.pack
			else
				return it.is.chat.welcome1
			end
		end,
		["welcome1"]={
			text=[[The only way to get down to the first level right now is through the elevator and we can't even open the doors up here. The whole shaft is protected by laser.]],
			says={{say="welcome2",text="Infrared or gas discharge?"}},
		},
		["welcome2"]={
			text=[[Gas. CO2, 10,000 watts.]],
			says={{say="exit",text="You boys take your elevator shafts pretty seriously."},
			{say="cig",text="Spare a cigarette?"},},
		},
		["cig"]=function(it,by)
			basket.level.is["got_cigs"]=true
			basket.level.new_item( yarn_attrs.get("cigs") ).set_cell(basket.player)
			code.step(1)
			basket.set_msg( "You got a packet of cigarettes!" )
			return{
			text=[[Oh sure.]],
			says={{say="pack",text="Thanks."},},}
		end,
		["pack"]={
			text=[[
Take the pack why don't ya?
Want my lighter too?]],
			says={{say="exit",text="No thanks, I carry my own matches."}},
		},
	},
}
a{
	name="control.burke",
	desc="Dr. Charlie Burke",
	img="burke",
	asc=ascii("B"),
	big=true,
	longdesc="The moustache catches your eye and distracts you from all the other details.",
	chat={
		["welcome"]={
			text=[[We have people trapped down there who need your help.]],
			says={{say="how",text="How does it stand right now?"}},
		},
		["how"]={
			text=[[Well, Marlowe's fine, Steubens was unconscious for a while but he's coming around, we've been unable to maintain any communication for more than a few seconds at a time and they are both trapped 300ft down. There are 20 other people down there and we have no idea how or where they are.]],
			says={{say="more",text="Have you got somebody I can talk building layout with?"}},
		},
		["more"]={
			text=[[Andy Colson is our chief of operations, you can ask him anything about the building layout.]],
			says={{say="time",text="What about time."}},
		},
		["time"]={
			text=[[We have an acid leak and in a little under 5 hours we will need to take drastic acion to stop it poluting the aquafer.]],
			says={{say="ok",text="I best be going then."}},
		},
	},
}
a{
	name="control.gantner",
	desc="Ed Gantner",
	longdesc="An old man in a suit, one of your few surviving friends",
	img="gantner",
	asc=ascii("G"),
	big=true,
	chat={
		["welcome"]={
			text=[[
Thanks for coming Mac and I know If anyone can help us, it will be you.
]],
			says={{say="who",text="Who should I talk to around here?"}},
		},
		["who"]={
			text=[[
Charlie Burke, is director of the lab and will be able to answer your questions.
]],
			says={{say="exit",text="OK"}},
		},
	},
}

a{
	name="control.tech1",
	desc="a fat balding technician",
	img="tech1",
	asc=ascii("X"),
	big=true,
}
a{
	name="control.tech2",
	desc="a short hairy technician",
	img="tech2",
	asc=ascii("Y"),
	big=true,
}
a{
	name="control.tech3",
	desc="a tall skinny technician",
	img="tech3",
	asc=ascii("Z"),
	big=true,
}

a{
	name="rubble",
	desc="a pile of rubble",
	longdesc=[[
A large pile of rubble blocks your way.
]],
	img="rubble",
	asc=ascii("X"),
	big=true,
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
	big=true,
	can=can.look,
}

a{
	name="lift_vent",
	desc="a vent",
	img="vent",
	longdesc=[[
Set into the dirt is a strong steel grate mounted in concrete.

This leads down the lift shaft which is the only available entrance into the Kiva complex.

Maybe you could use your Swiss Army Knife to open it.
]],
	asc=ascii("#"),
	big=true,
	can=can.look,
	sak={
		basetime=10*60,
		action="Force open the grate and climb inside.",
		needs={
			{"wood",10*60},
		},
		done=function(it,by)
			basket.change_level({levelname="level.shaft"})
			sscores.add(50000)
		end,
	},
}

a{
	name="lazer",
	desc="a lazer protects this area",
	img="lazer",
	longdesc=[[
This area is protected by fully charged lazers.

Whatyagonna do about it?
]],
	asc=ascii("#"),
	big=true,
	can=can.look,
	sak={
		basetime=10*60,
		action="Use smoke/dust to discover exactly where the lazers are and then reflect it back into itself. The feedback will destroy it!",
		needs={
			{"smoke",10*60},
			{"lens",10*60},
		},
		done=function(it,by)
			basket.change_level({levelname="level.blockage"})
			sscores.add(50000)
		end,
	},
}

a{
	name="blockage",
	desc="a blockage caused by a cavein",
	img="blockage",
	longdesc=[[
This area has suffered from a cavein and is impassable.

However you can hear a tapping coming from the otherside. You should find a way to get through and rescue the people traped there.
]],
	asc=ascii("#"),
	big=true,
	can=can.look,
	sak={
		basetime=10*60,
		action="Use water presure from a fire hoze to lift an iron girder a few inches, once lifted you will be able to swing the girder to one side and hopefully open up a way through.",
		needs={
			{"wood",10*60},
			{"hose",10*60},
		},
		done=function(it,by)
			basket.change_level({levelname="level.rescue"})
			sscores.add(50000)
		end,
	},
}

a{
	name="wood_chair",
	desc="a small wooden chair",
	img="chair",
	asc=ascii("h"),
	big=true,
	can=can.scrump,
	scrump={
		items={
			{"wood_plank",0.5},
			{"wood_log",0.5},
		},
		score=1000,
	},
	weight=1,
	wood=true,
}

a{
	name="wood_crate",
	desc="a small wooden crate, every game must have one",
	img="crate",
	asc=ascii("b"),
	big=true,
	can=can.scrump,
	scrump={
		items={
			{"wood_plank",0.5},
			{"wood_log",0.5},
		},
		score=1000,
	},
	weight=1,
	wood=true,
}

a{
	name="victim",
	desc="A random scientist",
	img="burke",
	asc=ascii("B"),
	big=true,
	longdesc="Although you are sure they have some distinguishing features you cant quite put your finger on what they are",
	chat={
		["welcome"]={
			text=[[Can you help us get out of here?]],
			says={{say="rescue",text="Just head back the way I came and people will be there to help you the rest of the way."}},
		},
	},
}
end

	return items
end
