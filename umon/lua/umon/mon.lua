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
	local fight=oven.rebake(oven.modgame..".fight")
	local world=oven.rebake(oven.modgame..".world")
	local nodes=oven.rebake(oven.modgame..".nodes")
	
	local beep=oven.rebake(oven.modgame..".beep")
	
local char={} ; char.__index=char

mon.loads=function()

end
		
mon.setup=function()

	mon.loads()

	local it=mon
	local opt={
			gold=1,
			atk=1,
			def=1,
			spd=1,
			hit=1,
			name="umon",
	}
	
	it.rank=1
	
	it.px=opt.px or -350
	it.py=opt.py or 24

	it.vx=opt.vx or 0
	it.vy=opt.vy or 0

	it.flava=opt.flava or "none"
	
	it.char=opt.char or 1
	
	it.wait=0
	it.count=opt.count or 0
	it.anim=opt.anim or "idle"
	
	fight.setup(it,opt)

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
		if it.wait>=fight.get_wait(it) then
			it.anim="jump"
			it.vx=1 + (it.spd/4)
			it.vy=-5 - (it.atk/4)
			it.wait=0
			if it.vy<-10 then it.vy=-10 end
		end
	
	end

	if it.anim=="jump" then
	
		local e=chars.get_active()
	
		it.py=it.py+it.vy
		it.vy=it.vy+1

		if it.py > 8*3 and it.vy>=0 then
			it.wait=0
			it.py=8*3
			it.vy=0
			it.anim="idle"
		end
		it.px=it.px+it.vx
		if it.px>370 then -- end of line (win)
			it.px=370
			it.rank=it.rank+1
			return world.rest()
		end

		if e then
			if it.vx>0 and it.px>e.px-24 then -- attack
				it.vx=-it.vx/2

				fight.attack(it,e)
			end
		end

		
	end

	if it.anim~="die" and it.anim~="dead" and it.anim~="rest" then
		if it.hit<=0 then -- time to die

			it.anim="die"
			it.vx=-1
			it.vy=-6

			beep.play("die")
		end
	end
	
	if it.anim=="die" then
	
		it.px=it.px+it.vx
		it.py=it.py+it.vy
		it.vy=it.vy+1
		
		if it.py > 8*3 and it.vy>=0 then
			it.wait=0
			it.py=8*3
			it.vy=0
			it.vx=0
			it.anim="dead"
		end
		
	end

	local _
	if     it.anim=="jump" then
		_,it.count=math.modf(it.count+(1/16))
		it.frame=math.floor(4+it.count*4)
	elseif it.anim=="idle" then
		_,it.count=math.modf(it.count+(1/64))
		it.frame=math.floor(it.count*4)
	elseif it.anim=="rest" then
		_,it.count=math.modf(it.count+(1/64))
		it.frame=math.floor(8+it.count*4)
	elseif it.anim=="die" then
		it.frame=14
	elseif it.anim=="dead" then
		it.frame=15
	end
	
	if it.anim=="dead" and it.rest>=1 then
	
		world.rest()
	
	end

	if it.anim=="rest" then
		it.wait=it.wait+1
		if it.wait>30 then
			it.wait=0
			it.hit=it.hit+1
		end
		if it.hit>=it.hitmax then
			world.fight()
		end
	end
	
end

mon.draw=function()
	local it=mon

	local i=it.char
	local px=it.px
	local py=it.py
	local f=it.frame
	
	local n="imgs/mon_01"
	if mon.atk>=20 then
		n="imgs/mon_02"
	end

	gl.Color(0,0,0,0.75)
	sheets.get(n):draw(i+f,px-3,py,nil,32*3,32*3)
	sheets.get(n):draw(i+f,px+3,py,nil,32*3,32*3)
	sheets.get(n):draw(i+f,px,py-3,nil,32*3,32*3)

	gl.Color(1,1,1,1)
	sheets.get(n):draw(i+f,px,py,nil,32*3,32*3)


end

mon.goto_rest=function()

	local it=mon
	
	it.anim="rest"
	it.rest=0
	
	it.px=0
	it.py=24
	
	it.vx=0
	it.vy=0
	
	if it.hit>=it.hitmax then it.hit=it.hitmax-1 end
	
--	it.hit=0

end

mon.goto_fight=function()

	local it=mon
	
	it.anim="idle"
	it.rest=0
	it.wait=0
	
	it.px=400-(#chars.tab+3)*50
	it.py=24
	
	it.vx=0
	it.vy=0

end


mon.update_stats=function()

	local ss={atk=1,def=1,spd=1,hit=1}

	local it=mon
	
	for i,v in ipairs(nodes.tab) do
		if v.num>=v.def then 
			local p=v.power
			for n,t in pairs(ss) do
				ss[n]=ss[n] + (p[n] or 0)*v.num
			end
		end
	end
	
	if ss.atk<1 then ss.atk=1 end
	if ss.def<1 then ss.def=1 end
	if ss.spd<1 then ss.spd=1 end
	if ss.hit<1 then ss.hit=1 end

	mon.atk=ss.atk
	mon.def=ss.def
	mon.spd=ss.spd
	mon.hitmax=ss.hit
	

end


	return mon
end
