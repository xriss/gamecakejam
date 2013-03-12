-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local wstr=require("wetgenes.string")

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

function M.bake(opts)

	local basket={}

	basket.opts=opts
	
	basket.data={} -- squirt game data into here
	basket.call={} -- squirt game functions into here
	
	basket.baked={}

-- require and bake basket.baked[modules] in such a way that it can have simple circular dependencies
	function basket.rebake(name)

		local ret=basket.baked[name]
		
		if not ret then
		
			ret={modname=name}
			basket.baked[name]=ret
			ret=assert(require(name)).bake(basket,ret)
			
		end

		return ret
	end

	function basket.preheat()

		basket.canvas=basket.rebake("yarn.canvas")
		basket.levels=basket.rebake("yarn.levels")
		
		basket.level=basket.rebake("yarn.levels").get("level")
		basket.player=basket.rebake("yarn.items").get("player")
		basket.menu=basket.rebake("yarn.menu")

		basket.level.setup({})
		basket.player.set_cell(basket.level.rand_room_cell())
		
	
		basket.menu.show_player_menu(basket.player)

		return basket
	end


	function basket.msg(m)
	--ascii,key,act
		if basket.menu and basket.menu.msg(m) then -- give the menu first chance to eat this keypress
			basket.levels.msg() -- stop level input
		else
			basket.levels.msg(m)
		end
	end



function basket.update()
--	return level.update() + menu.update()
end



--[[

-- save the current level
-- on level change or
-- in order to dump this state to disk

function save()
	local sd=sdata

	local level_name=level.name
	local level_pow=level.pow
	
	soul.level_name=level_name
	soul.level_pow=level_pow

	sd.soul=soul -- our soul, saves just as is since it does not contain complex data

	if level.flags.clean_slate then -- special test levels

	else
		player.un_cell()
		sd.player=player.save() -- the player is special, they contain epic loots
		player.re_cell()
		
		sd.levels=sd.levels or {}
		
		sd.levels[level_name]=sd.levels[level_name] or {}
		sd.levels[level_name][level_pow]=level.save()
	end
	
	return sd
end

-- get any previously created saved level data if it exists
function get_level_save(level_name,level_pow)

	local sd=sdata

	if sd.levels and sd.levels[level_name] then
	
		return sd.levels[level_name][level_pow]
		
	end
	
end


-- reload a full saved data (create and then load everything)
function load(sd)
	sdata=sd
	
	soul=sd.soul
	
	player=yarn_item.create({level=level})
	player.load(sd.player)

	level=yarn_level.create(yarn_attrs.get(soul.level_name,soul.level_pow,{xh=40,yh=28}),yarn)
	
	player.re_cell()

end

]]

	return basket
end

