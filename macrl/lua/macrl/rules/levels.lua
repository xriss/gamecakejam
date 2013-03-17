-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local wstr=require("wetgenes.string")

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(basket,levels)
	levels=levels or {}
	levels.modname=M.modname

local yarn_attrs=basket.rebake("yarn.attrs")
local yarn_fight=basket.rebake("yarn.fight")

local code=basket.rebake(basket.modgame..".rules.code")
local rooms=basket.rebake(basket.modgame..".rules.rooms")

function levels.setup()
	basket.call.get_map=levels.get_map

local add_item=code.add_item

add_item{
	name="level",
	desc="level {pow}",
	addjunk={
--		["wood_chair"]=0.5,
--		["wood_plank"]=0.5,
--		["wood_fag"]=0.5,
--		["wood_log"]=0.5,
--		["pointy_stick"]=0.5,
	}
}

add_item{
	name="level.control",
	desc="The control room.",
}

add_item{
	name="level.shaft",
	desc="The lift shaft.",
}

add_item{
	name="level.cavein",
	desc="The blockage.",
}

end


function levels.callback(d) -- default callback when building maps
--print("callback",wstr.dump(d))

	if d.call=="level" then
	
		local c=basket.level.cellfind["spawn"] or basket.level.rand_room_cell()		
		basket.player.set_cell(c)
		
		if not basket.player.is.setup then
			basket.player.is.setup=true
			
			basket.player.hp=basket.player.is.hp

			-- default equipment
			
			local it=basket.level.new_item( yarn_attrs.get("sak") )
			it.set_cell(basket.player)
			it.is.equiped=true

			local it=basket.level.new_item( yarn_attrs.get("watch") )
			it.set_cell(basket.player)
			it.is.equiped=true
			
		end
		
		local randfill=function(t)
			for i,v in ipairs(t) do
				for i=1,v[2] do
					local c=basket.level.rand_empty()
					if c then
						basket.level.new_item( v[1] ).set_cell( c )
					end
				end
			end
		end

		if d.name=="level.control" then

			randfill{
				{"wood_chair",5},
			}

			basket.menu.show_notice("YARN v"..basket.version.number or 0,
[[
Press the CURSOR keys to move up/down/left/right.

Press SPACE bar for a menu or to select a menu item.

If you are standing near anything interesting press SPACE bar to interact with it.

Press SPACE to continue.
]])
		end
		if d.name=="level.shaft" then
			basket.menu.show_notice("YARN v"..basket.version.number or 0,
[[
That was a tight squeeze! Now we just have to find and disable the lazer security.
]])
		end

	end
	
	if d.call=="room" then
--print(room,d)
	end
	
	if d.call=="cell" then
	
		local names=yarn_attrs.keys_name_and_subnames(d.name)
		for _,n in ipairs(names) do
		
			basket.level.cellfind[n]=d.cell -- last generated cell of this type
			
			local l=basket.level.celllist[n] or {} -- all generated cells of this type
			l[#l+1]=d.cell
			basket.level.celllist[n]=l
			
		end
		
		local at
		if d.name=="wall" then
			d.cell.is.set.name("wall")
		elseif d.name=="floor" then
			d.cell.is.set.name("floor")
		elseif names[1]=="spawn" then -- just a spawn point
		elseif d.name then
			at=yarn_attrs.get(d.name)	
		end
		if at then
			local it=basket.level.new_item( at )
			if it then
				it.set_cell( d.cell)
			end
		end
	end
	
end

-----------------------------------------------------------------------------
--
-- this handles the creation of a levels map by building options to be fed
-- to the map creator
--
-- after the map is created call backs are used to tidy things up
-- for instance room callbacks fill the room with required items
-- level callbacks make sure the player is located in the map (at an apropriate spawn point)
--
-----------------------------------------------------------------------------
function levels.get_map(name,pow)

	local aa=wstr.split(name,"%.")
	
	if #aa>1 then -- must be two parts or more
		local p=tonumber(aa[#aa]) -- the last bit may be a number
		if p then
			pow=p -- override with power in name
			aa[#aa]=nil
			name=table.concat(aa,".")
		end
	end

	local opts={}
	opts.rooms={} -- required rooms for this map
	opts.flags={} -- this stuff MUST be remembered on save, the rest is inconsequential

	opts.callback=levels.callback -- call this function when finshed building each real cell/room/level

	local function add_room(s)
		local r=rooms.get_room(s)
		opts.rooms[#opts.rooms+1]=r
		return r
	end
	
	local r
--print("check level",name)

	if name=="level.control" then
	
		r=add_room("controls")
		r=add_room("shaft")
		r=add_room("entrance")
		r=add_room("collapsed")
				
		opts.mode="town"
--		opts.only_these_rooms=true

	end

	if name=="level.shaft" then
	
		r=add_room("lazer")
		r.max_doors=1
		
		r=add_room("entrance3")
		r.max_doors=1
		
	end
	
	
	return opts

end

	return levels
end
