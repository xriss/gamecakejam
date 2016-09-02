
local wstr=require("wetgenes.string")
local wgrd=require("wetgenes.grd")
local tardis=require("wetgenes.tardis")	-- matrix/vector math

local bitdown=require("wetgenes.gamecake.fun.bitdown")
local bitdown_font_4x8=require("wetgenes.gamecake.fun.bitdown_font_4x8")



local hx,hy,ss=360,240,3

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
	["1 "]={  1,  0,  0,  0},
	["2 "]={  2,  0,  0,  0},
	["3 "]={  3,  0,  0,  0},
	["4 "]={  4,  0,  0,  0},
	["5 "]={  5,  0,  0,  0},
	["6 "]={  6,  0,  0,  0},
	["7 "]={  7,  0,  0,  0},
	["8 "]={  8,  0,  0,  0},
	["9 "]={  9,  0,  0,  0},
	["A "]={ 10,  0,  0,  0},
	["B "]={ 11,  0,  0,  0},
	["C "]={ 12,  0,  0,  0},
	["D "]={ 13,  0,  0,  0},
	["E "]={ 14,  0,  0,  0},
	["F "]={ 15,  0,  0,  0},
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

sprites[0]=[[
. . . . . . . 7 7 . . . . . . 7 7 . . . . . . . 
. . . . . . . 7 7 . . . . . . 7 7 . . . . . . . 
. . . . . . . 7 7 . . . . . . 7 7 . . . . . . . 
. . . . . . . 7 7 . . . . . . 7 7 . . . . . . . 
. . . . . . . 7 7 . . . . . . 7 7 . . . . . . . 
. . . . . . . 7 7 . . . . . . 7 7 . . . . . . . 
. . . . . . . 7 7 . . . . . . 7 7 . . . . . . . 
7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 
7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 
. . . . . . . 7 7 . . . . . . 7 7 . . . . . . . 
. . . . . . . 7 7 . . . . . . 7 7 . . . . . . . 
. . . . . . . 7 7 . . . . . . 7 7 . . . . . . . 
. . . . . . . 7 7 . . . . . . 7 7 . . . . . . . 
. . . . . . . 7 7 . . . . . . 7 7 . . . . . . . 
. . . . . . . 7 7 . . . . . . 7 7 . . . . . . . 
7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 
7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 7 
. . . . . . . 7 7 . . . . . . 7 7 . . . . . . . 
. . . . . . . 7 7 . . . . . . 7 7 . . . . . . . 
. . . . . . . 7 7 . . . . . . 7 7 . . . . . . . 
. . . . . . . 7 7 . . . . . . 7 7 . . . . . . . 
. . . . . . . 7 7 . . . . . . 7 7 . . . . . . . 
. . . . . . . 7 7 . . . . . . 7 7 . . . . . . . 
. . . . . . . 7 7 . . . . . . 7 7 . . . . . . . 
]]

maps[0]=[[
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
. . . . . 1 . . . . . 3 . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
. . . . 1 1 . . . . . 1 . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .  
. 1 . . 1 1 . . . . 1 1 1 . . . . . 1 . . . . . . . . . . . . . . . . . . . . . . . . . .  
. 1 . . 1 1 . . . 1 1 2 1 1 . . . . 1 1 . . . . . . . . . . . . . . . . . . . . . . . . .  
1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 
]]



function main(need)

	if not need.setup then need=coroutine.yield() end -- wait for setup request (should always be first call)


-- cache components in locals for less typing
	local ccopper  = system.components.copper
	local ctiles   = system.components.tiles
	local csprites = system.components.sprites
	local ctext    = system.components.text

--	ccopper.shader_name="fun_copper_back_noise"


-- copy font data
	ctext.bitmap_grd:pixels(0,0,128*4,8, bitdown_font_4x8.grd_mask:pixels(0,0,128*4,8,"") )

-- copy image data
	bitdown.pixtab_grd( tiles,    bitdown.cmap, ctiles.bitmap_grd   )
	bitdown.pixtab_grd( sprites,  bitdown.cmap, csprites.bitmap_grd )

-- screen
	bitdown.pix_grd(    maps[0],  tilemap,      ctiles.tilemap_grd  )--,0,0,48,32)
	
-- test text
	local tx=[[
Fun is the enjoyment of pleasure, particularly in leisure activities. Fun is an experience - short-term, often unexpected, informal, not cerebral and generally purposeless. It is an enjoyable distraction, diverting the mind and body from any serious task or contributing an extra dimension to it. Although particularly associated with recreation and play, fun may be encountered during work, social functions, and even seemingly mundane activities of daily living. It may often have little to no logical basis, and opinions on whether or not an activity is fun may differ. A distinction between enjoyment and fun is difficult but possible to articulate, fun being a more spontaneous, playful, or active event. There are psychological and physiological implications to the experience of fun.]]
	local tl=wstr.smart_wrap(tx,ctext.text_hx)
	for i=0,ctext.tilemap_hy-1 do
		local t=tl[i+1]
		if not t then break end
		ctext.text_print(t,0,i)
	end
	
	ccopper.shader_name="fun_copper_back_wave"

-- after setup we should yield and then perform updates only if requested from yield
	local done=false while not done do
		need=coroutine.yield()
		if need.update then

			ctext.px=(ctext.px+1)%360 -- scroll text position
			
			csprites.list_reset()
			csprites.list_add({t=0,h=24,px=100,py=100,rz=ctext.px})

		end
		if need.clean then done=true end -- cleanup requested
	end

-- perform cleanup here


end
