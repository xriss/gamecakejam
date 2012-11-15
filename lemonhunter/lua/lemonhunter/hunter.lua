-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require


local function print(...) _G.print(...) end

local wstr=require("wetgenes.string")
local pack=require("wetgenes.pack")

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M



M.bake=function(state,hunter)

	hunter=hunter or {} 
	hunter.modname=M.modname
	
	local cake=state.cake
	local sheets=cake.sheets
	
--	local shots=state:rebake("gagano.shots")
	local play=state:rebake("lemonhunter.main_play")
	local level=state:rebake("lemonhunter.level")
	local stake=state:rebake("lemonhunter.stake")
	
	function hunter.setup()
	
		hunter.px=720/2
		hunter.py=400
		hunter.pyj=400
		
		hunter.gx=720/2
		hunter.gy=400
		
		hunter.mx=720/2
		hunter.my=400
		
		hunter.rot=0
		hunter.jump=0
		hunter.dd=0
		hunter.howhigh=64
		
		hunter.state="live"
		
		hunter.stand="bot"
		
		hunter.deadcount=0
		
		hunter.do_click=true
	end
	

	function hunter.clean()
	
	end
	
	function hunter.update()
	
--		if hunter.state=="dead" then
--			hunter.deadcount=hunter.deadcount+1
--			if hunter.deadcount>100 then
--				state.game.last_score=play.score
--				state.game.next=state:rebake("gagano.game_menu")
--			end
--			return
--		end

		if hunter.gy<0   then hunter.gy=0   end 
		if hunter.gy>480 then hunter.gy=480 end 
		if hunter.gx<0   then hunter.gx=0   end 
		if hunter.gx>720 then hunter.gx=720 end 
	
		local mul=0.125
		hunter.px=hunter.px*(1-mul) + hunter.gx*mul
		hunter.pyj=hunter.pyj*(1-mul) + hunter.gy*mul

		if hunter.dd and hunter.dd>1 then
			local d=math.abs(hunter.gx-hunter.px)
			local fd=d/hunter.dd
			local j=fd
			if j>0.5 then j=1-j end
			j=j*2
			j=1-j
			j=j*j
			j=1-j
			hunter.jump=j*hunter.howhigh
		else
			hunter.jump=0
		end
		
		hunter.py=hunter.pyj-hunter.jump
		
--		hunter.py=level[hunter.stand] - 32
		
		if hunter.do_click then
			
			if stake.held>0 then -- throw
			
				
				local vx=hunter.mx-stake.px
				local vy=hunter.my-stake.py
				local dd=vx*vx+vy*vy
				local d=math.sqrt(dd)
				if d>1 then
					vx=vx/d
					vy=vy/d

					stake.state="fall"
					stake.held=-10
					stake.vx=vx*32
					stake.vy=vy*32
				end
				
			else --jump
				hunter.gx=hunter.mx
				hunter.gy=hunter.my
				
				if hunter.my<level.mid then
					if hunter.stand=="mid" then
						hunter.howhigh=64
					else
						hunter.howhigh=128
					end
					hunter.dd= math.abs(hunter.gx-hunter.px) 
					hunter.gy=level.mid-32
					hunter.stand="mid"
				else
					if hunter.stand=="bot" then
						hunter.howhigh=64
					else
						hunter.howhigh=128
					end
					hunter.dd= math.abs(hunter.gx-hunter.px) 
					hunter.gy=level.bot-32
					hunter.stand="bot"				
				end
			end
		end
		
		hunter.do_click=false

	end
	
	function hunter.msg(m)

	end

	function hunter.draw()
	
		if hunter.state=="dead" then
			return
		end

		sheets.get("imgs/hero"):draw(1,hunter.px,hunter.py,0,64)

	end
	
	return hunter
end
