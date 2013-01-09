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
		c.sheet:draw(1,cells.px+c.cx*cells.ss,cells.py+c.cy*cells.ss,0,cells.ss,cells.ss)	
	end
	local cupdate=function(c)
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
		update=function(c)end,
		draw=function(c)
			cdraw(c)
		end,
	}
	cells.classes.hard={
		setup=function(c)
			c.sheet=sheets.get("imgs/egg2")
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
		update=function(c)end,
		draw=function(c)
			cdraw(c)
		end,
	}
	
	local idx=1
	for cx=0,cells.mx-1 do
		for cy=0,cells.my-1 do
		
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

cells.clean=function()


end


cells.update=function()

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

