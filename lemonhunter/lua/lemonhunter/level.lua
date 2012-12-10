-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require


local function print(...) _G.print(...) end

local wstr=require("wetgenes.string")
local pack=require("wetgenes.pack")

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M



M.bake=function(state,level)

	level=level or {} 
	level.modname=M.modname
	
	local cake=state.cake
	local sheets=cake.sheets
	
--	local shots=state.rebake("gagano.shots")
	local play=state.rebake("lemonhunter.main_play")
	
	function level.setup()
	
		level.top=0
		level.mid=240-16
		level.bot=480-16
		
	end
	

	function level.clean()
	
	end
	
	function level.update()

	end
	
	function level.msg(m)

	end

	function level.draw()

		sheets.get("imgs/gameback"):draw(1,720/2,480/2)

	end
	
	return level
end
