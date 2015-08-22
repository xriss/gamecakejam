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

	
	return it
end
node.clean=function(it)
end
node.update=function(it)
end
node.draw=function(it)

	sheets.get("imgs/butt_01"):draw(1,it.px,it.py,nil,32*2,32*2)
	sheets.get("imgs/icon_01"):draw(1,it.px-24,it.py-24,nil,16*2,16*2)
	
	if it.num>0 then -- our troops

		local s=""..it.num
		local w=font.width(s)
		font.set_xy(it.px-(w/2),it.py-16)
		font.draw(s)
	
	elseif it.def>0 then -- npc troops

		gl.Color(0,0,0,1)
	
		local s=""..it.def
		local w=font.width(s)
		font.set_xy(it.px-(w/2),it.py-16)
		font.draw(s)
	
		gl.Color(1,1,1,1)
	end


end


nodes.loads=function()

end
		
nodes.setup=function()

	nodes.loads()
	nodes.tab={}
	
	nodes.add{
		px=0,py=0,
		num=2,def=0,
		flava="base",
	}

	nodes.add{
		px=80,py=8,
		num=0,def=2,
		flava="teeth",
	}

	nodes.add{
		px=80*2,py=16,
		num=0,def=2,
		flava="teeth",
	}

	nodes.add{
		px=80*3,py=24,
		num=0,def=2,
		flava="teeth",
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

	local px,py=800/2,600/2+200

	gl.PushMatrix()
	gl.Translate(px,py,0)
	
	font.set(cake.fonts.get("Vera")) -- default font
	font.set_size(24,0)

	for i,it in ipairs(nodes.tab) do
		it:draw()
	end

	gl.PopMatrix()
	
	gl.Color(1,1,1,1)
	
	console.display ("nodes "..#nodes.tab)

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
