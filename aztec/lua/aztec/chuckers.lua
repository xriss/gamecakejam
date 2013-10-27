-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math

local function dprint(a) print(wstr.dump(a)) end

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,chuckers)
	local chuckers=chuckers or {}
	chuckers.oven=oven
	
	chuckers.modname=M.modname

	local cake=oven.cake
	local opts=oven.opts
	local canvas=cake.canvas
	local font=canvas.font
	local flat=canvas.flat
	local gl=oven.gl
	local sheets=cake.sheets
	
	local sgui=oven.rebake("wetgenes.gamecake.spew.gui")

	local gui=oven.rebake(oven.modgame..".gui")
	local main=oven.rebake(oven.modgame..".main")
--	local beep=oven.rebake(oven.modgame..".beep")

	local chuckers=oven.rebake(oven.modgame..".chuckers")


	local sscores=oven.rebake("wetgenes.gamecake.spew.scores")
	local srecaps=oven.rebake("wetgenes.gamecake.spew.recaps")

	local layout=cake.layouts.create{}


local chucker_add=function(it)
	chuckers.tab[#chuckers.tab+1]=it
	
	it.px=it.px or 320
	it.py=it.py or 240

	it.vx=it.vx or 2
	it.vy=it.vy or 1

	it.ps=it.ps or 16
	it.vs=it.vs or 1/2

end

local chucker_update=function(it)

	it.px=it.px+it.vx
	it.py=it.py+it.vy
	it.ps=it.ps+it.vs
end

local chucker_draw=function(it)

	sheets.get("imgs/ships01"):draw(1,it.px,it.py,nil,it.ps,it.ps)

end



chuckers.loads=function()

end
		
chuckers.setup=function()

chuckers.time=0

chuckers.tab={}

end

chuckers.clean=function()


end

chuckers.msg=function(m)
	
end


chuckers.update=function()

	chuckers.time=chuckers.time+1
	
	if chuckers.time%15 == 0 then
		local it={}
		if (chuckers.time/15)%2 == 0 then
			it.vx=2
		else
			it.vx=-2
		end
		chucker_add(it)
	end
	
	for _,it in ipairs(chuckers.tab) do
		chucker_update(it)
	end
	
end

chuckers.draw=function()
		
	for _,it in ipairs(chuckers.tab) do
		chucker_draw(it)
	end
	
end

	return chuckers
end
