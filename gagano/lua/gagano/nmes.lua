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
	
	local meta={}
	
	
	function nmes.setup()
	
		nmes.list={}

		local x=64
		local y=32
		local bx=32
		for i=1,30 do
			
			nmes.add({x=x+16,y=y})
			
			x=x+64
			if x>=720-64 then
				x=bx
				y=y+64
				if bx==64 then bx=32 else bx=64 end
			end
		end
		
	end
	

	function nmes.clean()
	
	end
	
	function nmes.update()
	
		for i,v in pairs(nmes.list) do
			v:update()
		end

	end
	
	function nmes.msg(m)

	end

	function nmes.draw()

		
		for i,v in pairs(nmes.list) do
			v:draw()
		end

	end
	
	function nmes.add(opts)
	
		local nme={}
		setmetatable(nme,{__index=meta})
		
		nme:setup(opts)

		return nme
	end


	function meta.setup(nme,opts)
		nme.px=opts.x or 200
		nme.py=opts.y or 200
		
		nmes.list[nme]=nme
	end
	
	function meta.clean(nme)
	end
	
	function meta.update(nme)
	end
	
	function meta.draw(nme)
		sheets.get("imgs/sub"):draw(1,nme.px,nme.py)
	end
	
	return nmes
end
