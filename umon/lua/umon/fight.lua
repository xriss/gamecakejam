-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math

local function dprint(a) print(wstr.dump(a)) end

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,fight)
	local fight=fight or {}
	fight.oven=oven
	
	fight.modname=M.modname

	local cake=oven.cake
	local opts=oven.opts
	local canvas=cake.canvas
	local font=canvas.font
	local flat=canvas.flat
	local gl=oven.gl
	local sheets=cake.sheets
	

	local gui=oven.rebake(oven.modgame..".gui")
	local main=oven.rebake(oven.modgame..".main")
	local play=oven.rebake(oven.modgame..".main_play")
--	local beep=oven.rebake(oven.modgame..".beep")

	local console=oven.rebake("wetgenes.gamecake.mods.console")

	local stats=oven.rebake(oven.modgame..".stats")
	local mon=oven.rebake(oven.modgame..".mon")


-- add fight stats
fight.setup=function(it,opt)

	it.gold=opt.gold or 0	-- loot

	it.atk=opt.atk or 0		-- attack power
	it.def=opt.def or 0		-- defence power
	it.spd=opt.spd or 0		-- speed of attack
	it.hit=opt.hit or 0		-- health hit points 0==dead
	
	it.name=opt.name or "someone"

	return it
end


-- perform attack it hits et
fight.get_wait=function(it)

	local n=60-it.spd
	if n<10 then n=10 end
	
	return n
end

-- perform attack it hits et
fight.attack=function(it,et)

	if it.hit==0 or et.hit==0 then return et.hit end

	local ad=it.atk - et.def
	if ad<=0 then ad=1 end -- minimum damage
	
	et.hit=et.hit-ad
	
	local s=it.name.." hits "..et.name.." for "..ad.." damage "

	if et.hit<=0 then
		et.hit=0

		s=it.name.." knocks out "..et.name
		
		if it.name=="umon" then -- loot
		
			it.gold=it.gold+et.gold

		end

	end

	stats.print(s)
	
	return et.hit
end

	return fight
end
