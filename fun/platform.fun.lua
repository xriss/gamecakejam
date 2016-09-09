
local bit=require("bit")
local wstr=require("wetgenes.string")
local wgrd=require("wetgenes.grd")
local tardis=require("wetgenes.tardis")	-- matrix/vector math

local bitdown=require("wetgenes.gamecake.fun.bitdown")
local bitdown_font_4x8=require("wetgenes.gamecake.fun.bitdown_font_4x8")

local chipmunk=require("wetgenes.chipmunk")


local hx,hy,ss=424,240,3
local fps=60

--request this hardware setup before calling main
hardware={
	{
		component="screen",
		size={hx,hy},
		bloom=0.75,
		filter="scanline",
		scale=ss,
		fps=60,
	},
	{
		component="tiles",
		name="tiles",
		tile_size={8,8},
		bitmap_size={16,16},
	},
	{
		component="tiles",
		name="font",
		tile_size={4,8},
		bitmap_size={128,1},
	},
	{
		component="copper",
		name="copper",
		size={hx,hy},
	},
	{
		component="tilemap",
		name="map",
		tiles="tiles",
		tilemap_size={math.ceil(hx/8),math.ceil(hy/8)},
	},
	{
		component="sprites",
		name="sprites",
		tiles="tiles",
	},
	{
		component="tilemap",
		name="text",
		tiles="font",
		tilemap_size={math.ceil(hx/4),math.ceil(hy/8)},
	},
}


local tiles={}
local names={} -- a name -> tile number lookup
local maps={}

local set_name_tile=function(name,tile,data)
	names[name]=tile
	tiles[tile]=data
end


local tilemap={
	[0]={0,0,0,0},

	[". "]={  0,  0,  0,  0},
	["1 "]={  1,  0,  0,  0,	solid=1},
	["2 "]={  2,  0,  0,  0,	solid=1,dense=1},
	["3 "]={  3,  0,  0,  0,	solid=0},
	["4 "]={  4,  0,  0,  0,	solid=1},
	["5 "]={  5,  0,  0,  0,	solid=1},
	["6 "]={  6,  0,  0,  0,	solid=1},
	["7 "]={  7,  0,  0,  0,	solid=1},
	["8 "]={  8,  0,  0,  0,	solid=1},
	["9 "]={  9,  0,  0,  0,	solid=1},
	["A "]={ 10,  0,  0,  0,	solid=1},
	["B "]={ 11,  0,  0,  0,	solid=1},
	["C "]={ 12,  0,  0,  0,	solid=1},
	["D "]={ 13,  0,  0,  0,	solid=1},
	["E "]={ 14,  0,  0,  0,	solid=1},
	["F "]={ 15,  0,  0,  0,	solid=1},

	["$ "]={  0,  0,  0,  0,	loot=1},
	["? "]={  0,  0,  0,  0,	item=1},
}


tiles[0x0000]=[[
. . . . . . . . 
. . . . . . . . 
. . . . . . . . 
. . . . . . . . 
. . . . . . . . 
. . . . . . . . 
. . . . . . . . 
. . . . . . . . 
]]
tiles[0x0001]=[[
1 1 1 1 1 1 1 1 
1 1 1 1 1 1 1 1 
1 1 1 1 1 1 1 1 
1 1 1 1 1 1 1 1 
1 1 1 1 1 1 1 1 
1 1 1 1 1 1 1 1 
1 1 1 1 1 1 1 1 
1 1 1 1 1 1 1 1 
]]
tiles[0x0002]=[[
2 2 2 2 2 2 2 2 
2 2 2 2 2 2 2 2 
2 2 2 2 2 2 2 2 
2 2 2 2 2 2 2 2 
2 2 2 2 2 2 2 2 
2 2 2 2 2 2 2 2 
2 2 2 2 2 2 2 2 
2 2 2 2 2 2 2 2 
]]
tiles[0x0003]=[[
7 7 7 7 7 7 7 7 
7 0 0 0 0 0 0 7 
7 0 0 0 0 0 0 7 
7 0 0 0 0 0 0 7 
7 0 0 0 0 0 0 7 
7 0 0 0 0 0 0 7 
7 0 0 0 0 0 0 7 
7 7 7 7 7 7 7 7 
]]
tiles[0x0100]=[[
. . Y Y Y Y . . 
. Y Y Y Y Y Y . 
Y Y Y Y Y Y Y Y 
Y Y Y Y Y Y Y Y 
Y Y Y Y Y Y Y Y 
Y Y Y Y Y Y Y Y 
. Y Y Y Y Y Y . 
. . Y Y Y Y . . 
]]
tiles[0x0101]=[[
. . . . . . . . 
. . Y Y Y Y . . 
. Y Y 0 0 Y Y . 
. Y 0 Y Y 0 Y . 
. Y 0 Y Y 0 Y . 
. Y Y 0 0 Y Y . 
. . Y Y Y Y . . 
. . . . . . . . 
]]

tiles[0x0200]=[[
. . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . 7 7 7 7 . . . . . . . . . . 
. . . . . . . . . 7 2 7 7 1 7 . . . . . . . . . 
. . . . . . . . . 7 7 2 1 7 7 . . . . . . . . . 
. . . . . . . . 7 7 7 1 2 7 7 7 . . . . . . . . 
. . . . . . . 7 7 7 1 7 7 2 7 7 7 . . . . . . . 
. . . . . . . 7 7 7 7 7 7 7 7 7 7 . . . . . . . 
. . . . . . . . . . 7 7 0 7 . . . . . . . . . . 
. . . . . . . . . . 7 7 7 7 7 . . . . . . . . . 
. . . . . . . . . . 7 7 7 7 . . . . . . . . . . 
. . . . . . . . . . . 7 7 . . . . . . . . . . . 
. . . . . . . . . . 7 7 7 7 . . . . . . . . . . 
. . . . . . . . . 7 7 7 7 7 7 . . . . . . . . . 
. . . . . . . . . 7 7 7 7 7 7 . . . . . . . . . 
. . . . . . . . 7 7 7 7 . 7 7 7 . . . . . . . . 
. . . . . . . . 7 7 7 7 7 . 7 7 . . . . . . . . 
. . . . . . . . . . 7 7 7 7 . . . . . . . . . . 
. . . . . . . . . 7 7 7 . 7 7 . . . . . . . . . 
. . . . . . . . . 7 7 . 7 7 7 . . . . . . . . . 
. . . . . . . . . 7 7 7 . 7 7 7 . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . 
]]
tiles[0x0203]=[[
. . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . 7 7 7 7 . . . . . . . . . . 
. . . . . . . . . 7 2 7 7 1 7 . . . . . . . . . 
. . . . . . . . . 7 7 2 1 7 7 . . . . . . . . . 
. . . . . . . . 7 7 7 1 2 7 7 7 . . . . . . . . 
. . . . . . . 7 7 7 1 7 7 2 7 7 7 . . . . . . . 
. . . . . . . 7 7 7 7 7 7 7 7 7 7 . . . . . . . 
. . . . . . . . . . 7 7 0 7 . . . . . . . . . . 
. . . . . . . . . . 7 7 7 7 7 . . . . . . . . . 
. . . . . . . . . . 7 7 7 7 . . . . . . . . . . 
. . . . . . . . . . . 7 7 . . . . . . . . . . . 
. . . . . . . . . . 7 7 7 7 . . . . . . . . . . 
. . . . . . . . . 7 7 . 7 7 7 . . . . . . . . . 
. . . . . . . . . 7 7 . 7 7 7 . . . . . . . . . 
. . . . . . . . . 7 7 . 7 7 7 . . . . . . . . . 
. . . . . . . . . 7 7 7 . 7 7 . . . . . . . . . 
. . . . . . . . . . 7 7 7 7 . . . . . . . . . . 
. . . . . . . . . . . 7 7 . . . . . . . . . . . 
. . . . . . . . . . . 7 7 . . . . . . . . . . . 
. . . . . . . . . . . 7 7 7 . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . 
]]
tiles[0x0206]=[[
. . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . 7 7 7 7 . . . . . . . . . . 
. . . . . . . . . 7 2 7 7 1 7 . . . . . . . . . 
. . . . . . . . . 7 7 2 1 7 7 . . . . . . . . . 
. . . . . . . . 7 7 7 1 2 7 7 7 . . . . . . . . 
. . . . . . . 7 7 7 1 7 7 2 7 7 7 . . . . . . . 
. . . . . . . 7 7 7 7 7 7 7 7 7 7 . . . . . . . 
. . . . . . . . . . 7 7 0 7 . . . . . . . . . . 
. . . . . . . . . . 7 7 7 7 7 . . . . . . . . . 
. . . . . . . . . . 7 7 7 7 . . . . . . . . . . 
. . . . . . . . . . . 7 7 . . . . . . . . . . . 
. . . . . . . . . . 7 7 7 7 . . . . . . . . . . 
. . . . . . . . . 7 7 7 7 7 7 . . . . . . . . . 
. . . . . . . . 7 7 7 7 7 7 7 7 . . . . . . . . 
. . . . . . . 7 7 7 7 7 7 7 7 7 7 . . . . . . . 
. . . . . . . 7 7 . 7 7 7 7 . 7 7 . . . . . . . 
. . . . . . . . . . 7 7 7 7 7 . . . . . . . . . 
. . . . . . . . . 7 7 7 . 7 7 . 7 . . . . . . . 
. . . . . . . . 7 7 . . . . 7 7 7 . . . . . . . 
. . . . . . . . 7 7 7 . . . 7 7 . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . 
]]
set_name_tile("cannon_ball",0x0209,[[
. . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . R R R R R R . . . . . . . . . 
. . . . . . . R R R R R R R R R R . . . . . . . 
. . . . . . R R R R R R R R R R R R . . . . . . 
. . . . . R R R R R R R R R R R R R R . . . . . 
. . . . . R R R R R R R R R R R R R R . . . . . 
. . . . R R R R R R R R R R R R R R R R . . . . 
. . . . R R R R R R R R R R R R R R R R . . . . 
. . . . R R R R R R R R R R R R R R R R . . . . 
. . . . R R R R R R R R R R R R R R R R . . . . 
. . . . R R R R R R R R R R R R R R R R . . . . 
. . . . R R R R R R R R R R R R R R R R . . . . 
. . . . . R R R R R R R R R R R R R R . . . . . 
. . . . . R R R R R R R R R R R R R R . . . . . 
. . . . . . R R R R R R R R R R R R . . . . . . 
. . . . . . . R R R R R R R R R R . . . . . . . 
. . . . . . . . . R R R R R R . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . 
]])

tiles[0x0500]=[[
. . . . . . . . 
. . Y Y Y Y . . 
. Y Y 4 4 Y Y . 
. Y 4 Y Y 4 Y . 
. Y 4 Y Y 4 Y . 
. Y Y 4 4 Y Y . 
. . Y Y Y Y . . 
. . . . . . . . 
]]

maps[0]=[[
1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 
1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 
1 . . . . . . . . . . . . . . . . $ . . . . . . . . . . . . . . . . . . . . . . . . . ? . ? . ? . ? . . 1 
1 . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 1 
1 . . . . . . . . . . . . $ . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ? . . . . . . . 1 
1 . . . . $ . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 1 
1 . ? . . . . . . . . . . . . . . 1 1 1 1 1 1 1 1 1 1 . . . . . . . . . . . . . . . . . . . ? . ? . . . 1 
1 . . . ? . . . . . . . . . . . . . . . . . . . . . . . 1 . . . . . . . . . . . . . . . . . . . . . . . 1 
1 . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 1 
1 1 1 1 1 1 1 1 1 1 1 1 . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 1 
1 . . . . . . . . . . 1 . . ? . . . . . . . . . . . . . . . 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 
1 . . . . . . . . . . 1 . . . . . . . . . . . . . . . . . 1 . . . . . . . . . . . . . . . . . . . . . . 1 
1 . . . . . . . . . . 1 1 1 1 1 1 . . . . . . . . ? . . . 1 . . . . $ . . . . . . $ . . . . . . $ . . . 1 
1 . . . . . . . . . . . . . . . . . . . . . . . . . . . . 1 . . . . . . . . . . . . . . . . . . . . . . 1 
1 . . . . . . . . . . . . . . . . . . . . . . . 1 1 1 . . . . . . . . . . . 1 . . . . . 1 . . . . . . 1 1 
1 . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ? . ? . . . 1 . . . . . 1 . . . . . . 1 1 
1 . . . . . . . . . . . . . . . . . . . . . $ $ . . . . . . . . . . . . . . 1 . . . . . 1 . . . . . . 1 1 
1 . . . . . . . . . . . . . . . . . . . . . . . . . . . 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 
1 . . . . . . . . . . $ . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 1 
1 . . . . . . . . . . . . . . . . . . . . . . . . . 1 . . . . . . . . . . . . . . . . . . . . . . . . . 1 
1 . . . . . . . . . . . . . . . . . . . . . . . . 1 . . . . . . . . . . . . . . . . . . . . . . . . . . 1 
1 . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . $ . . . . . 1 
1 . . . . . . . . . . . . . . . . . . . . . . . 1 . . . . . . . . . . . . . . . . . . . . . . . . . . . 1 
1 . . . . . . . . . . . . . . . . . . . . . . 1 1 1 . . . . . ? . . . . . . . . . . . . . . . . . . . . 1 
1 . . . . . . . . . . . . . . . . . $ . . . . . 1 . . . . . . . . . . . . . . . . . . . . . . . . . . . 1 
1 . . . . 1 . . . . . 1 . . . . . . . . . 1 . . . . . . . . 1 1 1 . . . . $ . . . . . . . . . . . . . . 1 
1 . . . 1 1 . . . . . 1 . . . . . . . . . . . . . . . . . . 1 1 1 . . . . . . $ . . . . . . . . . . . . 1 
1 1 . . 1 1 . . . . 1 1 1 . . . . . 1 . . . . . . . . . . . 1 1 1 . . . . . . . . $ . . . . . . . . . . 1 
1 1 . . 1 1 . . . 1 1 1 1 1 . . . . 1 1 . . . . . . . . . . 1 1 1 . . . . . . . . . . . . . . . . . . . 1 
1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 
]]


function main(need)

	if not need.setup then need=coroutine.yield() end -- wait for setup request (should always be first call)

	local game_time=0
	local start_time -- set when we add a player
	local finish_time -- set when all loot is collected

-- cache components in locals for less typing
	local ctiles   = system.components.tiles
	local cfont    = system.components.font
	local ccopper  = system.components.copper
	local cmap     = system.components.map
	local csprites = system.components.sprites
	local ctext    = system.components.text

--	ccopper.shader_name="fun_copper_back_noise"


-- copy font data
	cfont.bitmap_grd:pixels(0,0,128*4,8, bitdown_font_4x8.grd_mask:pixels(0,0,128*4,8,"") )

-- copy image data
	bitdown.pixtab_tiles( tiles,    bitdown.cmap, ctiles   )

-- screen
	bitdown.pix_grd(    maps[0],  tilemap,      cmap.tilemap_grd  )--,0,0,48,32)


-- map for collision etc
	local map=bitdown.pix_tiles(  maps[0],  tilemap )
		
	local space=chipmunk.space()
	space:gravity(0,700)
	space:damping(0.5)

-- this stops sticky internal edges, probably breaks some other stuff...
--	space:collision_slop(0)
--	space:collision_bias(0)
--	space:iterations(10)
	
	local tile_get=function(x,y,member)
		local l=map[y] if not l then return false end -- outer space returns nil 
		local c=l[x] if not c then return false end
		if member then return c[member] else return c end -- return the tile or a member
	end

	local tile_cmp=function(x,y,member,value)
		local l=map[y] if not l then return true end -- outer space compares true with anything
		local c=l[x] if not c then return true end
		return (c[member]==value)
	end

	local tile_is_solid=function(x,y)
		local l=map[y] if not l then return true end -- outer space is solid
		local c=l[x] if not c then return true end
		return c.solid and true or false
	end
	
-- go through and flag x/y prefered link status of each solid tile

	for y,line in pairs(map) do for x,tile in pairs(line) do
		if tile.dense then
			tile.link=0
			tile.flow=0
			tile.coll="dense"
		elseif tile.solid then			
			tile.link=0
			tile.flow=0
			if tile_is_solid(x,y-1) or tile_is_solid(x,y+1) then -- a solid tile with another solid tile above/below becomes dense
				tile.coll="dense"
			else
				tile.coll="solid"
			end
		end
	end end

-- we use flow>0 for x strips and flow<0 for y strips ( flow==nil for an empty space )

	for y,line in pairs(map) do for x,tile in pairs(line) do
		if tile.flow then
			if not tile_cmp(x-1,y,"coll",tile.coll) then
				tile.flow=tile.flow-1
			end
			if not tile_cmp(x+1,y,"coll",tile.coll) then
				tile.flow=tile.flow-1
			end
			if not tile_cmp(x,y-1,"coll",tile.coll) then
				tile.flow=tile.flow+1
			end
			if not tile_cmp(x,y+1,"coll",tile.coll) then
				tile.flow=tile.flow+1
			end
		end
	end end

-- try and make y strips

	for y,line in pairs(map) do for x,tile in pairs(line) do
		if tile.flow then
			if tile.flow<0 and tile.link==0 then -- this tile really wants to link up/down so grab all tiles
				tile.link=-1
				for ny=y-1,0,-1 do
					local ts=tile_get(x,ny)
					if ts and ts.coll==tile.coll and ts.link==0 and tile.flow<=0 then -- one of us
						ts.link=-1
					else break end
				end
				for ny=y+1,#map,1 do
					local ts=tile_get(x,ny)
					if ts and ts.coll==tile.coll and ts.link==0 and tile.flow<=0 then -- one of us
						ts.link=-1
					else break end
				end
			end
		end
	end end

-- try and make x strips

	for y,line in pairs(map) do for x,tile in pairs(line) do
		if tile.flow then
			if tile.flow>0 and tile.link==0 then -- this tile really wants to link left/right so grab all tiles
				tile.link=1
				for nx=x-1,0,-1 do
					local ts=tile_get(nx,y)
					if ts and ts.coll==tile.coll and ts.link==0 and tile.flow>=0 then -- one of us
						ts.link=1
					else break end
				end
				for nx=x+1,#line,1 do
					local ts=tile_get(nx,y)
					if ts and ts.coll==tile.coll and ts.link==0 and tile.flow>=0 then -- one of us
						ts.link=1
					else break end
				end
			end
		end
	end end

-- glob the rest together any old how we can

	for y,line in pairs(map) do for x,tile in pairs(line) do
		if tile.flow then
			for _,d in ipairs{ {-1,0,1} , {1,0,1} , {0,-1,-1} , {0,1,-1} } do
				if tile.link==0 then
					local ts=tile_get(x+d[1],y+d[2])
					if ts and ts.coll==tile.coll and ts.link==0 or ts.link==d[3] then
						tile.link=d[3]
						ts.link=d[3]
					end
				end
			end
		end
	end end

-- set parents / child of each strip. The parent is the tile that will generate a collision strip

	for y,line in pairs(map) do for x,tile in pairs(line) do
		if tile.link==1 then
			local ts=tile_get(x-1,y)
			if ts and ts.coll==tile.coll and ts.link==1 then
				tile.parent=ts
				ts.child=tile
			end
		end
		if tile.link==-1 then
			local ts=tile_get(x,y-1)
			if ts and ts.coll==tile.coll and ts.link==-1 then
				tile.parent=ts
				ts.child=tile
			end
		end
	end end


--debug dump of collision links
--[[
	for y,line in pairs(map) do
		local s=""
		for x,tile in pairs(line) do
			if not tile.parent then
				if     tile.link== 1 then s=s.."X "
				elseif tile.link==-1 then s=s.."Y "
				elseif tile.link== 0 then s=s.."0 "
				else                      s=s..". "
				end
			else
				if     tile.link== 1 then s=s.."x "
				elseif tile.link==-1 then s=s.."y "
				elseif tile.link== 0 then s=s.."o "
				else                      s=s..". "
				end
			end
		end
		print(s)
	end
]]

-- build each collision strip

	for y,line in pairs(map) do
		for x,tile in pairs(line) do
			if tile.solid and (not tile.parent) then
			
				local l=1
				local t=tile
				while t.child do t=t.child l=l+1 end -- count lemgth of strip

				local shape
				
				if     tile.link==1 then 
					shape=space.static:shape("box",x*8,y*8,(x+l)*8,(y+1)*8,0)
				elseif tile.link==-1 then 
					shape=space.static:shape("box",x*8,y*8,(x+1)*8,(y+l)*8,0)
				else
					shape=space.static:shape("box",x*8,y*8,(x+1)*8,(y+1)*8,0)
				end

				shape:friction(tile.solid)
				shape:elasticity(tile.solid)
				shape.cx=x
				shape.cy=y
				shape.coll=tile.coll
				if tile.coll~="dense" then 
					shape:collision_type(0x1001) -- a tile we can jump up through
				end
			end
		end
	end

	space:add_handler({
		presolve=function(it)

--print(wstr.dump(it))
			local points=it:points()

-- once we trigger headroom, we keep a table of headroom shapes and it is not reset until total separation
			if it.shape_b.in_body.headroom then
				local headroom=false
				for n,v in pairs(it.shape_b.in_body.headroom) do headroom=true break end -- still touching an old headroom shape?
				if ( (points.normal_y>0) or headroom) then -- can only headroom through non dense tiles
					it.shape_b.in_body.headroom[it.shape_a]=true
					return it:ignore()
				end
			end
			
			return true
		end,
		separate=function(it)
			if it.shape_b.in_body.headroom then it.shape_b.in_body.headroom[it.shape_a]=nil end
		end
	},0x1001) -- background tiles we can jump up through

	space:add_handler({
		postsolve=function(it)
			local points=it:points()
			if points.normal_y>0.25 then -- on floor
				it.shape_a.in_body.floor_time=game_time
				it.shape_a.in_body.floor=it.shape_b
			end
			return true
		end,
	},0x2001) -- walking things (players)

	space:add_handler({
		presolve=function(it)
			if it.shape_a.loot and it.shape_b.player then -- trigger collect
				it.shape_a.loot.player=it.shape_b.player
			end
			return false
		end,
	},0x3001) -- loot things (pickups)
	
	local loots={}
	local items={}
	for y,line in pairs(map) do
		for x,tile in pairs(line) do

			if tile.loot then
				local loot={}
				loots[#loots+1]=loot

				local shape=space.static:shape("box",x*8,y*8,(x+1)*8,(y+1)*8,0)
				shape:collision_type(0x3001)
				shape.loot=loot
				loot.shape=shape
				loot.px=x*8+4
				loot.py=y*8+4
				loot.active=true
			end
			if tile.item then
				local item={}
				items[#items+1]=item
				
				item.sprite=names.cannon_ball

				item.active=true
				item.body=space:body(2,2)
				item.body:position(x*8+4,y*8+4)

				item.shape=item.body:shape("circle",8,0,0)
				item.shape:friction(0.5)
				item.shape:elasticity(0.5)

			end
		end
	end

	local players={}
	local players_colors={30,14,18,7,3,22}
	
	for i=1,6 do
		local p={}
		players[i]=p
		p.idx=i
		p.score=0
		
		local t=bitdown.map[ players_colors[i] ]
		p.color={}
		p.color.r=t[1]/255
		p.color.g=t[2]/255
		p.color.b=t[3]/255
		p.color.a=t[4]/255
		
		p.up_text_x=math.ceil( (ctext.tilemap_hx/8)*( i>3 and i+1 or i ) )

		p.join=function()
			
			p.active=true
			p.body=space:body(1,math.huge)
			p.body:position(50+i,200)
			p.body.headroom={}
			
			p.frame=0
			p.frames={0x0200,0x0203,0x0200,0x0206}

			p.shape=p.body:shape("segment",0,-4,0,4,4)
			p.shape:friction(1)
			p.shape:elasticity(0)
			p.shape:collision_type(0x2001) -- walker
			p.shape.player=p
			
			p.body.floor_time=0
			if not start_time then start_time=game_time end -- when the game started
		end
	end
	
-- after setup we should yield and then perform updates only if requested from yield
	local done=false while not done do
		need=coroutine.yield()
		if need.update then
		
			for _,p in ipairs(players) do
				local up=ups(p.idx) -- the controls for this player
				
				if not p.active then
					if --[[up.button("up") or up.button("down") or up.button("left") or up.button("right") or]] up.button("fire") then
						p:join()
					end
				end
				
				if p.active then
				
					local speed=60
					local drift=20
					
					if game_time-p.body.floor_time < 0.125 then -- floor available recently

						p.shape:friction(1)

						if --[[up.button("up") or]] up.button("fire") then

							local vx,vy=p.body:velocity()

							if vy>-20 then

								vy=-200
								p.body:velocity(vx,vy)
								
								p.body.floor_time=0
								
							end

						end

						if up.button("left") then
							
							local vx,vy=p.body:velocity()
							if vx>0 then p.body:velocity(0,vy) end
							
							p.shape:surface_velocity(speed,0)
							if vx>-speed then p.body:apply_force(-speed,0,0,0) end
							p.dir=-1
							p.frame=p.frame+1
							
						elseif  up.button("right") then

							local vx,vy=p.body:velocity()
							if vx<0 then p.body:velocity(0,vy) end

							p.shape:surface_velocity(-speed,0)
							if vx<speed then p.body:apply_force(speed,0,0,0) end
							p.dir= 1
							p.frame=p.frame+1

						else

							p.shape:surface_velocity(0,0)

						end
						
					else -- in air

						p.shape:friction(0)

						if up.button("left") then
							
							local vx,vy=p.body:velocity()
							if vx>0 then p.body:velocity(0,vy) end

							if vx>-speed then p.body:apply_force(-speed,0,0,0) end
							p.shape:surface_velocity(speed,0)
							p.dir=-1
							p.frame=p.frame+1
							
						elseif  up.button("right") then

							local vx,vy=p.body:velocity()
							if vx<0 then p.body:velocity(0,vy) end

							if vx<speed then p.body:apply_force(speed,0,0,0) end
							p.shape:surface_velocity(-speed,0)
							p.dir= 1
							p.frame=p.frame+1

						else

							p.shape:surface_velocity(0,0)

						end

					end

--					local vx,vy=p.body:velocity(vx,vy)
--					if vx<-1 then p.dir=-1 end
--					if vx> 1 then p.dir= 1 end

				end
			end
			
			space:step(1/fps)
--			space:step(0.25/fps)
--			space:step(0.25/fps)
--			space:step(0.25/fps)
--			space:step(0.25/fps)
			game_time=game_time+1/fps

--			ctext.px=(ctext.px+1)%360 -- scroll text position
			
		end
		if need.draw then
		
			ctext.tilemap_grd:clear(0)

			local t=start_time and ( (finish_time or game_time) - ( start_time ) ) or 0
			local ts=math.floor(t)
			local tp=math.floor((t%1)*100)

			local s=string.format("%d.%02d",ts,tp)
			ctext.text_print(s,math.floor((ctext.tilemap_hx-#s)/2),0)

			csprites.list_reset()
			for _,p in ipairs(players) do
				if p.active then
					local px,py=p.body:position()
					local rz=p.body:angle()
					p.frame=p.frame%16
					local t=p.frames[1+math.floor(p.frame/4)]
					
					csprites.list_add({t=t,h=24,px=px,py=py,sx=p.dir,sy=1,rz=180*rz/math.pi,r=p.color.r,g=p.color.g,b=p.color.b,a=p.color.a})


					local s=string.format("%d",p.score)
					ctext.text_print(s,math.floor(p.up_text_x-(#s/2)),0)
					
				end
			end
			for _,item in ipairs(items) do
				if item.active then
					local px,py=item.body:position()
					local rz=item.body:angle()
					rz=0
					csprites.list_add({t=item.sprite,h=24,px=px,py=py,rz=180*rz/math.pi})
				end
			end
			local remain=0
			for _,loot in ipairs(loots) do
				if loot.active then
					remain=remain+1
					
					local b=math.sin( (game_time*8 + (loot.px+loot.py)/16 ) )*2

					csprites.list_add({t=0x0500,h=8,px=loot.px,py=loot.py+b})
					
					if loot.player then
						loot.player.score=loot.player.score+1
						loot.active=false
						space:remove(loot.shape)
					end
				end
			end
			if remain==0 and not finish_time then -- done
				finish_time=game_time
			end
		end
		if need.clean then done=true end -- cleanup requested
	end

-- perform cleanup here


end
