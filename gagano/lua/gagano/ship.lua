-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require


local function print(...) _G.print(...) end

local wstr=require("wetgenes.string")
local pack=require("wetgenes.pack")

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M



M.bake=function(state,ship)

	ship=ship or {} 
	ship.modname=M.modname
	
	local cake=state.cake
	local sheets=cake.sheets
	
	local shots=state.rebake("gagano.shots")
	local play=state.rebake("gagano.game_play")
	
	function ship.setup()
	
		ship.px=720/2
		ship.py=400
		
		ship.gx=720/2
		ship.gy=400
		
		ship.state="live"
		
		ship.deadcount=0
		
	end
	

	function ship.clean()
	
	end
	
	function ship.update()
	
		if ship.state=="dead" then
			ship.deadcount=ship.deadcount+1
			if ship.deadcount>100 then
				state.game.last_score=play.score
				state.game.next=state.rebake("gagano.game_menu")
			end
			return
		end

		if ship.gy<240 then ship.gy=240 end 
		if ship.gy>460 then ship.gy=460 end 
		if ship.gx<0   then ship.gx=0   end 
		if ship.gx>720 then ship.gx=720 end 
	
		ship.px=ship.px*0.75 + ship.gx*0.25
		ship.py=ship.py*0.75 + ship.gy*0.25
		
		if ship.do_shot then
			shots.add({x=ship.px,y=ship.py-32,vx=0,vy=-4})
			cake.beep("shoot")
		end
		
		ship.do_shot=false

	end
	
	function ship.msg(m)

	end

	function ship.draw()
	
		if ship.state=="dead" then
			return
		end

		sheets.get("imgs/ship"):draw(1,ship.px,ship.py)

	end
	
	return ship
end
