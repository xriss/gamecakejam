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
		["score0"]={
			name="oggs/score",
		},
		["score1"]={
			name="oggs/score1",
		},
		["score2"]={
			name="oggs/score2",
		},
		["score3"]={
			name="oggs/score3",
		},
		["score4"]={
			name="oggs/score4",
		},

		["bathitwall"]={
			name="oggs/bathitwall",
		},

		["ballhitwall"]={
			name="oggs/ballhitwall",
		},

		["ballhitbat"]={
			name="oggs/ballhitbat",
		},

	}

	sounds.beep_max=4

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

		local function default()
		
			q1:stream_ogg{name="oggs/batwsbat"}
			q1.gain=1
			q1.pitch=1
			
		end
		
		default()

	end

	return beep
end
