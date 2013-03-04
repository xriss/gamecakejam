-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local wstr=require("wetgenes.string")

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,talkers)
	talkers=talkers or {}
	
	local cake=oven.cake
	local gl=oven.gl
	local canvas=cake.canvas
	
	local font=canvas.font

	function talkers.loads()
	end
	
	function talkers.setup()
		
		talkers.loads()
		
		talkers.tab={}
		
	end
	
	function talkers.clean()
	end
	
	function talkers.update()
		
		for i=#talkers.tab,1,-1 do local v=talkers.tab[i]
			
			local dx=v.px-v.anchor.px
			local dy=v.py-v.anchor.py+48
			local dd=dx*dx + dy*dy
			local d=math.sqrt(dd) if d<=0 then d=1 end
			dx=dx/d
			dy=dy/d
			local r=-(d-48)/16
			
			v.vx=(v.vx + (dx*r) )
			v.vy=(v.vy + (dy*r) )
			
			if v.px<64		then v.vx=v.vx+(64-v.px)*0.5 end
			if v.px>480-64 then v.vx=v.vx+(480-64-v.px)*0.5 end
			if v.py<64		then v.vy=v.vy+(64-v.py)*0.5 end
			if v.py>480-64 then v.vy=v.vy+(480-64-v.py)*0.5 end

			v.vx=v.vx*((256-128)/256)
			v.vy=v.vy*((256-128)/256)
			v.px=v.px+v.vx
			v.py=v.py+v.vy
			v.scale=v.scale-(1/30)
			if v.scale <= 0 then
				table.remove(talkers.tab,i)
			end
		end
		
	end

	function talkers.draw()		

		font.set(cake.fonts.get("Vera"))
		font.set_size(16)

		for i,v in ipairs(talkers.tab) do
			local w=font.width(v.str)/2
			local lx=(v.px-w-6)-v.anchor.px
			local hx=(v.px+w+6)-v.anchor.px
			local ly=(v.py-8-4)-v.anchor.py+64
			local hy=(v.py+8+6)-v.anchor.py+64
			
			gl.PushMatrix()
			gl.Translate(v.anchor.px,v.anchor.py-64,0)
			local s=v.scale
			if s>1 then s=1 end
			gl.Scale(s,s,a)
			
			gl.Color(1,1,1,1)	
			canvas.flat.tristrip("xyz",{
				lx,	ly,		0,
				hx,	ly,		0,
				lx,	hy,		0,
				hx,	hy,		0,
			})
			
			local tx=v.px-v.anchor.px
			local ty=v.py-v.anchor.py
			local dd=tx*tx + ty*ty
			local d=math.sqrt(dd) if d<=0 then d=1 end
			local tx=tx/d
			local ty=ty/d
			local rx=ty
			local ry=-tx

			canvas.flat.tristrip("xyz",{
				v.anchor.px - v.anchor.px,		v.anchor.py-64 -(v.anchor.py-64),			0,
				v.px-rx*8   - v.anchor.px,		v.py-ry*8   -(v.anchor.py-64),			0,
				v.px+rx*8   - v.anchor.px,		v.py+ry*8   -(v.anchor.py-64),			0,
			})

			gl.Color(0,0,0,1)
			font.set_xy( (v.px-w)-v.anchor.px , 64+(v.py-8)-v.anchor.py )
			font.draw(v.str)

			gl.PopMatrix()
		end
		gl.Color(1,1,1,1)

	end

	function talkers.add(t)

		local v={}
		
		v.px=t.px
		v.py=t.py
		
		v.str=t.str
		v.anchor=t.anchor
		
		v.vx=0
		v.vy=0
		v.scale=2
		
		v.alpha=1

		talkers.tab[#talkers.tab+1]=v
		
		return v
	end
	
	return talkers
end
