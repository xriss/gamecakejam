-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require


local function print(...) _G.print(...) end

local wstr=require("wetgenes.string")
local pack=require("wetgenes.pack")

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M



M.bake=function(state,lemons)

	lemons=lemons or {} 
	lemons.modname=M.modname
	
	local cake=state.cake
	local sounds=cake.sounds
	local sheets=cake.sheets
	
--	local shots=state.rebake("gagano.shots")
	local play=state.rebake("lemonhunter.main_play")
	local level=state.rebake("lemonhunter.level")
	local hunter=state.rebake("lemonhunter.hunter")
	local stake=state.rebake("lemonhunter.stake")
	
	function lemons.setup()
	

		lemons.list={}
		lemons.bench={}
		
		for i=1,64 do
			local v={}
			
			v.state="dead"
			lemons.list[i]=v
		end
		
		lemons.time=0
		
		lemons.add()

	end
	

	function lemons.clean()
	
	end
	
	function lemons.add(o)

		local v
		for i,vv in ipairs(lemons.list) do
			if vv.state=="dead" then v=vv break end
		end
		if not v then return end
		
		v.state="rise"
		
		v.px=math.random(0+32,720-32)
		v.py=0
		v.rot=0
		v.siz=0
		v.face=1
		v.stand="bot"
		v.speed=2
		if math.random(1,2)==1 then v.stand="mid" end
		if math.random(1,2)==1 then v.face=-1 end


		return v
	end
	
	function lemons.update()
	
		lemons.time=lemons.time+1
		

		local count=0
		for i,v in ipairs(lemons.list) do
			if v.state=="dead" then	else
				count=count+1
			
				if v.state=="rise" then
					if v.siz<64 then
						v.siz=v.siz+1
					end
					if v.siz==64 then
						v.state="walk"
					end
					
					v.py=level[v.stand]-v.siz/2
				end
				if v.state=="walk" then

					v.py=level[v.stand]-v.siz/2
					v.vx=-v.face*v.speed
					v.px=v.px+v.vx
					
					if v.px<0-32 or v.px>720+32 then -- gone off screen
						v.state="dead"
					end
					
					if stake.state=="fall" then
				
						local dx=stake.px-v.px
						local dy=stake.py-v.py
						
						if dx*dx + dy*dy < 64*64 then -- smash
							v.state="fall"
							v.vy=0
							
							stake.kills=(stake.kills*2)+1
							
							play.add_score(stake.kills)
							sounds.beep(sounds.get("sfx/beep"))
						end
						
					end
					
					if hunter.state~="dead" then
					
						local dx=hunter.px-v.px
						local dy=hunter.py-v.py
						
						if dx*dx + dy*dy < 64*64 then -- smash
							hunter.state="dead"
							hunter.vx=v.vx
							hunter.vy=-16
							sounds.beep(sounds.get("sfx/die"))
						end

					end
				
				end
				if v.state=="fall" then
					v.vy=v.vy+1
					v.px=v.px+v.vx
					v.py=v.py+v.vy
					if v.py>480+32 then
						v.state="dead"
					end
				end
			
			end
		end
		
		local max=math.ceil(lemons.time)/300
		
		if count<max and count<64 then
			lemons.add(o)
		end
		
		
	end
	
	function lemons.msg(m)

	end

	function lemons.draw()
	
		local shtl=sheets.get("imgs/lemon")
		local shtd=sheets.get("imgs/lemondie")
		
		for i,v in ipairs(lemons.list) do
			if v.state=="dead" then else
		
			local sht=shtl
			if v.state=="fall" then sht=shtd end
			
			sht:draw(1,v.px,v.py,v.rot,v.siz*v.face,v.siz)

			end
		end

	end
	
	return lemons
end
