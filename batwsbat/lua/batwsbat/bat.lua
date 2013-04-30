-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math


--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,bat)
	bat=bat or {}
	bat.modname=M.modname
	
	local gl=oven.gl
	local cake=oven.cake
	local opts=oven.opts
	local canvas=cake.canvas
	local layouts=cake.layouts
	local font=canvas.font
	local flat=canvas.flat

	local gui=oven.rebake(oven.modgame..".gui")
	local bats=oven.rebake(oven.modgame..".bats")

	
bat.loads=function()
	
end
		
bat.setup=function()

	bat.loads()



	bat.sx=20
	bat.sy=20*5
	
	bat.vx=0
	bat.vy=0
	bat.ax=0
	bat.ay=0
	
	local handicap=gui.data.handicap:value()

	if bat.idx==1 then
	
		bat.sy=bat.sy + handicap*-10
		
		bat.px=0+40
		bat.py=250
		
		bat.side=1
		
		bat.key_up="q"
		bat.key_down="a"

		bat.finger_up=1
		bat.finger_down=2

		bat.vy=-1

	else
	
		bat.sy=bat.sy + handicap*10

		bat.px=800-40
		bat.py=250
		
		bat.side=-1
		
		bat.key_up="up"
		bat.key_down="down"

		bat.finger_up=3
		bat.finger_down=4

		bat.vy=1
		
	end
	
	bat.sy_base=bat.sy


	return bat
end


bat.clean=function()


end

bat.msg=function(m)
--	print(wstr.dump(m))

	local d=0
	if m.class=="key" then
		if m.keyname==bat.key_up then d=-1 end
		if m.keyname==bat.key_down then d= 1 end
		if d then
			if m.action==1 then
				bat.ay=d
			elseif m.action==-1 then
				bat.ay=0
			end
		end
	end

	if m.class=="mouse" then
		if bats.finger_on( bat.finger_up ) then
			if bats.finger_on( bat.finger_down ) then
				bat.ay=0
			else
				bat.ay=-1
			end
		elseif bats.finger_on( bat.finger_down ) then
				bat.ay=1
		else
				bat.ay=0
		end
	end
	
end

bat.update=function()

	if bat.ay~=0 then
		bat.vy=bat.vy+bat.ay
		bat.sy=bat.sy-1
	end
	if bat.sy<0 then bat.sy=0 end

	if bat.vy> 16 then bat.vy= 16 end
	if bat.vy<-16 then bat.vy=-16 end
	
	bat.py=bat.py+bat.vy
	local sy=20+(bat.sy/2)
	
	if bat.py < 0  +sy then bat.py=sy     bat.vy= math.abs(bat.vy) end
	if bat.py > 500-sy then bat.py=500-sy bat.vy=-math.abs(bat.vy) end


end

bat.draw=function()
	
	local sx=bat.sx*0.5
	local sy=bat.sy*0.5
	
	if sy<=0 then return end
	
	local sx2=sx+2
	local sy2=sy+2

	flat.tristrip("xyz",{	
		bat.px-sx,bat.py-sy,0,
		bat.px+sx,bat.py-sy,0,
		bat.px-sx,bat.py+sy,0,
		bat.px+sx,bat.py+sy,0,
		bat.px+sx,bat.py+sy,0,

		bat.px-sx2,bat.py-sy2,0,
		bat.px-sx2,bat.py-sy2,0,
		bat.px+sx2,bat.py-sy2,0,
		bat.px-sx2,bat.py+sy2,0,
		bat.px+sx2,bat.py+sy2,0,

	})

end
		
	return bat
end

