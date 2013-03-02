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

	function beep.play(id)
		local t=beep.lookup(id)
		
		if t then
		
			sounds.beep(sounds.get(t.name),t.idx)
		
		end
	
	end

	return beep
end
