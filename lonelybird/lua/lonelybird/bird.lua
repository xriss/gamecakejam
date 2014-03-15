-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math

local function dprint(a) print(wstr.dump(a)) end

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,bird)
	local bird=bird or {}
	bird.oven=oven
	
	bird.modname=M.modname

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

	local ground=oven.rebake(oven.modgame..".ground")
	local walls=oven.rebake(oven.modgame..".walls")
--	local bird=oven.rebake(oven.modgame..".bird")
	local beep=oven.rebake(oven.modgame..".beep")

	local sscores=oven.rebake("wetgenes.gamecake.spew.scores")
	local srecaps=oven.rebake("wetgenes.gamecake.spew.recaps")


bird.loads=function()

end
		
bird.setup=function()

	bird.loads()

	bird.a=1
	
	bird.sx=1
	bird.sy=1
	bird.rz=0

	bird.px=64
	bird.py=128

	bird.vy=0
	bird.ay=8/8

	bird.diecount=0	
	bird.status="fly"
	
	bird.anim=0


--	beep.stream("bird")

end

bird.clean=function()

end

bird.msg=function(m)

--	print(wstr.dump(m))

	
end

bird.flap=function()

	if bird.status~="fly" then return end

	bird.vy=bird.vy-24
	ground.vx=ground.vx-6
	
	beep.play("flap")

end

bird.die=function(vx,vy)

	if bird.status=="fly" then
		bird.status="fall"
		bird.vx=vx or 2
		bird.vy=vy or 0
		bird.sx=bird.sx*2
		bird.sy=bird.sx

		beep.play("die")

	end
end

bird.update=function()

	if bird.status=="fly" then

		bird.anim=bird.anim+1
		
		if bird.anim > 16 then bird.anim=bird.anim-16 end
		
		bird.frame=math.floor(bird.anim/4)
		if bird.frame<1 then bird.frame=2 end


		bird.vy=bird.vy+bird.ay
		
		bird.vy=bird.vy*14/16

		bird.py=bird.py+bird.vy
		
		bird.rz=bird.vy*8
		
		if bird.py<0+16 then

			bird.die(8,0)

		elseif bird.py>512-16 then

			bird.die(8,-16)

		end

	elseif bird.status=="fall" then
	
		bird.frame=4

		bird.diecount=bird.diecount+1

--		bird.a=1-(bird.diecount/256)
--		if bird.a<0 then bird.a=0 end
--		if bird.a>1 then bird.a=1 end

		bird.rz=bird.rz-bird.diecount
--		bird.sx=bird.sx*15/16
--		bird.sy=bird.sx

		bird.vy=bird.vy+bird.ay
		
--		bird.vy=bird.vy*14/16

		bird.px=bird.px+bird.vx
		bird.py=bird.py+bird.vy
		
		if bird.diecount > 60 then
			main.next=oven.rebake(oven.modgame..".main_menu")
		end

	end
	
end

bird.draw=function()

		gl.Color(bird.a,bird.a,bird.a,bird.a)
		sheets.get("imgs/bird"):draw(bird.frame,bird.px,bird.py,bird.rz,64*bird.sx,64*bird.sy)		
		gl.Color(1,1,1,1)
end

	return bird
end
