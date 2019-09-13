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
	local font=canvas.font
	local flat=canvas.flat

	local sheets=cake.sheets

	local gui=oven.rebake(oven.modgame..".gui")
	local bats=oven.rebake(oven.modgame..".bats")
	local balls=oven.rebake(oven.modgame..".balls")
	local emits=oven.rebake(oven.modgame..".emits")

	local beep=oven.rebake(oven.modgame..".beep")

	
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
	bat.rz=0
	
	local handicap=gui.data.handicap:value()

	if bat.idx==1 then
	
		bat.sy=bat.sy + handicap*-10
		
		bat.px=0+80
		bat.py=250
		
		bat.side=1
		
		bat.key_up="q"
		bat.key_down="a"

		bat.finger=1

		bat.vy=-1

	else
	
		bat.sy=bat.sy + handicap*10

		bat.px=800-80
		bat.py=250
		
		bat.side=-1
		
		bat.key_up="up"
		bat.key_down="down"

		bat.finger=2

		bat.vy=1
		
	end
	
	bat.sy_base=bat.sy


	bat.emit=nil

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
			
			bats.fingers=nil
			
		end

--[[
	elseif m.class=="joykey" then
	
		if bat.finger==1 then
			if m.keycode==106 then
--				if m.action==-1 then
					bat.vy=0
					bat.ay=0
--				end
			end
		else
			if m.keycode==107 then
--				if m.action==-1 then
					bat.vy=0
					bat.ay=0
--				end
			end		
		end
]]
	elseif m.class=="joystick" then -- share a single controller, use the sticks for left-right players

		if bat.finger==1 then
		

			if m.ly<-0.125 then
				bat.ay=-1
			elseif m.ly>0.125 then
				bat.ay= 1
			else
				bat.ay=0
			end			

		else

			if m.ry<-0.125 then
				bat.ay=-1
			elseif m.ry>0.125 then
				bat.ay= 1
			else
				bat.ay=0
			end

		end

	end
	
end

bat.spurt=function(vx,vy)

	local e=bat.emit
	
	if e and e.life > e.time then
	
		e.life=e.time+4
		e.vx=vx
		e.vy=vy
		
		e.px=bat.px
		e.py=bat.py + vy*bat.sy*0.5 - vy*20
		
	else

		bat.emit=emits.spurt.create{
			px=bat.px,
			py=bat.py + vy*bat.sy*0.5 - vy*20,
			vx=vx,
			vy=vy,
--			gx=-vx,
--			gy=-vy,
			burst=1,
			life=4,
			gg=balls[1],
		}

	end
	
end

bat.update=function()

	local rz=bat.vy*3*bat.side
	bat.rz=(rz-bat.rz)*0.1 + bat.rz


	if bats.fingers then -- touch control
	
		local finger=bats.fingers[bat.finger]
		
		if finger then
		
			local sy=bat.sy/2
			if sy<10 then sy=10 end

			local dy=math.abs(bat.vy)
			local ty=0
			while dy>0 do ty=ty+dy dy=dy-1 end -- stoping distance

			local yadd= dy
			local ysub=-dy
--			if bat.vy<0 then yadd=0 else ysub=0 end
		
			if     bat.py+(sy)+yadd < finger then
				if bat.vy< 8 then bat.ay= 1 else bat.ay=0 end
			elseif bat.py-(sy)+ysub > finger then
				if bat.vy>-8 then bat.ay=-1 else bat.ay=0 end
			else
				if     bat.vy> 1 then
					bat.ay=-1
				elseif bat.vy<-1 then
					bat.ay= 1
				else
					bat.ay=0
					bat.vy=0
				end
			end
		else
			bat.ay=0
		end
		
	end

	if bat.ay~=0 and bat.sy>=0 then
		bat.vy=bat.vy+(bat.ay/2)
		if     bat.vy> 16 then
			bat.vy= 16
		elseif bat.vy<-16 then
			bat.vy=-16
		else
			bat.sy=bat.sy-(1/2)
			if bat.sy<0 then bat.sy=0 end
			
			bat.spurt(0,-bat.ay)
		end
	end
	
	if bat.sy<0 then bat.sy=0 end

--	if bat.sy==0 then bat.vy=0 end

	
	bat.py=bat.py+bat.vy
	local sy=20+(bat.sy/2)
	
	if bat.py < 0  +sy then

		bat.py=sy
		bat.vy= math.abs(bat.vy)

		emits.spurt.create{
			px=bat.px,
			py=0,
			vx=0,
			vy=1,
			burst=1,
			life=math.floor(math.abs(bat.vy)),
			gg=balls[1],
		}

		beep.play("bathitwall")

	end
	if bat.py > 500-sy then

		bat.py=500-sy
		bat.vy=-math.abs(bat.vy)

		emits.spurt.create{
			px=bat.px,
			py=500,
			vx=0,
			vy=-1,
			burst=1,
			life=math.floor(math.abs(bat.vy)),
			gg=balls[1],
		}

		beep.play("bathitwall")

	end


end

bat.draw=function()
	
	local sx=bat.sx*0.5
	local sy=bat.sy*0.5
	

	gl.Color(1,1,1,1)

	local s=sheets.get( "imgs/bat"..bat.finger )
	s:draw(1, bat.px , bat.py, bat.rz )
	
	if sy<=0 then return end

	
	local sx2=sx+4
	local sy2=sy+4

	gl.Color(0,0,0,1)
	flat.tristrip("xyz",{	
		bat.px-sx2,bat.py-sy2,0,
		bat.px+sx2,bat.py-sy2,0,
		bat.px-sx2,bat.py+sy2,0,
		bat.px+sx2,bat.py+sy2,0,
	})

	gl.Color(0,1,0,1)
	flat.tristrip("xyz",{	
		bat.px-sx,bat.py-sy,0,
		bat.px+sx,bat.py-sy,0,
		bat.px-sx,bat.py+sy,0,
		bat.px+sx,bat.py+sy,0,
	})
	

--[[
	
	local ps={
		{"imgs/bat"..bat.finger.."_arm1",	1 },
		{"imgs/bat"..bat.finger.."_arm2",	1 },
		{"imgs/bat"..bat.finger.."_leg1",	1 },
		{"imgs/bat"..bat.finger.."_leg2",	1 },
		{"imgs/bat"..bat.finger.."_back",	0.0 },	
--		{"imgs/bat"..bat.finger.."_mouth",	1 },
		{"imgs/bat"..bat.finger.."_face",	1 },
	}
	
	gl.Color(1,1,1,1)
	gl.PushMatrix()
	gl.Translate(bat.px,bat.py,0)
	gl.Rotate(90,0,0,bat.side)
	
--	gl.Scale(bat.sy/60,1,1)

	local sa=bat.sy/60
	for i,v in ipairs(ps) do
		gl.PushMatrix()
		local sb=sa
		if sb<v[2] then sb=v[2] end
		gl.Scale(sb,1,1)

		local s=sheets.get( v[1] )
		s:draw(1,0,0)
		gl.PopMatrix()
	end

	gl.PopMatrix()
]]

end
		
	return bat
end

