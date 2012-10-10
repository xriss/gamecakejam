-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require


local function print(...) _G.print(...) end

local wstr=require("wetgenes.string")
local pack=require("wetgenes.pack")

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M


M.bake=function(state,nmes)

	nmes=nmes or {} 
	nmes.modname=M.modname
	
	local cake=state.cake
	local sheets=cake.sheets
	
	
	function nmes.setup()
	
		nmes.px=720/2
		nmes.py=40
		
		nmes.gx=720/2
		nmes.gy=400
		
	end
	

	function nmes.clean()
	
	end
	
	function nmes.update()
	

	end
	
	function nmes.msg(m)

	end

	function nmes.draw()

		sheets.get("imgs/sub"):draw(1,nmes.px,nmes.py)

	end
	
	return nmes
end
