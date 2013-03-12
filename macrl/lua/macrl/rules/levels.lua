-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(basket,levels)
	levels=levels or {}
	levels.modname=M.modname

local yarn_attrs=basket.rebake("yarn.attrs")
local yarn_fight=basket.rebake("yarn.fight")

local code=basket.rebake(basket.modgame..".rules.code")
local maps=basket.rebake(basket.modgame..".rules.maps")
local get_room=maps.get_room

function levels.setup()
	basket.call.get_map=levels.get_map
	basket.call.generate_player=levels.generate_player
	basket.call.generate_player_bystairs=levels.generate_player_bystairs

local add_item=code.add_item

add_item{
	name="level",
	desc="level {pow}",
	addjunk={
		["wood_chair"]=0.5,
		["wood_plank"]=0.5,
		["wood_fag"]=0.5,
		["wood_log"]=0.5,
		["pointy_stick"]=0.5,
	}
}
add_item{
	name="level.home",
	desc="Home level {pow}",
}
add_item{
	name="level.town",
	desc="Town level {pow}",
}
add_item{
	name="level.dump",
	desc="Dump level {pow}",
}

end


function levels.callback(d) -- default callback when building maps
	if d.call=="cell" then
	
		for _,n in ipairs(yarn_attr.keys_name_and_subnames(d.name)) do
		
			d.level.cellfind[n]=d.cell -- last generated cell of this type
			
			local l=d.level.celllist[n] or {} -- all generated cells of this type
			l[#l+1]=d.cell
			d.level.celllist[n]=l
			
		end
		
		local at
		if d.name=="wall" then
			d.cell.set.name("wall")
		else
			at=yarn_attrs.get(d.name)
		end
		if at then
			local it=d.level.new_item( at )
			if it then
				it.set_cell( d.cell)
			end
		end
	end
end



function levels.generate_player(level)
	if level.flags.clean_slate then
		level.player=level.new_item( "player" )
	else
		level.player=level.player or level.main.player or level.new_item( "player" )
		level.main.player=level.player
	end
	level.main.player=level.player		
	level.player.level=level
	level.player.is.soul=level.main.soul -- we got soul
	level.player.set_cell( level.cellfind["player_spawn"] or level.rand_room_cell({}) )
end

function levels.generate_player_bystairs(level)
	if level.flags.clean_slate then
		level.player=level.new_item( "player" )
	else
		level.player=level.player or level.main.player or level.new_item( "player" )
		level.main.player=level.player
	end
	level.player.level=level
	level.player.is.soul=level.main.soul -- we got soul
	
	local stairs
	if level.soul.last_stairs then -- aim to stick to the same stairs
		stairs=level.cellfind[level.soul.last_stairs]
dbg("fond real stairs : "..tostring(stairs))
	end
	if not stairs then stairs=level.cellfind["stairs"] end
	
	if stairs then
		for i,v in stairs.neighbours() do
			if v.is_empty() then --empty so place palyer here
				level.player.set_cell( v )
				break
			end
		end
	else -- if we got here then just pick a random place
		level.player.set_cell( level.rand_room_cell({}) )
	end
end

function levels.generate_ants(level)
	for i=1,10 do
		local c=level.rand_room_cell({})
		if not c.char then
			local p=level.new_item( "ant" )
			p.set_cell( c )
		end
	end
end

function levels.generate_blobs(level)
	for i=1,5 do
		local c=level.rand_room_cell({})
		if not c.char then
			local p=level.new_item( "blob" )
			p.set_cell( c )
		end
	end
end

function levels.generate_junk(level)

-- first count number of empty cells

local empty_cells={}

local add

	for i=0,#level.cells do local v=level.cells[i]
		if v.is_empty() then empty_cells[#empty_cells+1]=v end
	end

	for n,v in pairs(level.addjunk) do
		local count=math.floor(#empty_cells * v/100)
		if count>0 then
			for i=1,count do
				local idx=math.random(1,#empty_cells)
				local c=table.remove(empty_cells,idx)
				local p=level.new_item( n )
				p.set_cell( c )
			end
		end
	end

end



-----------------------------------------------------------------------------
--
-- this handles the creation of levels by building options to be fed
-- to the level creator
--
-----------------------------------------------------------------------------
function levels.get_map(name,pow)

	local aa=strings.split(name,"%.")
	
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

	function opts.add_room(s)
		local r=maps.get_room(s)
		opts.rooms[#opts.rooms+1]=r
		r.callback=callback
		return r
	end
	local add_room=opts.add_room


--default generation	
	opts.generate=function(level)
		levels.generate_player(level)
		levels.generate_ants(level)
		levels.generate_blobs(level)
	end
	
	local r
	if pow==0 then -- level 0 is always town no matter what the name
	
		r=add_room("home_stairs")
		r=add_room("dump_stairs")
		r=add_room("test_stairs")
		r=add_room("redroom")
				
		opts.mode="town"
		opts.only_these_rooms=true

		opts.generate=function(level)
			levels.generate_player_bystairs(level)
			levels.generate_junk(level)
		end
	
	elseif name=="level.home" then
	
		r=add_room("home_stairs")
		r=add_room("home_bedroom")
		r=add_room("home_mainroom")
		
		opts.generate=function(level)
				
			if level.soul.capsule_done then
				levels.generate_player_bystairs(level)
			else
				levels.generate_player(level)
			end
			
			levels.generate_junk(level)

			level.soul.capsule_done=true

		end
		
		
	elseif name=="level.dump" then

		r=add_room("dump_stairs")

			opts.generate=function(level)
			
				levels.generate_player(level)
				levels.generate_ants(level)
				levels.generate_blobs(level)
				
				levels.generate_junk(level)
				
			end
	
	else

		r=add_room("stairs")
	
	end
	
	
	return opts

end

	return levels
end
