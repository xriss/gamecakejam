-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math

local function dprint(a) print(wstr.dump(a)) end

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,stars)
	local stars=stars or {}
	stars.oven=oven
	
	stars.modname=M.modname

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

	local sscores=oven.rebake("wetgenes.gamecake.spew.scores")
	local srecaps=oven.rebake("wetgenes.gamecake.spew.recaps")

	local layout=cake.layouts.create{}



stars.loads=function()

end
		
stars.setup=function()

	stars.p1y=0
	stars.p2y=0

end

stars.clean=function()

end

stars.msg=function(m)

end

stars.update=function()
	
	stars.p1y=stars.p1y+0.25
	
	if	stars.p1y>1024 then
		stars.p1y=stars.p1y-1024
	end
	
	stars.p2y=stars.p2y+0.4
	
	if	stars.p2y>1024 then
		stars.p2y=stars.p2y-1024
	end
	
end

stars.draw=function()
	
	local image=sheets.get("imgs/back01")
	
	image:draw(1,256,stars.p1y-1024,nil,1024,1024)
	image:draw(1,256,stars.p1y,nil,1024,1024)
	image:draw(1,256,stars.p1y+1024,nil,1024,1024)
	
	local image=sheets.get("imgs/back02")
	
	image:draw(1,256,stars.p2y-1024,nil,1024,1024)
	image:draw(1,256,stars.p2y,nil,1024,1024)
	image:draw(1,256,stars.p2y+1024,nil,1024,1024)

	
end

	return stars
end
