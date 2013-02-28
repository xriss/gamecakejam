-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local wstr=require("wetgenes.string")

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,monster)
	monster=monster or {}
	
	local cake=oven.cake
	local opts=oven.opts
	local canvas=cake.canvas
	
	local font=canvas.font
	local flat=canvas.flat
	local sheets=cake.sheets
	
	local gl=oven.gl

	monster.modname=M.modname

	local cells=oven.rebake("dmazed.cells")
	local main=oven.rebake("dmazed.main")
	local menu=oven.rebake("dmazed.main_menu")
	local game=oven.rebake("dmazed.main_game")
	local hero=oven.rebake("dmazed.hero")
		
	local beep=oven.rebake("dmazed.beep")
	local wscores=oven.rebake("wetgenes.gamecake.spew.scores")

	local wgui=oven.rebake("wetgenes.gamecake.spew.gui")
	local gui=oven.rebake("dmazed.gui")


	local movedirs={
		{name="left",	vx=-1,vy= 0,dir=1,back=2},
		{name="right",	vx= 1,vy= 0,dir=2,back=1},
		{name="up",		vx= 0,vy=-1,dir=3,back=4},
		{name="down",	vx= 0,vy= 1,dir=4,back=3},
		}
	for i,v in ipairs(movedirs) do movedirs[v.name]=v end


monster.loads=function()

--	oven.cake.fonts.loads({1}) -- load 1st builtin font, a basic 8x8 font	

	
end

monster.setup=function()
	monster.x=0
	monster.y=0
	monster.block=cells.blocks[9*9]
	monster.lastmove=movedirs[1]
	monster.think=0
	
--	monster.speed=2
	monster.thinktime=10
	monster.speed=2+(main.level/10)
	monster.rotate=0
	monster.anim=0
	monster.size=1
	
end

monster.clean=function()
end

	
monster.update=function()

if hero.state=="live" then

	monster.move=monster.lastmove.dir

	if monster.think and monster.think>0 then
		local count=0
		for i,v in pairs( monster.block.links ) do count=count+1 end
		if count>2 then -- stop and think at crossroads
			monster.think=monster.think-1
			monster.move=nil
		else
			monster.think=0
		end
	end

	if monster.think and monster.think<=0 then
		monster.move=monster.lastmove.dir

		local best=monster.block.links[monster.lastmove.dir]
		if monster.smart then
			for i,v in pairs( monster.block.links ) do
				if i~=monster.lastmove.back then -- monster trys not to turn back
					if not best then best=v monster.move=i end
					if v.sniff < best.sniff then best=v monster.move=i end
	--print(monster.lastmove.back," considering "..i)
	--			else
	--print(monster.lastmove.back," ignoring "..i)
				end
			end
		else
			local t={}
			for i,v in pairs( monster.block.links ) do
				if i~=monster.lastmove.back then -- monster trys not to turn back
					t[#t+1]=i
				end
			end
			if t[1] then
				monster.move= t[ math.random(1,#t) ]
			end
		end
		
--print(monster.lastmove.back," decided "..monster.move)
		monster.lastmove=movedirs[monster.move]

		monster.think=nil
	end
		
-- monster cannot turn back on itself
--	if monster.move==monster.lastmove.back then
--		monster.move=monster.lastmove.dir
--	end

	local d
	if monster.move then
		local m=movedirs[monster.move]
		
		if not monster.block.links[m.dir] then
			m=monster.lastmove
		end

		if m then
		if ( m.vy~=0 and monster.block.links[m.dir] ) or ( ( m.vy<0 and monster.y>0 ) or ( m.vy>0 and monster.y<0 ) ) then
			if monster.x > monster.speed then
				d=movedirs.left
			elseif monster.x < -monster.speed then
				d=movedirs.right
			else
				monster.x=0
				d=m
				monster.lastmove=m
			end
		elseif  ( m.vx~=0 and monster.block.links[m.dir] ) or ( ( m.vx<0 and monster.x>0 ) or ( m.vx>0 and monster.x<0 ) ) then
			if monster.y > monster.speed then
				d=movedirs.up
			elseif monster.y < -monster.speed then
				d=movedirs.down
			else
				monster.y=0
				d=m
				monster.lastmove=m
			end
		end
		end
	end
	if d then -- perform valid move
		monster.x=monster.x+(d.vx*monster.speed)
		monster.y=monster.y+(d.vy*monster.speed)
		monster.anim=monster.anim+1
	else
		monster.anim=0
	end
	
	if monster.lastmove.vx<0 and monster.x<=-48 and monster.block.links[1] then
		monster.x=monster.x+48
		monster.block=monster.block.links[1]
		monster.think=monster.thinktime
	end
	if monster.lastmove.vx>0 and monster.x>=48 and monster.block.links[2] then
		monster.x=monster.x-48
		monster.block=monster.block.links[2]
		monster.think=monster.thinktime
	end
	if monster.lastmove.vy<0 and monster.y<=-48 and monster.block.links[3] then
		monster.y=monster.y+48
		monster.block=monster.block.links[3]
		monster.think=monster.thinktime
	end
	if monster.lastmove.vy>0 and monster.y>=48 and monster.block.links[4] then
		monster.y=monster.y-48
		monster.block=monster.block.links[4]
		monster.think=monster.thinktime
	end
	
	monster.px=monster.x+48+(monster.block.x-1)*48
	monster.py=monster.y+48+(monster.block.y-1)*48
	
	local dx=monster.px-hero.px
	local dy=monster.py-hero.py
	local dd=dx*dx+dy*dy
	if dd<(24*24) then
		hero.state="die"
	end
	
	if dd<(hero.viewbase*2)*(hero.viewbase*2) then -- if you can see the monster then the monster can see you
		monster.smart=true
	else
		monster.smart=false
	end


end
	monster.px=monster.x+48+(monster.block.x-1)*48
	monster.py=monster.y+48+(monster.block.y-1)*48

end

monster.draw=function()
	local sheet=sheets.get("imgs/bear")
	local f=monster.anim
	
	f=(math.floor(f/8)%4)
	if     f==0 then f=2
	elseif f==1 then f=1
	elseif f==2 then f=3
	elseif f==3 then f=1
	end
	
	if     monster.lastmove.dir==1 then f=f+9
	elseif monster.lastmove.dir==2 then f=f+6
	elseif monster.lastmove.dir==3 then f=f+3
	elseif monster.lastmove.dir==4 then f=f+0
	end
	
	sheet:draw(f,monster.px,monster.py-(8),monster.rotate,(64)*monster.size,(64)*monster.size)
end

	return monster
end

