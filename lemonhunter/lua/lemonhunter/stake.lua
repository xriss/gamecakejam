-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require


local function print(...) _G.print(...) end

local wstr=require("wetgenes.string")
local pack=require("wetgenes.pack")

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M



M.bake=function(state,stake)

	stake=stake or {} 
	stake.modname=M.modname
	
	local cake=state.cake
	local sheets=cake.sheets
	
--	local shots=state.rebake("gagano.shots")
	local play=state.rebake("lemonhunter.main_play")
	local level=state.rebake("lemonhunter.level")
	local hunter=state.rebake("lemonhunter.hunter")
	
	function stake.setup()
	
		stake.px=720/2
		stake.py=200

		stake.vx=0
		stake.vy=0
		
		stake.held=0
		
		stake.state="fall"

	end
	

	function stake.clean()
	
	end
	
	function stake.update()

		if stake.state=="fall" and stake.held<1 then

			local mul=63/64
			
			stake.vy=stake.vy+1/4
			
			stake.vx=stake.vx*mul
			stake.vy=stake.vy*mul
			
			local ly=stake.py

			stake.px=stake.px+stake.vx
			stake.py=stake.py+stake.vy
			
			local siz=32
			
			if stake.px<0+siz   then stake.px=0+siz   stake.vx=math.abs(stake.vx)    end
			if stake.px>720-siz then stake.px=720-siz stake.vx=math.abs(stake.vx)*-1 end
			if stake.py<0+siz   then stake.py=0+siz   stake.vy=math.abs(stake.vy)    end
			
			if stake.py>224-siz and ly<=224-siz then
				if math.abs(stake.vy) < 2 then -- rest
					stake.py=224-siz
					stake.state="rest"
				elseif math.abs(stake.vy) < 16 then
					stake.py=224-siz
					stake.vy=math.abs(stake.vy)*-1
				end
			end
			
			if stake.py>464-siz then
				if math.abs(stake.vy) < 2 then -- rest
					stake.py=464-siz
					stake.state="rest"
				else
					stake.py=464-siz
					stake.vy=math.abs(stake.vy)*-1
				end
			end

		end

		
		if stake.held>0 then
			stake.px=hunter.px
			stake.py=hunter.py-64
		else
			if stake.held<0 then -- do not catch for a little while
				stake.held=stake.held+1
			end
			
			if stake.held==0 then
				local dx=stake.px-hunter.px
				local dy=stake.py-hunter.py
				
				if dx*dx + dy*dy < 64*64 then
					stake.held=1
					stake.kills=0
				end
			end
		
		end
		
	end
	
	function stake.msg(m)

	end

	function stake.draw()
	
		if stake.state=="dead" then
			return
		end

		sheets.get("imgs/stake"):draw(1,stake.px,stake.py,0,64)

	end
	
	return stake
end
