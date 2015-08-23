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
	if ( (dx*dx + dy*dy) < 32*32 ) then
		over=2
		if play.mb==1 then
			over=3
		end
	end

	if it.num>=it.def then -- our troops

		sheets.get("imgs/butt_01"):draw(over,it.px,it.py,nil,32*2,32*2)
		sheets.get("imgs/icon_01"):draw(it.icon,it.px-24,it.py-24,nil,16*2,16*2)

		local s=""..it.num
		local w=font.width(s)
		font.set_xy(it.px-math.floor(w/2),it.py-23)
		font.draw(s)
	
	elseif it.def>0 then -- npc troops

		sheets.get("imgs/butt_01"):draw(over+4,it.px,it.py,nil,32*2,32*2)
		sheets.get("imgs/icon_01"):draw(it.icon,it.px-24,it.py-24,nil,16*2,16*2)

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
		links={2,4},
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
		icon=2,
		links={2,6,7},
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
		icon=1,
		links={5},
	}

	nodes.add{
		px=380,py=350,
		num=0,def=3,
		flava="base",
		icon=3,
		links={5,6},
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

	gl.PopMatrix()
	
	gl.Color(1,1,1,1)
	
	console.display ("nodes "..#nodes.tab)
	console.display ("mouse "..(play.mx-nodes.px)..","..(play.my-nodes.py))
	
	if nodes.menu then -- popup
	
	end
	
end

nodes.add=function(opt)

	local it=node.setup({},opt)
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
