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
	
	
	function ship.setup()
	
		ship.px=720/2
		ship.py=400
		
		ship.gx=720/2
		ship.gy=400
		
	end
	

	function ship.clean()
	
	end
	
	function ship.update()
	
		if ship.gy<240 then ship.gy=240 end 
		if ship.gy>460 then ship.gy=460 end 
		if ship.gx<0   then ship.gx=0   end 
		if ship.gx>720 then ship.gx=720 end 
	
		ship.px=ship.px*0.75 + ship.gx*0.25
		ship.py=ship.py*0.75 + ship.gy*0.25

	end
	
	function ship.msg(m)

	end

	function ship.draw()

		sheets.get("imgs/ship"):draw(1,ship.px,ship.py)

	end
	
	return ship
end
