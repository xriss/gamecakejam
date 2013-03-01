-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local grd=require("wetgenes.grd")
local pack=require("wetgenes.pack")
local wstr=require("wetgenes.string")

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
	local fbs=cake.framebuffers
	
	local gl=oven.gl

	cells.modname=M.modname

	local main=oven.rebake("dmazed.main")
	local menu=oven.rebake("dmazed.main_menu")
	local game=oven.rebake("dmazed.main_game")
		
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
	
	cells.blocks={} -- build final maze info
	for i=1,9*9 do
		local b=binfo(i)
		cells.blocks[i]=b
	end
	local sweets={1,2,3,7}
	for i=1,9*9 do
		local b=cells.blocks[i]
		local w=walls(b.x,b.y)
		b.links={}
		if w[1]==0 then
			b.links[1]=cells.blocks[binfo(b.x-1,b.y).idx]
		end
		if w[2]==0 then
			b.links[2]=cells.blocks[binfo(b.x+1,b.y).idx]
		end
		if w[3]==0 then
			b.links[3]=cells.blocks[binfo(b.x,b.y-1).idx]
		end
		if w[4]==0 then
			b.links[4]=cells.blocks[binfo(b.x,b.y+1).idx]
		end
		b.time=0
		b.sniff=0
		b.item=sweets[math.random(1,#sweets)]
	end
	
	cells.blocks[1].item=0
	repeat
		local done=false
		local r1=math.random(2,9*9-1)
		local r2=math.random(2,9*9-1)
		if r1~=r2 then
			cells.blocks[r1].item=4
			cells.blocks[r2].item=5
			done=true
		end
	until done
	
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
	
	
	cells.fbo=fbs.create()

end

cells.clean=function()
	cells.fbo:clean()
	cells.fbo=nil
end

cells.update=function()

-- the smell spreads block by block
	for i,b in ipairs(cells.blocks) do
		
		local best=nil
		for _,l in pairs(b.links) do
			if l.sniff and l.time then
				if not best then
					best=l
				elseif l.time>best.time then
					best=l
				elseif l.time==best.time and l.sniff<best.sniff then
					best=l
				end
			end
		end
		if best then
			if b.time==best.time then
				if b.sniff~=0 then -- the master
--					if b.sniff>best.sniff then
						b.sniff=best.sniff+1
						b.time=best.time
--					end
				end
			elseif b.time<best.time then -- best by time
				b.time=best.time
				b.sniff=best.sniff+1
			end
		end
	end
end

cells.image=function()

	local fbo=assert(fbs.create(480,480,0))
	local layout=cake.layouts.create{parent={w=480,h=480,x=0,y=0}}
	
	fbs.bind_frame(fbo)
	layout.setup()
	gl.ClearColor(pack.argb4_pmf4(0xf000))
	gl.Clear(gl.COLOR_BUFFER_BIT+gl.DEPTH_BUFFER_BIT)
	
	cells.draw()

	layout.clean()

	local gd = fbo:download()
	assert(gd:convert(grd.FMT_U8_ARGB))
	
	fbs.bind_frame(nil)
	
	fbo:clean()

	return gd
end

cells.examples=function()
	
	for i=0,9 do
		local gd

		cells.setup()
		gd=cells.image()
		gd:save("files/dmazed0"..i..".png")

	end
end

cells.draw_walls=function()

	local sheet=sheets.get(game.walls)
	
	oven.gl.Color(0,0,0,1)
	local idx=1
	local t
	for y=0,29 do
		for x=0,29 do
			t=cells.tab[idx]
			if t>0 then
				sheet:draw(t,x*16+2,y*16+2,nil,16,16)
			end
			idx=idx+1
		end
	end
	oven.gl.Color(1,1,1,1)
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

cells.draw_into_texture=function()

	if not cells.fbo.texture then -- build our texture (happens after any stop/start)

		cells.fbo:resize(1024,1024,0)
		
		local layout=cake.layouts.create{parent={w=1024,h=1024,x=0,y=0}}
		
		fbs.bind_frame(cells.fbo)
		layout.setup(480,480,1/4,480*4)
		
		gl.ClearColor(pack.argb4_pmf4(0x0000))
		gl.Clear(gl.COLOR_BUFFER_BIT+gl.DEPTH_BUFFER_BIT)
		
		cells.draw_walls()

		layout.clean()

		fbs.bind_frame(nil)
		
		cells.fbo:free_depth()
		cells.fbo:free_frame()
		-- but keep the texture

	end
	
end

cells.draw=function()

	cells.draw_into_texture()
	cells.fbo:bind_texture()
	gl.Color(pack.argb4_pmf4(0xffff))
	flat.tristrip("xyzuv",{
		0,		0,		0,		0,	1,
		480,	0,		0,		1,	1,
		0,		480,	0,		0,	0,
		480,	480,	0,		1,	0,
	})

--	cells.draw_walls()

-- draw sniff values
--[[
	oven.gl.Color(1,1,1,1)
	font.set(cake.fonts.get(1))
	font.set_size(16)
	for i,b in ipairs(cells.blocks) do
		local x=48-16+(b.x-1)*48
		local y=48-8+(b.y-1)*48
		font.set_xy( x,y )
		font.draw(tostring(b.sniff))
	end
]]

	local sheet=sheets.get("imgs/items")
	oven.gl.Color(1,1,1,1)
	for i,b in ipairs(cells.blocks) do
		if b.item>0 then
			local x=48+(b.x-1)*48
			local y=48+(b.y-1)*48
			local s=1
			if b.item==4 or b.item==5 then s=1.5 end
			sheet:draw(b.item,x,y,nil,24*s,24*s)
		end
	end


end

--cells.examples()

	return cells
end

