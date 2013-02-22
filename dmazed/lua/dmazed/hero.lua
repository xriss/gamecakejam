-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local wstr=require("wetgenes.string")

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,hero)
	hero=hero or {}
	
	local cake=oven.cake
	local opts=oven.opts
	local canvas=cake.canvas
	
	local font=canvas.font
	local flat=canvas.flat
	local sheets=cake.sheets
	
	local gl=oven.gl

	hero.modname=M.modname

	local cells=oven.rebake("dmazed.cells")
	local main=oven.rebake("dmazed.main")
	local menu=oven.rebake("dmazed.main_menu")
	local game=oven.rebake("dmazed.main_game")
		
	local beep=oven.rebake("dmazed.beep")
	local wscores=oven.rebake("wetgenes.gamecake.spew.scores")


	local movedirs={
		{name="left",	vx=-1,vy= 0,dir=1},
		{name="right",	vx= 1,vy= 0,dir=2},
		{name="up",		vx= 0,vy=-1,dir=3},
		{name="down",	vx= 0,vy= 1,dir=4},
		}
	for i,v in ipairs(movedirs) do movedirs[v.name]=v end


hero.loads=function()

--	oven.cake.fonts.loads({1}) -- load 1st builtin font, a basic 8x8 font	

	
end

hero.setup=function()
	hero.x=0
	hero.y=0
	hero.block=cells.blocks[1]
	hero.lastmove=movedirs[1]
end

hero.clean=function()
end

	
hero.update=function()

	if hero.move then
		local m=movedirs[hero.move]
		local d
		
		if not hero.block.links[m.dir] then
			m=hero.lastmove
		end

		if m then
		if ( m.vy~=0 and hero.block.links[m.dir] ) or ( ( m.vy<0 and hero.y>0 ) or ( m.vy>0 and hero.y<0 ) ) then
			if hero.x > 2 then
				d=movedirs.left
			elseif hero.x < -2 then
				d=movedirs.right
			else
				hero.x=0
				d=m
				hero.lastmove=m
			end
		elseif  ( m.vx~=0 and hero.block.links[m.dir] ) or ( ( m.vx<0 and hero.x>0 ) or ( m.vx>0 and hero.x<0 ) ) then
			if hero.y > 2 then
				d=movedirs.up
			elseif hero.y < -2 then
				d=movedirs.down
			else
				hero.y=0
				d=m
				hero.lastmove=m
			end
		end
		end
		
		if d then -- perform valid move
			hero.x=hero.x+(d.vx*2)
			hero.y=hero.y+(d.vy*2)
		end
	end
	
	if hero.lastmove.vx<0 and hero.x<0 and hero.block.links[1] then
		hero.x=hero.x+48
		hero.block=hero.block.links[1]
	end
	if hero.lastmove.vx>0 and hero.x>0 and hero.block.links[2] then
		hero.x=hero.x-48
		hero.block=hero.block.links[2]
	end
	if hero.lastmove.vy<0 and hero.y<0 and hero.block.links[3] then
		hero.y=hero.y+48
		hero.block=hero.block.links[3]
	end
	if hero.lastmove.vy>0 and hero.y>0 and hero.block.links[4] then
		hero.y=hero.y-48
		hero.block=hero.block.links[4]
	end
	
	
	
end

hero.draw=function()
	local sheet=sheets.get("imgs/hero")
	
	local x=48+(hero.block.x-1)*48
	local y=48+(hero.block.y-1)*48
	sheet:draw(1,x+hero.x,y+hero.y,nil,32+8,32+8)
end

	return hero
end

