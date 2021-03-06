-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require


local function print(...) _G.print(...) end

local wstr=require("wetgenes.string")
local pack=require("wetgenes.pack")

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M


M.bake=function(oven,beep)

	beep=beep or {} 
	beep.modname=M.modname

	local cake=oven.cake
	local sounds=cake.sounds

	local ids={
	
--		["heartbeat"]={
--			name="oggs/heart",
--		},
		["munch"]={
			name="oggs/munch",
			idx=4,
		},
		["death1"]={
			name="oggs/death1",
		},
		["death2"]={
			name="oggs/death2",
		},
		["death3"]={
			name="oggs/death3",
		},
		["death4"]={
			name="oggs/death4",
		},
		["exit1"]={
			name="oggs/exit1",
		},
		["exit2"]={
			name="oggs/exit2",
		},
		["exit3"]={
			name="oggs/exit3",
		},
		["exit4"]={
			name="oggs/exit4",
		},
		["exit5"]={
			name="oggs/exit5",
		},
		["exit6"]={
			name="oggs/exit6",
		},
		["exit7"]={
			name="oggs/exit7",
		},
		["key1"]={
			name="oggs/key1",
		},
		["key2"]={
			name="oggs/key2",
		},
		["key3"]={
			name="oggs/key3",
		},
		["key4"]={
			name="oggs/key4",
		},
		["key5"]={
			name="oggs/key5",
		},
		["key6"]={
			name="oggs/key6",
		},
		["key7"]={
			name="oggs/key7",
		},
--[[
		["die"]={
			name="sfx/diehunted",
		},
		["slide"]={
			name="sfx/slide",
		},
		["slide1"]={
			name="sfx/slide1",
		},
		["start"]={
			name="sfx/starthunted",
		},
		["win"]={
			name="sfx/winhunted",
		},
]]

	}

	sounds.beep_max=3

-- load all the sample referenced in the ids table
	function beep.loads()
		local t={}
		for n,v in pairs(ids) do
			t[v.name]=true
		end
		local tab={}
		for n,v in pairs(t) do
			tab[#tab+1]=n
		end
		cake.sounds.loads(tab)

--		cake.sounds.load_ogg("oggs/hunted","ogghunt")
	end

	function beep.lookup(id)
	
		while type(id)=="string" do -- allow recursive lookups
			id=ids[id]
		end
	
		return id
	end

	function beep.play(id,gain,pitch)

		if cake.sounds.disabled then return end -- disabled

		local t=beep.lookup(id)
		
		if t then
			local snd=sounds.get(t.name)
			if snd then
				t.buff=snd.buff -- update buffer id
				local n=t
				if gain or pitch then -- tempory adjust
					n={} for i,v in pairs(t) do n[i]=v end
					n.gain=gain or n.gain
					n.pitch=pitch or n.pitch
				end
				sounds.beep(n)
			end
		end
	
	end

	function beep.stream(name)
	
		if cake.sounds.disabled then return end -- disabled
	
		local q1=cake.sounds.queues[1]
		local q2=cake.sounds.queues[2]

		local function default()
		
			q1:stream_ogg{name="oggs/hum"}
			q1.gain=0
			q1.pitch=1

			q2:stream_ogg{name="oggs/bearsong"}
			q2.gain=0
			q2.pitch=1
			
		end
		
		if name=="menu" then

			default()
			q1.gain=0
			q2.gain=1

		elseif name=="game" then

			default()
			q1.gain=1
			q2.gain=0

		elseif name=="intermission" then

			q1:stream_ogg{name="oggs/intermission",mode="restart"}
			q1.gain=1
			q1.pitch=1

			q2:stream_ogg{mode="stop"}
			q2.gain=0
			
		end

	end

	return beep
end
