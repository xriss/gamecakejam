
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
		fps=fps,
	},
	{
		component="copper",
		name="copper",
		size={hx,hy},
	},
	{
		component="tilemap",
		name="tiles",
		tile_size={8,8},
		bitmap_size={16,16},
		tilemap_size={math.ceil(hx/8),math.ceil(hy/8)},
	},
	{
		component="sprites",
		name="sprites",
		tile_size={8,8},
		bitmap_size={16,16},
	},
	{
		component="tilemap",
		name="text",
		tile_size={4,8},
		bitmap_size={128,4},
		tilemap_size={math.ceil(hx/4),math.ceil(hy/8)},
	},
}


local tiles={}
local sprites={}
local maps={}

local tilemap={
	[0]={0,0,0,0},

	[". "]={  0,  0,  0,  0},
	["1 "]={  1,  0,  0,  0,	solid=1, really_solid=1},
	["2 "]={  2,  0,  0,  0,	solid=1},
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


tiles[0]=[[
. . . . . . . . 
. . . . . . . . 
. . . . . . . . 
. . . . . . . . 
. . . . . . . . 
. . . . . . . . 
. . . . . . . . 
. . . . . . . . 
]]
tiles[1]=[[
1 1 1 1 1 1 1 1 
1 1 1 1 1 1 1 1 
1 1 1 1 1 1 1 1 
1 1 1 1 1 1 1 1 
1 1 1 1 1 1 1 1 
1 1 1 1 1 1 1 1 
1 1 1 1 1 1 1 1 
1 1 1 1 1 1 1 1 
]]
tiles[2]=[[
2 2 2 2 2 2 2 2 
2 2 2 2 2 2 2 2 
2 2 2 2 2 2 2 2 
2 2 2 2 2 2 2 2 
2 2 2 2 2 2 2 2 
2 2 2 2 2 2 2 2 
2 2 2 2 2 2 2 2 
2 2 2 2 2 2 2 2 
]]
tiles[3]=[[
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

sprites[0x0000]=[[
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
sprites[0x0001]=[[
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
sprites[0x0002]=[[
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

sprites[0x0003]=[[
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
]]

sprites[0x0300]=[[
. . . . . . . . 
. . Y Y Y Y . . 
. Y Y 7 7 Y Y . 
. Y 7 Y Y 7 Y . 
. Y 7 Y Y 7 Y . 
. Y Y 7 7 Y Y . 
. . Y Y Y Y . . 
. . . . . . . . 
]]

maps[0]=[[
1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 
1 . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 1 
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
1 . . . . . . . . . . . . . . . . . . . . . . 1 1 1 . . . . . . . . . . . . . . . . . . . . . . . . . . 1 
1 . . . . . . . . . . . . . . . . . $ . . . . . 1 . . . . . . . . . . . . . . . . . . . . . . . . . . . 1 
1 . . . . 1 . . . . . 1 . . . . . . . . . 1 . . . . . . . . . ? . . . . . $ . . . . . . . . . . . . . . 1 
1 . . . 1 1 . . . . . 1 . . . . . . . . . . . . . . . . . . . . . . . . . . . $ . . . . . . . . . . . . 1  
1 1 . . 1 1 . . . . 1 1 1 . . . . . 1 . . . . . . . . . . . 1 1 1 . . . . . . . . $ . . . . . . . . . . 1  
1 1 . . 1 1 . . . 1 1 1 1 1 . . . . 1 1 . . . . . . . . . . 1 1 1 . . . . . . . . . . . . . . . . . . . 1 
1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 
]]



function main(need)

	if not need.setup then need=coroutine.yield() end -- wait for setup request (should always be first call)

-- cache components in locals for less typing
	local ccopper  = system.components.copper
	local ctiles   = system.components.tiles
	local csprites = system.components.sprites
	local ctext    = system.components.text



	local game_time=0
	local start_time -- set when we add a player
	local finish_time -- set when all loot is collected

--	ccopper.shader_name="fun_copper_back_noise"


-- copy font data
	ctext.bitmap_grd:pixels(0,0,128*4,8, bitdown_font_4x8.grd_mask:pixels(0,0,128*4,8,"") )
	ctext.py=-1 --better y spaceing of text

-- copy image data
	bitdown.pixtab_grd( tiles,    bitdown.cmap, ctiles.bitmap_grd   )
	bitdown.pixtab_grd( sprites,  bitdown.cmap, csprites.bitmap_grd )

-- screen
	bitdown.pix_grd(    maps[0],  tilemap,      ctiles.tilemap_grd  )--,0,0,40,30)--,0,0,48,32)

-- map for collision etc
	local map=bitdown.pix_tiles(  maps[0],  tilemap )
			
	local space=chipmunk.space()
	space:gravity(0,700)
	space:damping(0.5)

-- this stops sticky internal edges, probably breaks some other stuff...
	space:collision_slop(0.1)
	space:collision_bias(0)
	space:iterations(10)
	
	local tile_is_sold=function(x,y)
		local l=map[y] if not l then return false end
		local c=l[x] if not c then return false end
		if c.solid then return true end
		return false
	end
	
	for y,line in pairs(map) do
		for x,tile in pairs(line) do

			if tile.solid then
				local flags=0
				if not tile_is_sold(x-1,y) then flags=flags+1 end
				if not tile_is_sold(x,y-1) then flags=flags+2 end
				if not tile_is_sold(x+1,y) then flags=flags+4 end
				if not tile_is_sold(x,y+1) then flags=flags+8 end

				if flags~=0 then -- ignore enclosed solids
				
					local shape=space.static:shape("box",x*8,y*8,(x+1)*8,(y+1)*8,0)
--					local shape=space.static:shape("box",x*8-1,y*8-1,(x+1)*8+1,(y+1)*8+1,0)
					shape:friction(tile.solid)
					shape:elasticity(tile.solid)
					shape:filter(0,flags,0xffffffff) -- we use 4 bits to mark soft edges 
					shape:collision_type(0x1001) -- used for softedge tiles
					shape.cx=x
					shape.cy=y
				end
			end

		end
	end
	space:add_handler({
		presolve=function(it)

--print(wstr.dump(it))
			local points=it:points()

			local _,flags,_=it.shape_a:filter()
			local n=tardis.v2.new(points.normal_x,points.normal_y)

-- one we trigger headroom, we keep a table of headroom shapes and it is not reset until total separation
			if it.shape_b.in_body.headroom then
				local headroom=false
				for n,v in pairs(it.shape_b.in_body.headroom) do headroom=true break end -- still touching an old headroom shape?
				if ( (n[2]>0) or headroom) and bit.band(flags,2)==2 then -- can only headroom through these tiles
					it.shape_b.in_body.headroom[it.shape_a]=true
					return it:ignore()
				end
			end
			
--			print("presolve",flags,it.shape_a,it.shape_b,it.normal_x,it.normal_y)

			if bit.band(flags,1)==0 then if n[1]<=0 then n[1]=0 end end
			if bit.band(flags,2)==0 then if n[2]<=0 then n[2]=0 end	end
			if bit.band(flags,4)==0 then if n[1]>=0 then n[1]=0 end end
			if bit.band(flags,8)==0 then if n[2]>=0 then n[2]=0 end end
			
			if n:len()<1/256 then return false end -- give up
		
			n:normalize()

			points.normal_x=n[1]
			points.normal_y=n[2]

			it:points(points)

			return true
		end,
		separate=function(it)
			if it.shape_b.in_body.headroom then it.shape_b.in_body.headroom[it.shape_a]=nil end
		end
	},0x1001) -- softedge tiles

	space:add_handler({
		postsolve=function(it)
			local points=it:points()
			if points.normal_y>0.75 then -- on floor
				it.shape_a.in_body.floor_time=game_time
			end
			return true
		end,
	},0x2001) -- walking things

	space:add_handler({
		presolve=function(it)
			if it.shape_a.loot and it.shape_b.player then -- trigger collect
				it.shape_a.loot.player=it.shape_b.player
			end
			return false
		end,
	},0x3001) -- loot things
	
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
				
				item.sprite=0x0003

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
			p.frames={0x0000,0x0001,0x0000,0x0002}

			p.shapes={}
--			p.shapes[1]=p.body:shape("circle",3,0,-5)
--			p.shapes[2]=p.body:shape("circle",3,0, 0)
--			p.shapes[3]=p.body:shape("circle",3,0, 5)
			p.shapes[1]=p.body:shape("box",-3,-8,3,8,0)

			for i,v in ipairs(p.shapes) do
				v:friction(0.0)
				v:elasticity(0.0)
				v:collision_type(0x2001) -- walker
				v.player=p
			end
			
			p.body.floor_time=0
			if not start_time then start_time=game_time end -- when the game started
		end
	end
	
-- after setup we should yield and then perform updates only if requested from yield
	local done=false while not done do
		need=coroutine.yield()
		if need.update then
		
			for _,p in ipairs(players) do
				local up=ups(p.idx) -- controls
				
				if not p.active then
					if --[[up.button("up") or up.button("down") or up.button("left") or up.button("right") or]] up.button("fire") then
						p:join()
					end
				end
				
				if p.active then
				
					local speed=60
					
					if game_time-p.body.floor_time < 0.125 then -- floor available recently

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
							if vx>0 then vx=0 elseif vx>-speed then vx=vx-12 end
							p.body:velocity(vx,vy)
							p.dir=-1
							for i,v in ipairs(p.shapes) do v:friction(0) end
							p.frame=p.frame+1
							
						elseif  up.button("right") then

							local vx,vy=p.body:velocity()
							if vx<0 then vx=0 elseif vx<speed then vx=vx+12 end
							p.body:velocity(vx,vy)
							p.dir= 1
							for i,v in ipairs(p.shapes) do v:friction(0) end
							p.frame=p.frame+1

						else

							for i,v in ipairs(p.shapes) do v:friction(1) end

						end
						
					else -- in air

						if up.button("left") then
							
							local vx,vy=p.body:velocity()
							if vx>0 then vx=0 elseif vx>-speed then vx=vx-3 end
							p.body:velocity(vx,vy)
							p.dir=-1
							for i,v in ipairs(p.shapes) do v:friction(0) end
							p.frame=p.frame+1
							
						elseif  up.button("right") then

							local vx,vy=p.body:velocity()
							if vx<0 then vx=0 elseif vx<speed then vx=vx+3 end
							p.body:velocity(vx,vy)
							p.dir= 1
							for i,v in ipairs(p.shapes) do v:friction(0) end
							p.frame=p.frame+1

						else

							for i,v in ipairs(p.shapes) do v:friction(1) end

						end

					end

--					local vx,vy=p.body:velocity(vx,vy)
--					if vx<-1 then p.dir=-1 end
--					if vx> 1 then p.dir= 1 end

				end
			end
			
--			space:step(1/60)
			space:step(0.25/fps)
			space:step(0.25/fps)
			space:step(0.25/fps)
			space:step(0.25/fps)
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

					csprites.list_add({t=0x0300,h=8,px=loot.px,py=loot.py+b})
					
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
