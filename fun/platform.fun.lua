
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
1414121212121414
1414121212121414
1313131315151515
1313131315151515
1212141414141212
1212141414141212
1515151513131313
1515151513131313
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
000000000000000000000000000000000000000000000000
000000000000000000001C1C1C1C00000000000000000000
0000000000000000001C1A1F1F191C000000000000000000
0000000000000000001C1F1A191F1C000000000000000000
00000000000000001C1F1F191A1F1F1C0000000000000000
000000000000001C1F1F191F1F1A1F1F1C00000000000000
000000000000001C1C1C1C1C1C1C1C1C1C00000000000000
000000000000000000001F1F181F00000000000000000000
000000000000000000001F1F1F1F1F000000000000000000
000000000000000000001F1F1F1F00000000000000000000
00000000000000000000001F1F0000000000000000000000
000000000000000000001F1F1F1F00000000000000000000
0000000000000000001F1F1F1F1F1F000000000000000000
0000000000000000001F1F1F1F1F1F000000000000000000
00000000000000001F1F1F1F001F1F1F0000000000000000
00000000000000001F1F1F1F1F001F1F0000000000000000
000000000000000000001F1F1F1F00000000000000000000
0000000000000000001F1F1F001F1F000000000000000000
0000000000000000001F1F001F1F1F000000000000000000
0000000000000000001F1F1F001F1F1F0000000000000000
000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000
]]
tiles[0x0203]=[[
000000000000000000000000000000000000000000000000
000000000000000000001C1C1C1C00000000000000000000
0000000000000000001C1A1F1F191C000000000000000000
0000000000000000001C1F1A191F1C000000000000000000
00000000000000001C1F1F191A1F1F1C0000000000000000
000000000000001C1F1F191F1F1A1F1F1C00000000000000
000000000000001C1C1C1C1C1C1C1C1C1C00000000000000
000000000000000000001F1F181F00000000000000000000
000000000000000000001F1F1F1F1F000000000000000000
000000000000000000001F1F1F1F00000000000000000000
00000000000000000000001F1F0000000000000000000000
000000000000000000001F1F1F1F00000000000000000000
0000000000000000001F1F001F1F1F000000000000000000
0000000000000000001F1F001F1F1F000000000000000000
0000000000000000001F1F001F1F1F000000000000000000
0000000000000000001F1F1F001F1F000000000000000000
000000000000000000001F1F1F1F00000000000000000000
00000000000000000000001F1F0000000000000000000000
00000000000000000000001F1F0000000000000000000000
00000000000000000000001F1F1F00000000000000000000
000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000
]]
tiles[0x0206]=[[
000000000000000000000000000000000000000000000000
000000000000000000001C1C1C1C00000000000000000000
0000000000000000001C1A1F1F191C000000000000000000
0000000000000000001C1F1A191F1C000000000000000000
00000000000000001C1F1F191A1F1F1C0000000000000000
000000000000001C1F1F191F1F1A1F1F1C00000000000000
000000000000001C1C1C1C1C1C1C1C1C1C00000000000000
000000000000000000001F1F181F00000000000000000000
000000000000000000001F1F1F1F1F000000000000000000
000000000000000000001F1F1F1F00000000000000000000
00000000000000000000001F1F0000000000000000000000
000000000000000000001F1F1F1F00000000000000000000
0000000000000000001F1F1F1F1F1F000000000000000000
00000000000000001F1F1F1F1F1F1F1F0000000000000000
000000000000001F1F1F1F1F1F1F1F1F1F00000000000000
000000000000001F1F001F1F1F1F001F1F00000000000000
000000000000000000001F1F1F1F1F000000000000000000
0000000000000000001F1F1F001F1F001F00000000000000
00000000000000001F1F000000001F1F1F00000000000000
00000000000000001F1F1F0000001F1F0000000000000000
000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000
]]
set_name_tile("cannon_ball",0x0209,[[
000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000
000000000000000000001414141400000000000000000000
000000000000001214141414141414141200000000000000
000000000000121212141414141414121212000000000000
000000000012121212141414141414121212120000000000
00000000001D121212121414141412121212060000000000
00000000001D1D1D12121414141412120606060000000000
000000001D1D1D1D1D1D1218181206060606060600000000
000000001D1D1D1D1D1D1818181806060606060600000000
000000001D1D1D1D1D1D1818181806060606060600000000
000000001D1D1D1D1D1D1218181206060606060600000000
00000000001D1D1D12121515151512120606060000000000
00000000001D121212121515151512121212060000000000
000000000012121212151515151515121212120000000000
000000000000121212151515151515121212000000000000
000000000000001215151515151515151200000000000000
000000000000000000001515151500000000000000000000
000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000
]])

tiles[0x0500]=[[
0000000000000000
0000161616160000
0016161818161600
1616181616181616
1616161818161616
1616181616181616
0016161818161600
0000161616160000
]]

set_name_tile("body_p1",0x0600,[[
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
0000000000001C1C1C1C000000000000
00000000001C1A1F1F191C0000000000
00000000001C1F1A191F1C0000000000
000000001C1F1F191A1F1F1C00000000
0000001C1F1F191F1F1A1F1F1C000000
0000001C1C1C1C1C1C1C1C1C1C000000
0000000000001F1F181F000000000000
0000000000001F1F1F1F1F0000000000
0000000000001F1F1F1F000000000000
000000000000001C1C00000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
]])

set_name_tile("body_p2",0x0602,[[
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
000000000000001C1C00000000000000
0000000000001F1F1F1F000000000000
00000000001F1F1F1F1F1F0000000000
000000001F1F1F1F1F1F1F1F00000000
0000001F1F1F1C1C1C1C1F1F1F000000
0000001F1F001C1C1C1C001F1F000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
]])

set_name_tile("body_p3",0x0604,[[
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
0000000000001C1C1C1C000000000000
0000000000001F1F1F1F1F0000000000
00000000001F1F1F001F1F001F000000
000000001F1F000000001F1F1F000000
000000001F1F1F0000001F1F00000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
]])

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

-- mess around with low level setting that should not be messed with
--	space:collision_slop(0)
--	space:collision_bias(0)
--	space:iterations(10)
	

-- build collision strips for each tile with a solid or dense member
-- dense will be added for solid tiles that should be dense ( dense means can not jump up through)
	bitdown.map_build_collision_strips(map,function(tile)
		if tile.coll then -- can break the collision types up some more by appending a code to this
		end
	end)

	for y,line in pairs(map) do
		for x,tile in pairs(line) do
			if tile.solid and (not tile.parent) then -- if we have no parent then we are the master tile
			
				local l=1
				local t=tile
				while t.child do t=t.child l=l+1 end -- count length of strip

				local shape
				
				if     tile.link==1 then -- x strip
					shape=space.static:shape("box",x*8,y*8,(x+l)*8,(y+1)*8,0)
				elseif tile.link==-1 then  -- y strip
					shape=space.static:shape("box",x*8,y*8,(x+1)*8,(y+l)*8,0)
				else -- single box
					shape=space.static:shape("box",x*8,y*8,(x+1)*8,(y+1)*8,0)
				end

				shape:friction(tile.solid)
				shape:elasticity(tile.solid)
				shape.cx=x
				shape.cy=y
				shape.coll=tile.coll
				if not tile.dense then 
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

				end
			end
			
			space:step(1/fps)
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
--					rz=0
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
