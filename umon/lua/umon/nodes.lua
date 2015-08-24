-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math

local function dprint(a) print(wstr.dump(a)) end

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,nodes)
	local nodes=nodes or {}
	nodes.oven=oven
	
	nodes.modname=M.modname

	local cake=oven.cake
	local opts=oven.opts
	local canvas=cake.canvas
	local font=canvas.font
	local flat=canvas.flat
	local gl=oven.gl
	local sheets=cake.sheets
	

	local gui=oven.rebake(oven.modgame..".gui")
	local main=oven.rebake(oven.modgame..".main")
	local play=oven.rebake(oven.modgame..".main_play")
--	local beep=oven.rebake(oven.modgame..".beep")

	local console=oven.rebake("wetgenes.gamecake.mods.console")

	local stats=oven.rebake(oven.modgame..".stats")
	local mon=oven.rebake(oven.modgame..".mon")

local powers={

	{
		name="Teeth",
		atk=1,
		hit=1,
		gold=2,
	},

	{
		name="Skin",
		def=2,
		hit=2,
		gold=2,
	},

	{
		name="Spikes",
		atk=1,
		def=1,
		hit=1,
		gold=2,
	},

	{
		name="Wings",
		spd=3,
		def=1,
		hit=-1,
		gold=3,
	},

	{
		name="Tail",
		atk=2,
		def=2,
		spd=-1,
		hit=2,
		gold=3,
	},

	{
		name="Claw",
		atk=3,
		spd=1,
		gold=4,
	},

	{
		name="Leg",
		spd=3,
		def=3,
		hit=1,
		gold=4,
	},

	{
		name="Arm",
		atk=2,
		def=2,
		hit=2,
		gold=3,
	},

	{
		name="Neck",
		atk=2,
		hit=2,
		gold=2,
	},


}
for i,v in ipairs(powers) do v.idx=i powers[ v.name:lower() ]=i end


local node={} ; node.__index=node

node.setup=function(it,opt)
	local it=it or {}
	setmetatable(it,node) -- allow : functions
	
	it.px=opt.px or 0
	it.py=opt.py or 0

	it.num=opt.num or 0		-- our troops
	it.def=opt.def or 0		-- their troops, costs this many troops to take over this node

	it.flava=opt.flava or "none"
	
	it.icon=opt.icon or 1
	
	it.links=opt.links or {}

	it.power=powers[it.icon]
	
	return it
end
node.clean=function(it)
end
node.update=function(it)
end
node.draw=function(it)

	local mx=play.mx-nodes.px
	local my=play.my-nodes.py
	
	local dx=mx-it.px
	local dy=my-it.py
	
	local over=1
	if not nodes.menu then
		if ( (dx*dx + dy*dy) < 32*32 ) then
			over=2
			if play.mb==1 then
				over=3
			end
			if play.click then
				if not nodes.menu then nodes.menu=it.idx play.click=false end
			end
		end
	end

	local draw=function(n,i,x,y,w,h)

		gl.Color(0,0,0,1)

		sheets.get(n):draw(i,x+2,y,nil,w,h)
		sheets.get(n):draw(i,x-2,y,nil,w,h)
		sheets.get(n):draw(i,x,y+2,nil,w,h)
		sheets.get(n):draw(i,x,y-2,nil,w,h)

		gl.Color(1,1,1,1)
		
		sheets.get(n):draw(i,x,y,nil,w,h)
		
	end

	if it.num>=it.def then -- our troops
		
		draw("imgs/butt_01",over,it.px,it.py,32*2,32*2)
		draw("imgs/icon_01",it.icon,it.px-24,it.py-24,16*2,16*2)

		local s=""..it.num
		local w=font.width(s)
		font.set_xy(it.px-math.floor(w/2),it.py-23)
		font.draw(s)
	
	elseif it.def>0 then -- npc troops

		draw("imgs/butt_01",5,it.px,it.py,32*2,32*2)
		draw("imgs/icon_01",it.icon,it.px-24,it.py-24,16*2,16*2)

		gl.Color(0,0,0,1)
	
		local s=""..it.def
		local w=font.width(s)
		font.set_xy(it.px-math.floor(w/2),it.py-23)
		font.draw(s)
	
		gl.Color(1,1,1,1)
	end


end


nodes.loads=function()

end
		
nodes.setup=function()

	nodes.loads()
	nodes.tab={}

	nodes.hx=552
	nodes.hy=408

	nodes.px=800-nodes.hx-16
	nodes.py=600-nodes.hy-16

--[[	
	for j=1,4 do
		for i=1,6 do
		
			nodes.add{
				px=i*80,py=j*80,
				num=i-4-2+j,def=i-1+j,
				flava="base",
				icon=i,
			}

		end
	end
]]

--1y

	nodes.add{
		px=140,py=80,
		num=0,def=6,
		flava="base",
		icon=6,
		links={2},
	}

	nodes.add{
		px=230,py=110,
		num=0,def=5,
		flava="base",
		icon=5,
		links={1,3,5},
	}

	nodes.add{
		px=345,py=110,
		num=0,def=7,
		flava="base",
		icon=7,
		links={2,4,9},
	}

	nodes.add{
		px=435,py=80,
		num=0,def=8,
		flava="base",
		icon=8,
		links={3,6},
	}

--2y

	nodes.add{
		px=210,py=280,
		num=0,def=2,
		flava="base",
		icon=powers.teeth,
		links={2,7,8,9},
	}

	nodes.add{
		px=450,py=290,
		num=0,def=4,
		flava="base",
		icon=4,
		links={4,8},
	}

--3y

	nodes.add{
		px=110,py=350,
		num=0,def=0,
		flava="base",
		icon=powers.skin,
		links={5},
	}

	nodes.add{
		px=380,py=350,
		num=0,def=3,
		flava="base",
		icon=3,
		links={5,6,9},
	}

--middle
		nodes.add{
		px=350,py=220,
		num=0,def=9,
		flava="base",
		icon=9,
		links={3,5,8},
	}

end

nodes.clean=function()

	for i,v in ipairs(nodes.tab) do
		node.clean(v)
	end
	
end

nodes.msg=function(m)

--	print(wstr.dump(m))

end

nodes.update=function()

	for i=#nodes.tab,1,-1 do
		local it=nodes.tab[i]
		it:update()
		if it.flava=="dead" then
			table.remove(nodes.tab,i)
		end
	end

end

nodes.draw=function()

	gl.PushMatrix()
	gl.Translate(nodes.px,nodes.py,0)

	gl.Color(pack.argb4_pmf4(0xf001))
--	flat.quad(0,0,nodes.hx,nodes.hy)
	gl.Color(1,1,1,1)

	sheets.get("imgs/map_01"):draw(1,nodes.hx/2,nodes.hy/2,nil,nodes.hx,nodes.hy)
	
	font.set(cake.fonts.get("slkscr")) -- default font
	font.set_size(32,0)

	for i,it in ipairs(nodes.tab) do
		it:draw()
	end


	if nodes.menu then -- popup
	
		local it=nodes.tab[nodes.menu]
		
		if it.num>=it.def then -- a menu
		

			local lines={}

			font.set(cake.fonts.get("slkscr")) -- default font
			font.set_size(16,0)

			local n=math.floor(it.power.gold^it.num)
			if mon.gold>=n and it.num<9 then -- need gold
				lines[#lines+1]={txt="Upgrade your "..it.power.name.." for "..n.." gold",cmd="levelup",gold=n}
				lines[#lines].width=font.width(lines[#lines].txt)
			elseif it.num<9 then
				lines[#lines+1]={txt="Need "..n.." gold to upgrade",cmd="nop"}
				lines[#lines].width=font.width(lines[#lines].txt)
			end
			
			for _,l in ipairs(it.links) do

				local v=nodes.tab[l]
				if v.def>v.num and it.num>=v.def then
					lines[#lines+1]={txt="Grow some "..v.power.name,cmd="invade",dst=v}
					lines[#lines].width=font.width(lines[#lines].txt)
				end
				
			end

			lines[#lines+1]={txt="Close PopUp",cmd="close"}
			lines[#lines].width=font.width(lines[#lines].txt)
			
			local fs=24
			local w,h=16,#lines*fs+16

			for _,l in ipairs(lines) do if l.width+16>w then w=l.width+16 end end


			local x,y=nodes.hx/2-w/2,nodes.hy/2-h/2
			local fx,fy=x+8,y+8


			gl.Color(pack.argb4_pmf4(0xf004))
			flat.quad(x,y,x+w,y+h)
			gl.Color(1,1,1,1)

			local mx=play.mx-nodes.px
			local my=play.my-nodes.py


			local over=nil
			for i,v in ipairs(lines) do
			
				gl.Color(1/2,1/2,1/2,1/2)

				if mx>=fx and mx<=fx+w-16 then
					if my>=fy and my<fy+fs and v.cmd~="nop" then -- over
						gl.Color(1,1,1,1)
						over=v -- remember selection
					end
				end
			
				font.set_xy(fx,fy) font.draw(v.txt) fy=fy+fs
			end

			
			if play.click then
				if over then -- clicked on something
				
					if over.cmd=="levelup" then
					
						it.num=it.num+1
						mon.gold=mon.gold-over.gold
						mon.update_stats()
						mon.hit=mon.hitmax
						stats.print("Umon improved their "..it.power.name.." for "..over.gold.." gold")
					
						
					elseif over.cmd=="invade" then

						local d=over.dst
						d.num=0
						it.num=it.num-d.def
						d.def=0
						mon.update_stats()
						mon.hit=mon.hitmax
						stats.print("Umon grew some "..d.power.name.." but lost some "..it.power.name)
					end
					
				end
				nodes.menu=nil play.click=false
			end
		else
		
			nodes.menu=nil
			
		end
	
	end

	gl.PopMatrix()
	
	gl.Color(1,1,1,1)
	
	console.display ("nodes "..#nodes.tab)
	console.display ("mouse "..(play.mx-nodes.px)..","..(play.my-nodes.py))
	
	
end

nodes.add=function(opt)

	local it=node.setup({},opt)
	it.idx=#nodes.tab+1
	nodes.tab[#nodes.tab+1]=it

end

nodes.remove=function(it)

	for i,v in ipairs(nodes.tab) do
		if v==it then
			table.remove(nodes.tab,i)
			return
		end
	end

end


	return nodes
end
