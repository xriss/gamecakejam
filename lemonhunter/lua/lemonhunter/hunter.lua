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
	
	function hunter.setup()
	
		hunter.px=720/2
		hunter.py=400
		
		hunter.gx=720/2
		hunter.gy=400
		
		hunter.state="live"
		
		hunter.deadcount=0
		
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

		if hunter.gy<240 then hunter.gy=240 end 
		if hunter.gy>460 then hunter.gy=460 end 
		if hunter.gx<0   then hunter.gx=0   end 
		if hunter.gx>720 then hunter.gx=720 end 
	
		hunter.px=hunter.px*0.75 + hunter.gx*0.25
--		hunter.py=hunter.py*0.75 + hunter.gy*0.25
		
--		if hunter.do_shot then
--			shots.add({x=hunter.px,y=hunter.py-32,vx=0,vy=-4})
--			cake.beep("shoot")
--		end
		
--		hunter.do_shot=false

	end
	
	function hunter.msg(m)

	end

	function hunter.draw()
	
		if hunter.state=="dead" then
			return
		end

		sheets.get("imgs/hunter"):draw(1,hunter.px,hunter.py,0,64)

	end
	
	return hunter
end
