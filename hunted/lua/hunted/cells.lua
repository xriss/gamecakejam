-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require



--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(state,cells)
	local cells=cells or {}
	
	local cake=state.cake
	local opts=state.opts
	local canvas=state.canvas
	
	local font=canvas.font
	local flat=canvas.flat
	local sheets=cake.sheets
	
	local gl=cake.gl

	cells.modname=M.modname
		
	
cells.loads=function()

	state.cake.fonts.loads({1}) -- load 1st builtin font, a basic 8x8 font	

	
end
		
cells.setup=function()

	cells.loads()
	
	cells.tab={}
	
	cells.classes={}
	local classes=cells.classes
		
	cells.mx=12
	cells.my=12
	
	cells.ss=40

	cells.px=cells.ss/2
	cells.py=cells.ss/2


	local cdraw=function(c)
		local x=cells.px+c.cx*cells.ss
		local y=cells.py+c.cy*cells.ss
		if c.dd then -- animate
			x=x+c.dx*c.dd
			y=y+c.dy*c.dd
		end
		c.sheet:draw(1,x,y,0,cells.ss,cells.ss)	
	end
	local cupdate=function(c)
		if c.dd then -- animate
			c.dd=c.dd - (cells.ss/10)
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
		end,
		update=function(c)
			cupdate(c)
		end,
		draw=function(c)
			cdraw(c)
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
		end,
		update=function(c)
			cupdate(c)
		end,
		draw=function(c)
			cdraw(c)
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
	}
	cells.classes.alien={
		setup=function(c)
			c.sheet=sheets.get("imgs/alien")
			cells.alien=c -- only one
			if not c.data then
				c.data={}
				c.data.dx=0
				c.data.dy=0
			end
		end,
		update=function(c)
			cupdate(c)
			if not c.dd then
				if c.data.dx==0 and c.data.dx==0 then -- new random direction
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
					end
				end
				c.data.dx,c.data.dy=0,0 -- try another direction next time
			end
		end,
		draw=function(c)
			cdraw(c)
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
		c.class.setup(c)
	end

	for i=1,5 do
		local cx=math.random(1,cells.mx-2)
		local cy=math.random(1,cells.mx-2)
		local idx=cells.cxcy_to_idx(cx,cy)
		local c=cells.tab[idx]
		c.class=classes.alien
		c.class.setup(c)
	end
	
	for i=1,1 do
		local cx=math.random(1,cells.mx-2)
		local cy=math.random(1,cells.mx-2)
		local idx=cells.cxcy_to_idx(cx,cy)
		local c=cells.tab[idx]
		c.class=classes.hero
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
	end
	
	for i,v in ipairs(cells.tab) do
		v.class.update(v)
	end

end

cells.draw=function()
	
	for i,v in ipairs(cells.tab) do
		v.class.draw(v)
	end

end
		
	return cells
end

