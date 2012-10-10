-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require


local function print(...) _G.print(...) end

local wstr=require("wetgenes.string")
local pack=require("wetgenes.pack")

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M


M.bake=function(state,shots)

	shots=shots or {} 
	shots.modname=M.modname
	
	local cake=state.cake
	local sheets=cake.sheets
	
	local meta={}
	
	
	function shots.setup()
	
		shots.list={}
		
	end
	

	function shots.clean()
	
	end
	
	function shots.update()
	
		for i,v in pairs(shots.list) do
			v:update()
		end

	end
	
	function shots.msg(m)

	end

	function shots.draw()

		
		for i,v in pairs(shots.list) do
			v:draw()
		end

	end
	
	function shots.add(opts)
	
		local nme={}
		setmetatable(nme,{__index=meta})
		
		nme:setup(opts)

		return nme
	end


	function meta.setup(shot,opts)
		shot.px=opts.x or 200
		shot.py=opts.y or 200
		
		shot.vx=opts.vx or 0
		shot.vy=opts.vy or -1
		
		shots.list[shot]=shot
	end
	
	function meta.clean(shot)
	end
	
	function meta.update(shot)
		shot.px=shot.px+shot.vx
		shot.py=shot.py+shot.vy
		if shot.px<-128 or shot.px>720+128 or shot.py<-128 or shot.py>480+128 then
			shots.list[shot]=nil
		end
	end
	
	function meta.draw(shot)
		sheets.get("imgs/bullet"):draw(1,shot.px,shot.py)
	end
	
	return shots
end
