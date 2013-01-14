#!/usr/local/bin/gamecake

-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

-- setup some default search paths,
local apps=require("apps")
apps.default_paths()

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math

local opts={
	times=true, -- request simple time keeping samples
	
	width=480,	-- display basics
	height=480,
	title="hunted",
	fps=60,
	...
}

local bake=function()

	math.randomseed(os.time())

	local state=require("wetgenes.gamecake.state").bake(opts)
	do
		local screen=wwin.screen()
		local inf={width=opts.width,height=opts.height,title=opts.title}
		inf.x=(screen.width-inf.width)/2
		inf.y=(screen.height-inf.height)/2

		if wwin.flavour=="raspi" then
			inf.x=0
			inf.y=0
			inf.width=screen.width
			inf.height=screen.height
			inf.dest_width=screen.width
			inf.dest_height=screen.height
			if inf.height>=480*2 then
				inf.width=inf.width/2
				inf.height=inf.height/2
			end
		end

		state.win=wwin.create(inf)
		state.gl=require("gles").gles1
		state.win:context({})

		state.frame_rate=1/opts.fps -- how fast we want to run
		state.frame_time=0

		require("wetgenes.gamecake").bake({
			state=state,
			width=inf.width,
			height=inf.height,
		})
		
	end
	
	state.require_mod("wetgenes.gamecake.mods.escmenu") -- escmenu gives us a doom style escape menu
	state.require_mod("wetgenes.gamecake.mods.console") -- console gives us a quake style tilda console
	state.require_mod("wetgenes.gamecake.mods.keys")
	state.require_mod("wetgenes.gamecake.mods.layout")
	state.require_mod("wetgenes.gamecake.mods.mouse")

	state.next=state.rebake("hunted.main")

	return state
end




-- this will busy loop or hand back control depending on system we are running on
return bake():serv()


