-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math

local function dprint(a) print(wstr.dump(a)) end

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,mon)
	local mon=mon or {}
	mon.oven=oven
	
	mon.modname=M.modname

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

	local chars=oven.rebake(oven.modgame..".chars")

local char={} ; char.__index=char

char.setup=function(it,opt)
	local it=it or {}
	setmetatable(it,char) -- allow : functions

	
	it.px=opt.px or 0
	it.py=opt.py or 0

	it.vx=opt.vx or 0
	it.vy=opt.vy or 0

	it.flava=opt.flava or "none"
	
	it.char=opt.char or 17
	
	it.wait=0
	it.count=opt.count or 0
	it.anim=opt.anim or "idle"

	
	return it
end
char.clean=function(it)
end
char.update=function(it)


end
char.draw=function(it)


end


mon.loads=function()

end
		
mon.setup=function()

	mon.loads()

	local it=mon
	local opt={}
	
	it.px=opt.px or -350
	it.py=opt.py or 24

	it.vx=opt.vx or 0
	it.vy=opt.vy or 0

	it.flava=opt.flava or "none"
	
	it.char=opt.char or 1
	
	it.wait=0
	it.count=opt.count or 0
	it.anim=opt.anim or "idle"
	

end

mon.clean=function()
	
end

mon.msg=function(m)

--	print(wstr.dump(m))

end

mon.update=function()

	local it=mon

	if it.anim=="idle" then
	
		it.wait=it.wait+1
		if it.wait>=60 then
			it.anim="jump"
			it.vx=1
			it.vy=-5
			it.wait=0
		end
	
	end

	if it.anim=="jump" then
	
		local e=chars.top()
	
		it.py=it.py+it.vy
		it.vy=it.vy+1/4

		if it.py > 8*3 and it.vy>=0 then
			it.wait=0
			it.py=8*3
			it.vy=0
			it.anim="idle"
		end
		it.px=it.px+it.vx
		if it.px>370 then -- end of line
			it.px=370
		end

		if e then
			if it.vx>0 and it.px>e.px-24 then -- attack
				it.vx=-it.vx
			end
		end

		
	end

	local _
	if     it.anim=="jump" then
		_,it.count=math.modf(it.count+(1/64))
		it.frame=math.floor(it.count*4)
	elseif it.anim=="idle" then
		_,it.count=math.modf(it.count+(1/64))
		it.frame=math.floor(it.count*4)
	end
	
end

mon.draw=function()
	local it=mon

	local i=it.char
	local px=it.px
	local py=it.py
	local f=it.frame

	gl.Color(0,0,0,0.75)
	sheets.get("imgs/mon_01"):draw(i+f,px-3,py,nil,32*3,32*3)
	sheets.get("imgs/mon_01"):draw(i+f,px+3,py,nil,32*3,32*3)
	sheets.get("imgs/mon_01"):draw(i+f,px,py-3,nil,32*3,32*3)

	gl.Color(1,1,1,1)
	sheets.get("imgs/mon_01"):draw(i+f,px,py,nil,32*3,32*3)


end



	return mon
end
