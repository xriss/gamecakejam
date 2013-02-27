-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local wstr=require("wetgenes.string")

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,floaters)
	floaters=floaters or {}
	
	local cake=oven.cake
	local gl=oven.gl
	local canvas=cake.canvas
	
	local font=canvas.font

	function floaters.loads()
	end
	
	function floaters.setup()
		
		floaters.loads()
		
		floaters.tab={}
		
	end
	
	function floaters.clean()
	end
	
	function floaters.update()
		
		for i=#floaters.tab,1,-1 do local v=floaters.tab[i]
			v.px=v.px+v.vx
			v.py=v.py+v.vy
			v.alpha=v.alpha-(1/60)
			if v.alpha <= 0 then
				table.remove(floaters.tab,i)
			end
		end
		
	end

	function floaters.draw()		

		font.set(cake.fonts.get(1))
		font.set_size(8)

		for i,v in ipairs(floaters.tab) do
			gl.Color(v.alpha,v.alpha,v.alpha,v.alpha)	
			font.set_xy(v.px-(font.width(v.str)/2),v.py-8)
			font.draw(v.str)
		end

	end

	function floaters.newnum(x,y,num)

		local v={}
		
		v.px=x
		v.py=y
		
		v.num=num
		v.str=wstr.str_insert_number_commas(num)
		
		v.vx=0
		v.vy=-2
		
		v.alpha=1

		floaters.tab[#floaters.tab+1]=v
		
		return v
	end

	function floaters.newstr(x,y,str)

		local v={}
		
		v.px=x
		v.py=y
		
		v.str=str
		
		v.vx=0
		v.vy=1
		
		v.alpha=1

		floaters.tab[#floaters.tab+1]=v
		
		return v
	end
	
	return floaters
end
