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

	local wgui=oven.rebake("wetgenes.gamecake.spew.gui")
	local gui=oven.rebake("dmazed.gui")

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
	hero.pulse=1
	hero.rate=1.125
	hero.viewbase=1
	hero.item=0
	hero.held=0
	hero.speed=2+main.herospeed
	hero.state="start" -- start , live, die , exit
	hero.gone=0
	hero.size=1
	hero.rotate=0
	hero.anim=0
end

hero.clean=function()
end

	
hero.update=function()

if hero.state=="start" then

	hero.viewbase=hero.viewbase*1.1
	if hero.viewbase>100 then
		hero.state="live"
	end

elseif hero.state=="die" then

	hero.gone=hero.gone+1
	hero.size=hero.size*1.1
	hero.viewbase=hero.viewbase+1
	hero.rotate=hero.rotate+5

	if hero.gone==100 then
		wscores.final_score({})
		main.next=menu
		gui.page()
		gui.next="menu"
		wgui.page("score")
	end

elseif hero.state=="exit" then

	hero.x=hero.x*0.5
	hero.y=hero.y*0.5
	hero.gone=hero.gone+1
	hero.size=hero.size*0.95
	hero.viewbase=hero.viewbase+5
--	hero.rotate=hero.rotate+5

	if hero.gone==100 then
		main.next=game
	end

elseif hero.state=="live" then

	local moved=false
	
	if hero.move then
		local m=movedirs[hero.move]
		local d
		
		if not hero.block.links[m.dir] then
			m=hero.lastmove
		end

		if m then
		if ( m.vy~=0 and hero.block.links[m.dir] ) or ( ( m.vy<0 and hero.y>0 ) or ( m.vy>0 and hero.y<0 ) ) then
			if hero.x > hero.speed then
				d=movedirs.left
			elseif hero.x < -hero.speed then
				d=movedirs.right
			else
				hero.x=0
				d=m
				hero.lastmove=m
			end
		elseif  ( m.vx~=0 and hero.block.links[m.dir] ) or ( ( m.vx<0 and hero.x>0 ) or ( m.vx>0 and hero.x<0 ) ) then
			if hero.y > hero.speed then
				d=movedirs.up
			elseif hero.y < -hero.speed then
				d=movedirs.down
			else
				hero.y=0
				d=m
				hero.lastmove=m
			end
		end
		end
		
		if d then -- perform valid move
			hero.x=hero.x+(d.vx*hero.speed)
			hero.y=hero.y+(d.vy*hero.speed)
			
			moved=true
		end
	end

	if moved then

		hero.viewbase=hero.viewbase+1
		if hero.viewbase>100 then hero.viewbase=100 end

		hero.anim=hero.anim+1

	else

		hero.viewbase=hero.viewbase-1
		if hero.viewbase<50 then hero.viewbase=50 end
	
	end

	local newblock=false
	if hero.lastmove.vx<0 and hero.x<0 and hero.block.links[1] then
		hero.x=hero.x+48
		hero.block=hero.block.links[1]
		hero.block.time=game.time
		newblock=true
	end
	if hero.lastmove.vx>0 and hero.x>0 and hero.block.links[2] then
		hero.x=hero.x-48
		hero.block=hero.block.links[2]
		hero.block.time=game.time
		newblock=true
	end
	if hero.lastmove.vy<0 and hero.y<0 and hero.block.links[3] then
		hero.y=hero.y+48
		hero.block=hero.block.links[3]
		hero.block.time=game.time
		newblock=true
	end
	if hero.lastmove.vy>0 and hero.y>0 and hero.block.links[4] then
		hero.y=hero.y-48
		hero.block=hero.block.links[4]
		hero.block.time=game.time
		newblock=true
	end
	
	if newblock then
		local b=hero.block
		
		if b.item==1 then
			b.item=0
			wscores.add(main.level)

-- 77 of these on each level
-- if you collect everything on everylevel you will stay faster than the monster
-- who speeds up by 0.1 each level
			main.herospeed=main.herospeed+(0.1/78)
			hero.speed=hero.speed+(1/78) -- also apply super speed (x10 bonus) instantly
			
			hero.held=hero.held+1

		elseif b.item==2 then -- exit
			if hero.item==3 then
				b.item=0
				wscores.add(111*main.level*main.level)
				hero.state="exit"
			end
		elseif b.item==3 then -- key
			b.item=0
			hero.item=3
			wscores.add(11*main.level*main.level)
		end
	end

	if hero.pulse>1/256 then
		hero.pulse=hero.pulse/hero.rate
	else
		hero.pulse=1
	end

	hero.block.sniff=0

end
	
	hero.px=hero.x+48+(hero.block.x-1)*48
	hero.py=hero.y+48+(hero.block.y-1)*48

	hero.view=hero.viewbase+hero.pulse*hero.viewbase
	
end

hero.draw=function()
	local sheet=sheets.get("imgs/pilu")
	local f=hero.anim
	
	f=(math.floor(f/8)%4)
	if     f==0 then f=2
	elseif f==1 then f=1
	elseif f==2 then f=3
	elseif f==3 then f=1
	end
	sheet:draw(f,hero.px,hero.py-8,hero.rotate,(64)*hero.size,(64)*hero.size)
end

	return hero
end

