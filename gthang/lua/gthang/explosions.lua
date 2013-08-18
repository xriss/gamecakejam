-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math

local function dprint(a) print(wstr.dump(a)) end

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,explosions)
	local explosions=explosions or {}
	explosions.oven=oven
	
	explosions.modname=M.modname

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
	local enemies=oven.rebake(oven.modgame..".enemies")
	local ship=oven.rebake(oven.modgame..".ship")

	local sscores=oven.rebake("wetgenes.gamecake.spew.scores")
	local srecaps=oven.rebake("wetgenes.gamecake.spew.recaps")

	local layout=cake.layouts.create{}

	local explosion={}


	
explosion.setup=function(it,opt)



end

explosion.clean=function(it)

end

explosion.update=function(it)

	
	
end

explosion.draw=function(it)
	


end


explosions.loads=function()

end
		
explosions.setup=function()

explosions.tab = {}

end

explosions.clean=function()

	for i,v in ipairs(explosions.tab) do
		explosion.clean(v)
	end

end

explosions.msg=function(m)
	

end

explosions.update=function()

	for i,v in ipairs(explosions.tab) do
		explosion.update(v)
	end
	
end

explosions.draw=function()

	for i,v in ipairs(explosions.tab) do
		explosion.draw(v)
	end
	
	gl.Color(1,1,1,1)
	
end

explosions.add=function(opt)

	local it2={}
	explosion.setup(it2,opt)
	explosions.tab[#explosions.tab+1]=it2

end

explosions.remove=function(it)

	for i,v in ipairs(explosions.tab) do
		if v==it then
			table.remove(explosions.tab,i)
			return
		end
	end

end

	return explosions
end
