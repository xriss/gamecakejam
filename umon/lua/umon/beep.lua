-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require


local function print(...) _G.print(...) end

local wstr=require("wetgenes.string")
local pack=require("wetgenes.pack")
local sod=require("wetgenes.sod")

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M


M.bake=function(state,beep)

	beep=beep or {} 
	beep.modname=M.modname

	local cake=state.cake
	local sounds=cake.sounds
	local al=sounds.al
	
	

	local ids={

		["die"]={
			name="oggs/mon_die",
		},
		["kill1"]={
			name="oggs/human_die1",
		},
		["kill2"]={
			name="oggs/human_die2",
		},
		["fight1"]={
			name="oggs/fight1",
		},
		["fight2"]={
			name="oggs/fight2",
		},
		["fight3"]={
			name="oggs/fight3",
		},
	}

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

	function beep.play(id)
		local t=beep.lookup(id)
		
		if t then
		
			sounds.beep_max=2 -- keep 4 available for long sounds
		
			local ss=sounds.get(t.name)
			if ss then
				ss.idx=t.idx -- temp setting
				ss.name=t.name			
				sounds.beep(ss)
			end
		else
		
print("Missing sound FX for "..id)

		end
	
	end

	
	function beep.update()
		
		
	end

	function beep.stream(id,idx)
	
		local qq=cake.sounds.queues[1]
	
		if     id=="play" or id=="menu" or id=="rest" then

			qq.BufferData=nil
			if not qq.oggs then
				qq.ogg_loop=true
				qq.state="play_queue"
				qq.oggs={}
				qq.gain=1.0
				qq.pitch=1
			end
			if id=="rest" then
				qq.og=nil -- force old ogg to stop
				if al then al.SourceStop(sounds.strs[1].source) end
				qq.oggs={"oggs/mon_rest"}
			else
				qq.og=nil -- force old ogg to stop
				if al then al.SourceStop(sounds.strs[1].source) end
				qq.oggs={"oggs/umon_theme1"}
			end

		else
			qq.oggs=nil
			qq.og=nil -- force old ogg to stop
			if al then al.SourceStop(sounds.strs[1].source) end
		end

	end
	
	
	return beep
end
