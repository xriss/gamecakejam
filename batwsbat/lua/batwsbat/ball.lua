-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math


--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,ball)
	ball=ball or {}
	ball.modname=M.modname
	
	local gl=oven.gl
	local cake=oven.cake
	local opts=oven.opts
	local canvas=cake.canvas
	local layouts=cake.layouts
	local font=canvas.font
	local flat=canvas.flat

	local bats=oven.rebake(oven.modgame..".bats")

	local sscores=oven.rebake("wetgenes.gamecake.spew.scores")


ball.loads=function()
	
end
		
ball.setup=function()

	ball.loads()
	
	ball.vx=4
	ball.vy=4

	ball.px=400
	ball.py=250

	ball.sx=20
	ball.sy=20

	return ball
end


ball.clean=function()


end

ball.msg=function(m)
--	print(wstr.dump(m))

	
end

ball.score=function(side)
	local bat=bats[side]
	
	bat.sy=bat.sy_base
	
	sscores.add(1,3-side)
	
end

ball.update=function()

	ball.px=ball.px+ball.vx
	ball.py=ball.py+ball.vy
	
	if ball.px < 0      then ball.px=ball.px-ball.vx ball.vx= math.abs(ball.vx) ball.score(1) end
	if ball.px > 800    then ball.px=ball.px-ball.vx ball.vx=-math.abs(ball.vx) ball.score(2) end
	if ball.py < 0  +30 then ball.py=ball.py-ball.vy ball.vy= math.abs(ball.vy) end
	if ball.py > 500-30 then ball.py=ball.py-ball.vy ball.vy=-math.abs(ball.vy) end


	for i,bat in ipairs(bats) do
		local dx=ball.px-bat.px
		local dy=ball.py-bat.py
		local sx=(bat.sx+ball.sx)/2
		local sy=(bat.sy+ball.sy)/2
		if dx > -sx and dx < sx and dy > -sy and dy < sy then 
			if bat.side<0 and ball.vx>0 then
--				ball.px=bat.px - sx
				ball.vx=-math.abs(ball.vx)
				ball.vy=ball.vy + 8*(dy/sy)
			elseif bat.side>0 and ball.vx<0 then
--				ball.px=bat.px + sx
				ball.vx= math.abs(ball.vx)
				ball.vy=ball.vy + 8*(dy/sy)
			end
		end
	end

	if ball.vy >  8 then ball.vy= 8 end
	if ball.vy < -8 then ball.vy=-8 end
	
--[[
	local dd=ball.vy*ball.vy
	local dx=math.sqrt((8*8)-dd)
	if ball.vx<0 then
		ball.vx=-dx
	else
		ball.vx=dx
	end
]]

end

ball.draw=function()

	local sx=ball.sx*0.5
	local sy=ball.sy*0.5

	local sx2=sx+2
	local sy2=sy+2

	flat.tristrip("xyz",{	
		ball.px-sx,ball.py-sy,0,
		ball.px+sx,ball.py-sy,0,
		ball.px-sx,ball.py+sy,0,
		ball.px+sx,ball.py+sy,0,
		ball.px+sx,ball.py+sy,0,

		ball.px-sx2,ball.py-sy2,0,
		ball.px-sx2,ball.py-sy2,0,
		ball.px+sx2,ball.py-sy2,0,
		ball.px-sx2,ball.py+sy2,0,
		ball.px+sx2,ball.py+sy2,0,
	})
	
end
		
	return ball
end

