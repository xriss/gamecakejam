-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require



--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,cells)
	local cells=cells or {}
	
	local cake=oven.cake
	local opts=oven.opts
	local canvas=cake.canvas
	
	local font=canvas.font
	local flat=canvas.flat
	local sheets=cake.sheets
	
	local gl=oven.gl

	cells.modname=M.modname

	local main=oven.rebake("dmazed.main")
	local menu=oven.rebake("dmazed.main_menu")
		
	local beep=oven.rebake("dmazed.beep")
	local wscores=oven.rebake("wetgenes.gamecake.spew.scores")

cells.loads=function()

--	oven.cake.fonts.loads({1}) -- load 1st builtin font, a basic 8x8 font	

	
end

cells.setup=function()
	local tab={}
	local idx
	
	idx=1
	for y=0,29 do
		for x=0,29 do
		
			tab[idx]=0
			
			if ( x>=1 and x<=28 and y>=1 and y<=28 ) then
				tab[idx]=1
			end

			if ( (((x-1)%3)==1) or (((x-1)%3)==2) ) and ( (((y-1)%3)==1) or (((y-1)%3)==2) ) then
				tab[idx]=0
			end

			idx=idx+1
		end
	end
	
	local blocks={}
	local links={}

	local function peek(x,y)
		if x<0 or x>29 or y<0 or y>29 then return 0 end
		local i=1 + x + y*30
		return tab[i]
	end
	local function poke(x,y,v)
		if x<0 or x>29 or y<0 or y>29 then return end
		local i=1 + x + y*30
		tab[i]=v
	end
	
	local function walls(x,y) -- blocks 1,9 in x and y
		local px=1+(3*(x-1))
		local py=1+(3*(y-1))
		return {	-- left,right,up,down
			peek(px+0,py+1),
			peek(px+3,py+1),
			peek(px+1,py+0),
			peek(px+1,py+3)
		}
	end

	local function binfo(x,y) -- blocks 1,9 in x and y
		if not y then -- or just idx in x
			x=x-1
			y=math.floor(x/9)+1
			x=(x%9)+1
		end
		if x<1 or x>9 or y<1 or y>9 then return nil end
		local ret={x=x,y=y,idx=x+((y-1)*9)}
		return ret
	end
	
	local function count_links()
		local n=0
		for i,v in pairs(links) do n=n+1 end
		return n
	end

	local function merge_links(a,b) -- pass in two links idx

		local la=links[a]
		local lb=links[b]
		
		if la==lb then return end -- done already
		
		for i,v in ipairs(lb) do
			la[#la+1]=v
			blocks[v]=a
		end
		links[b]=nil
	end
	
	local function merge_all()
		repeat
			local before=count_links()
			
			for i,v in pairs(blocks) do
				local b=binfo(i)
				local w=walls(b.x,b.y)
				local c
				if w[1]==0 then
					c=binfo(b.x-1,b.y)
					if c then
						if blocks[c.idx]~=blocks[b.idx] then 
							merge_links(blocks[c.idx],blocks[b.idx])
							break
						end
					end
				end
				if w[2]==0 then
					c=binfo(b.x+1,b.y)
					if c then
						if blocks[c.idx]~=blocks[b.idx] then 
							merge_links(blocks[c.idx],blocks[b.idx])
							break
						end
					end
				end
				if w[3]==0 then
					c=binfo(b.x,b.y-1)
					if c then
						if blocks[c.idx]~=blocks[b.idx] then 
							merge_links(blocks[c.idx],blocks[b.idx])
							break
						end
					end
				end
				if w[4]==0 then
					c=binfo(b.x,b.y+1)
					if c then
						if blocks[c.idx]~=blocks[b.idx] then 
							merge_links(blocks[c.idx],blocks[b.idx])
							break
						end
					end
				end
			end

			local after=count_links()
		until before==after -- no change
	end

--gouge the map
	for y=1,9 do
		local a,b=math.random(1,9),math.random(1,9)
		if a>b then a,b=b,a end -- low to high
		a=2+(3*(a-1))
		b=2+(3*(b-1))+1
		for x=a,b do
			poke(x,2+(3*(y-1)),0)
			poke(x,3+(3*(y-1)),0)
		end
	end
	
	for x=1,9 do
		local a,b=math.random(1,9),math.random(1,9)
		if a>b then a,b=b,a end -- low to high
		a=2+(3*(a-1))
		b=2+(3*(b-1))+1
		for y=a,b do
			poke(2+(3*(x-1)),y,0)
			poke(3+(3*(x-1)),y,0)
		end
	end	

	local function break_a_wall(l)
	
		local b=binfo(l)
		local w=walls(b.x,b.y)
		local p=math.random(1,4)
		local px=1+(3*(b.x-1))
		local py=1+(3*(b.y-1))

		if w[p]~=0 then -- break down this wall
			if p==1 then -- left
				if binfo(b.x-1,b.y) then -- check its not edge of map
					poke(px+0,py+1,0)
					poke(px+0,py+2,0)
				end
			elseif p==2 then -- right
				if binfo(b.x+1,b.y) then -- check its not edge of map
					poke(px+3,py+1,0)
					poke(px+3,py+2,0)
				end
			elseif p==3 then -- up
				if binfo(b.x,b.y-1) then -- check its not edge of map
					poke(px+1,py+0,0)
					poke(px+2,py+0,0)
				end
			elseif p==4 then -- down
				if binfo(b.x,b.y+1) then -- check its not edge of map
					poke(px+1,py+3,0)
					poke(px+2,py+3,0)
				end
			end
		end
	end

	local function remove_deadends()
		repeat -- remove all deadends
			local finished=true
			for i,v in pairs(blocks) do
				local b=binfo(i)
				local w=walls(b.x,b.y)
				local c=0
				for i,v in ipairs(w) do if v~=0 then c=c+1 end end
				if c>=3 then
					break_a_wall(i)
					finished=false
				end
			end		
		until finished
	end

	local function connect_everything()
	
		-- reset links
		links={}
		blocks={}
		for i=1,9*9 do
			links[i]={i} -- list of blocks
			blocks[i]=i -- which link we are part of
		end

		merge_all()
		while count_links()>1 do -- then make sure all blocks are connected
			for i,ls in pairs(links) do
				local l=ls[math.random(1,#ls)]
				break_a_wall(l)
			end
			merge_all()
		end
	end

	local function repair_islands()
		local count=0
		for i,v in pairs(blocks) do
			local b=binfo(i)
			local px=1+(3*(b.x-1))
			local py=1+(3*(b.y-1))
			if peek(px-1,py)==0 and peek(px+1,py)==0 and peek(px,py-1)==0 and peek(px,py+1)==0 then
				count=count+1
				poke(px-1,py,1) poke(px-2,py,1)
				poke(px+1,py,1) poke(px+2,py,1)
				poke(px,py-1,1) poke(px,py-1,1)
				poke(px,py-2,1) poke(px,py-2,1)
			end
		end
		return count
	end
	
	repeat
		connect_everything()
		remove_deadends()
	until repair_islands()==0
	
	local map={
--         L  R LR
		 5,12,13,14,		
		21, 8, 7,16,	-- up
		 3, 2, 1,11,	-- down
		 9,17,10,15,	-- up+down
	}
	

	cells.tab={}
	idx=1
	for y=0,29 do
		for x=0,29 do
			if peek(x,y)==1 then
				local cl=peek(x-1,y  )	-- 1
				local cr=peek(x+1,y  )	-- 2
				local cu=peek(x  ,y-1)	-- 4
				local cd=peek(x  ,y+1)	-- 8
				local c=0
				if cl~=0 then c=c+1 end
				if cr~=0 then c=c+2 end
				if cu~=0 then c=c+4 end
				if cd~=0 then c=c+8 end
				cells.tab[idx]=map[c+1]
			else
				cells.tab[idx]=0
			end
			idx=idx+1
		end
	end

end

cells.clean=function()
end

cells.update=function()
end

cells.draw=function()
	local sheet=sheets.get("imgs/walls")
	
	local idx=1
	local t
	for y=0,29 do
		for x=0,29 do
			t=cells.tab[idx]
			if t>0 then
				sheet:draw(t,x*16,y*16,nil,16,16)
			end
			idx=idx+1
		end
	end
end


--[[

cells.setup=function()

	cells.next=nil

	cells.loads()
	
	cells.tab={}
	
	cells.classes={}
	local classes=cells.classes
		
	cells.mx=12
	cells.my=12
	
	cells.ss=40

	cells.px=cells.ss/2
	cells.py=cells.ss/2
	
	cells.aliens=0


	local cdraw=function(c)
		local x=cells.px+c.cx*cells.ss
		local y=cells.py+c.cy*cells.ss
		if c.dd then -- animate
			x=x+c.dx*c.dd
			y=y+c.dy*c.dd
		end
		c.sheet:draw(1,x,y,nil,cells.ss,cells.ss)	
	end
	local cupdate=function(c)
		if c.dd then -- animate
			c.dd=c.dd - ( cells.ss/(c.data and c.data.speed or 1) )
			if c.dd<=0 then c.dd=nil end
		end
	end
	
-- build cells table
	cells.classes.none={
		setup=function(c)
--			c.sheet=sheets.get("imgs/floor")
		end,
		update=function(c)end,
		draw=function(c)
--			cdraw(c)
		end,
	}
	cells.classes.egg={
		setup=function(c)
			c.sheet=sheets.get("imgs/egg1")
			if not c.data then
				c.data={}
				c.data.speed=5
			end
		end,
		update=function(c)
			cupdate(c)
			if c.data.state=="slide" then
				if not c.dd then
					local idx=cells.cxcy_to_idx(c.cx+c.data.dx,c.cy+c.data.dy)
					local c2=cells.tab[idx]
					if c2 then
						if c2.class==classes.none then -- just move
							cells.swap_cell(c,c2)
						else
							if c2.class.die then
								c2.class.die(c2)
							end
							c.data.state=nil							
						end
					end
				end
			elseif c.data.state=="die" then
				if not c.dd then
					c.class=cells.classes.none
					c.data=nil
				end
			end
		end,
		draw=function(c)
			if c.data.state=="die" then
				local a=c.dd/cells.ss
				gl.Color(a,a,a,a)
				cdraw(c)
				gl.Color(1,1,1,1)
			else
				cdraw(c)
			end
		end,
		move=function(c,dx,dy)
			if not c.dd then -- move again
				if dx~=0 or dy~=0 then
					local idx=cells.cxcy_to_idx(c.cx+dx,c.cy+dy)
					local c2=cells.tab[idx]
					if c2 then
						if c2.class==classes.none then -- just move
							cells.swap_cell(c,c2)
						end
					end
				end
			end
		end,
		push=function(c,dx,dy)
			if not c.data.state then
				local idx=cells.cxcy_to_idx(c.cx+dx,c.cy+dy)
				local c2=cells.tab[idx]
				if c2 then
					if (c2.class==classes.none) or (c2.class==classes.alien) then
						c.data.dx=dx
						c.data.dy=dy
						c.data.state="slide"
						beep.play("slide1")
					else
						c.class.die(c)
						beep.play("slide")
					end
				end
			end
		end,
		die=function(c)
			c.sheet=sheets.get("imgs/egg2")
			c.data.state="die"
			c.dx=0
			c.dy=0
			c.dd=cells.ss
			wscores.add(1*main.level)
		end,
	}
	cells.classes.hard={
		setup=function(c)
			c.sheet=sheets.get("imgs/block")
		end,
		update=function(c)end,
		draw=function(c)
			cdraw(c)
		end,
	}
	cells.classes.hero={
		setup=function(c)
			c.sheet=sheets.get("imgs/hero")
			cells.hero=c -- only one
			if not c.data then
				c.data={}
				c.data.speed=10
				c.data.safe=60*2
			end
		end,
		update=function(c)
			cupdate(c)
			if c.data.safe>0 then c.data.safe=c.data.safe-1 end
			if c.data.state=="die" then
				if not c.dd then
					c.class=cells.classes.none
					c.data=nil
					cells.hero=nil
				end
			end
		end,
		draw=function(c)
			if c.data.state=="die" then
				local a=c.dd/cells.ss
				gl.Color(a,a,a,a)
				cdraw(c)
				gl.Color(1,1,1,1)
			elseif c.data.safe>0 then
				local a=1/3
				gl.Color(a,a,a,a)
				cdraw(c)
				gl.Color(1,1,1,1)
			else
				cdraw(c)
			end
		end,
		move=function(c,dx,dy)
			if not c.dd then -- move again
				if dx~=0 or dy~=0 then
					local idx=cells.cxcy_to_idx(c.cx+dx,c.cy+dy)
					local c2=cells.tab[idx]
					if c2 then
						if c2.class==classes.none then -- just move
							cells.swap_cell(c,c2)
						elseif c2.class.push then
							c2.class.push(c2,dx,dy)
							c.dx=0
							c.dy=0
							c.dd=cells.ss
						elseif c2.class==classes.alien then
							c.class.die(c)
						end
					end
				end
			end
		end,
		die=function(c)
			if c.data.safe==0 then
				c.sheet=sheets.get("imgs/herodie")
				c.data.state="die"
				c.dx=0
				c.dy=0
				c.dd=cells.ss
				beep.play("die")
			end
		end,
	}
	cells.classes.alien={
		setup=function(c)
			c.sheet=sheets.get("imgs/alien")
			cells.alien=c -- only one
			if not c.data then
				c.data={}
				c.data.dx=0
				c.data.dy=0
				c.data.speed=20
			end
		end,
		update=function(c)
			cells.aliens=cells.aliens+1
			cupdate(c)
			if c.data.state=="die" then
				if not c.dd then
					c.class=cells.classes.none
					c.data=nil
				end
			else
				if not c.dd then
					if c.data.dx==0 and c.data.dy==0 then -- new random direction
						local r=math.random(1,4)
						if     r==1 then c.data.dx,c.data.dy=-1,0
						elseif r==2 then c.data.dx,c.data.dy= 1,0
						elseif r==3 then c.data.dx,c.data.dy= 0,-1
						elseif r==4 then c.data.dx,c.data.dy= 0,1
						end
					end
					local idx=cells.cxcy_to_idx(c.cx+c.data.dx,c.cy+c.data.dy)
					local c2=cells.tab[idx]
					if c2 then
						if c2.class==classes.none then -- just move
							cells.swap_cell(c,c2)
							return
						elseif c2.class==classes.hero then -- gameover
							c2.class.die(c2)
						end
					end
					c.data.dx,c.data.dy=0,0 -- try another direction next time
				end
			end
		end,
		draw=function(c)
			if c.data.state=="die" then
				local a=c.dd/cells.ss
				gl.Color(a,a,a,a)
				cdraw(c)
				gl.Color(1,1,1,1)
			else
				cdraw(c)
			end
		end,
		move=function(c,dx,dy)
			if not c.dd then -- move again
				if dx~=0 or dy~=0 then
					local idx=cells.cxcy_to_idx(c.cx+dx,c.cy+dy)
					local c2=cells.tab[idx]
					if c2 then
						if c2.class==classes.none then -- just move
							cells.swap_cell(c,c2)
						end
					end
				end
			end
		end,
		die=function(c)
			if c.data.state~="die" then
				c.sheet=sheets.get("imgs/aliendie")
				c.data.state="die"
				c.dx=0
				c.dy=0
				c.dd=cells.ss
				wscores.add(10*main.level)
				beep.play("squash")
			end
		end,
	}
		
	local idx=1
	for cy=0,cells.my-1 do
		for cx=0,cells.mx-1 do
		
			local c={}
			cells.tab[idx]=c
			c.cx=cx
			c.cy=cy
			c.idx=idx
			if cx==0 or cx==cells.mx-1 or cy==0 or cy==cells.mx-1 then -- edge
				c.class=classes.hard
			else
				c.class=classes.none
			end
			c.class.setup(c)
			idx=idx+1
		end
	end
	
	for i=1,50 do
		local cx=math.random(1,cells.mx-2)
		local cy=math.random(1,cells.mx-2)
		local idx=cells.cxcy_to_idx(cx,cy)
		local c=cells.tab[idx]
		c.class=classes.egg
		c.data=nil
		c.class.setup(c)
	end

	for i=1,4+main.level do
		local cx=math.random(1,cells.mx-2)
		local cy=math.random(1,cells.mx-2)
		local idx=cells.cxcy_to_idx(cx,cy)
		local c=cells.tab[idx]
		c.class=classes.alien
		c.data=nil
		c.class.setup(c)
	end
	
	for i=1,1 do
		local cx=math.random(1,cells.mx-2)
		local cy=math.random(1,cells.mx-2)
		local idx=cells.cxcy_to_idx(cx,cy)
		local c=cells.tab[idx]
		c.class=classes.hero
		c.data=nil
		c.class.setup(c)
	end
	
end

cells.cxcy_to_idx=function(cx,cy)
	return 1+cx+(cy*cells.mx)
end

cells.swap_cell=function(c1,c2)

	c1.class,c2.class=c2.class,c1.class
	c1.data,c2.data=c2.data,c1.data
	
	c1.dx=c2.cx-c1.cx
	c1.dy=c2.cy-c1.cy
	c1.dd=cells.ss
	
	c2.dx=c1.cx-c2.cx
	c2.dy=c1.cy-c2.cy
	c2.dd=cells.ss

	c1.class.setup(c1)
	c2.class.setup(c2)
end


cells.clean=function()


end


cells.update=function()

	if cells.hero and cells.hero.class.move then
	
		local dx,dy=0,0
		if cells.move=="up" then
			dx,dy=0,-1
		elseif cells.move=="down" then
			dx,dy=0,1
		elseif cells.move=="left" then
			dx,dy=-1,0
		elseif cells.move=="right" then
			dx,dy=1,0
		end
		cells.hero.class.move(cells.hero,dx,dy)
		
	else -- gameover
		if not cells.next then
			menu.back="imgs/end"
			cells.next=menu
		end
	end
	
	cells.aliens=0
	for i,v in ipairs(cells.tab) do
		v.class.update(v)
	end
	
	if cells.aliens<=0 then
		if not cells.next then
			cells.next=oven.rebake("dmazed.main_game") -- next level
			beep.play("win")
		end
	end
	

end

cells.draw=function()

	for i,v in ipairs(cells.tab) do
		v.class.draw(v)
	end

end
]]
		
	return cells
end

