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
	it.setmetatable(it,node) -- allow : functions
	
	return it
end
node.clean=function(it)
end
node.update=function(it)
end
node.draw=function(it)
end


nodes.loads=function()

end
		
nodes.setup=function()

	nodes.loads()
	nodes.tab={}

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
		bode.update(it)
		if it.flava=="dead" then
			table.remove(nodes.tab,i)
		end
	end

end

nodes.draw=function()

	for i,it in ipairs(nodes.tab) do
		node.draw(it)
	end
	
	gl.Color(1,1,1,1)
	
	console.display ("nodes "..#nodes.tab)

end


	return nodes
end
