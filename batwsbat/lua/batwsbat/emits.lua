-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local function print(...) _G.print(...) end

local wstr=require("wetgenes.string")


local function mrandom(mn,mx,mp)
	return math.random(mn/mp,mx/mp)*mp
end


local M={ modname=(...) } ; package.loaded[M.modname]=M

function M.bake(oven,emits)
	local emits=emits or {}
	local parts={}
	
	local cake=oven.cake
	local game=cake.game
	local gl=oven.gl

	local canvas=cake.canvas
	local flat=canvas.flat

	local balls=oven.rebake(oven.modgame..".balls")

-- BASE
	do
		local f={}		emits.base=f

		function f.create(e)

			e.destroy=e.f.destroy or emits.base.destroy
			e.update=e.f.update or emits.base.update
			e.draw=e.f.draw or emits.base.draw

			e.pcreate=e.f.pcreate or emits.base.pcreate
			e.pdestroy=e.f.pdestroy or emits.base.pdestroy
			e.pupdate=e.f.pupdate or emits.base.pupdate
			e.pdraw=e.f.pdraw or emits.base.pdraw

			emits.tab[ #emits.tab+1 ]=e

			e.tab={}

			e.pr=e.pr or 0
			e.px=e.px or 0 -- position
			e.py=e.py or 0

			e.vr=e.vr or 0
			e.vx=e.vx or 0 -- velocty
			e.vy=e.vy or 0

			e.state="live"
			
			e.time		=e.time			or 0
			e.life		=e.life			or 1
			e.burst		=e.burst		or 1
			
			return e
		end
		function f.destroy(e)
			e.state="dead"
		end
		function f.update(e)
		
			e.time=e.time+1
		
			e.pr=e.pr+e.vr
			e.px=e.px+e.vx
			e.py=e.py+e.vy
			
			for i=#e.tab,1,-1 do
				local p=e.tab[i]
				if p.state~="dead" then e.pupdate(p)	end
				if p.state=="dead" then table.remove(e.tab,i) end
			end
			

			if e.time<=e.life then -- still alive so spit stuff out
				for i=1,e.burst do
					e.pcreate(e)
				end
			else 						-- we are dormant
				if not e.tab[1] then 	-- and dead
					e.destroy(e)
				end
			end
			
		end
		function f.draw(e)
			for i=#e.tab,1,-1 do
				local p=e.tab[i]
				e.pdraw(p)
			end
		end

		function f.pcreate(e,p)
			p.e=e
			
			e.tab[ #e.tab+1 ]=p

			p.pr=p.pr or e.pr or 0
			p.px=p.px or e.px or 0 -- position
			p.py=p.py or e.py or 0

			p.vr=p.vr or e.vr or 0
			p.vx=p.vx or e.vx or 0 -- velocity
			p.vy=p.vy or e.vy or 0

			p.state="live"
			
			p.time = p.time or 0
			p.life = p.life or 1
			
			return p
		end
		function f.pdestroy(p)
			p.state="dead"
		end
		function f.pupdate(p)
			p.time=p.time+1
			p.pr=p.pr+p.vr
			p.px=p.px+p.vx
			p.py=p.py+p.vy
			if p.time>p.life then -- we are dead
				p.e.pdestroy(p)
			end
		end
		function f.pdraw(p)
		end
	end

-- BLOB
	do
		local f={}		emits.blob=f
		function f.create(t)
			t.f=f
			local e=emits.base.create(t)
			e.id=t.id or 1
			return e
		end
		function f.pcreate(e,t)

			if not t then
				t={
					px=e.px,
					py=e.py,
					vr=mrandom(-4,4,1/64),
					vx=mrandom(-2,2,1/64),
					vy=mrandom(-6,-8,1/64),
					life=128,
					id=e.id,
				}
			end

			local p=emits.base.pcreate(e,t)
			p.id=t.id or 18
			p.a=1
			return p
		end
		function f.pupdate(p)
			emits.base.pupdate(p)
			p.a=p.a*(31/32)
			p.vy=p.vy+(1/8)
		end
		function f.pdraw(p)
			emits.base.pdraw(p)
			local s=p.time--((1-p.a)*64)
			gl.Color(p.a,p.a,p.a,p.a)
--			local bulbs=cake.sheets.get("bulbs")
--			bulbs:draw(p.id,p.px,p.py,p.pr,s)
		end
	end
	
-- SPURT
	do
		local f={}		emits.spurt=f
		function f.create(t)
			t.f=f
			local e=emits.base.create(t)
			return e
		end
		function f.pcreate(e,t)

			if not t then
				t={
					px=e.px,
					py=e.py,
--					vr=mrandom(-4,4,1/64),
					life=64,
					id=e.id,
				}

				if math.abs(e.vx or 0) > math.abs(e.vy or 0) then -- x mode
					t.vx=e.vx*mrandom(8,16,1/64)
					t.vy=mrandom(-3,3,1/64)
				else
					t.vx=mrandom(-3,3,1/64)
					t.vy=e.vy*mrandom(8,16,1/64)
				end
				
				t.gx=e.gx -- gravity
				t.gy=e.gy
				t.gg=e.gg
			end

			local p=emits.base.pcreate(e,t)
			p.points={}
			p.a=1
			p.r=math.random(32,255)/255
			p.g=1 -- math.random(64,255)/255
			p.b=math.random(32,255)/255
			return p
		end
		function f.pupdate(p)
			emits.base.pupdate(p)

			local d={}
			d.x1=p.px+p.vy*0.25
			d.y1=p.py-p.vx*0.25
			d.x2=p.px-p.vy*0.25
			d.y2=p.py+p.vx*0.25
			p.points[ #p.points+1 ]=d
			
			if #p.points>16 then table.remove(p.points,1) end

--			local pa=( p.life-p.time ) / p.life
--			p.a=p.a*(30/32)

local b=p.gg --balls[1]
local dx=p.px-b.px
local dy=p.py-b.py
local dd=dx*dx + dy*dy
local d=math.sqrt(dd) if d*d < 0.01 then d=1 end
dx=-dx/d
dy=-dy/d

			p.vx=p.vx+ (4/8)*(p.gx or dx)
			p.vy=p.vy+ (4/8)*(p.gy or dy)
			
			p.vx=p.vx*(31/32)
			p.vy=p.vy*(31/32)

		end
		function f.pdraw(p)
			if #p.points<2 then return end
			
			emits.base.pdraw(p)
			local t={}
			
			local pa=( p.life-p.time ) / p.life
			pa=pa*pa
			local l=#p.points
			for i=l,1,-1 do local d=p.points[i]

				local a=pa*i/l
			
				t[#t+1]=d.x1
				t[#t+1]=d.y1
				t[#t+1]=0

				t[#t+1]=a
				t[#t+1]=a
				t[#t+1]=a
				t[#t+1]=a

				t[#t+1]=d.x2
				t[#t+1]=d.y2
				t[#t+1]=0

				t[#t+1]=a
				t[#t+1]=a
				t[#t+1]=a
				t[#t+1]=a
			
			end
	
			gl.Color(p.r,p.g,p.b,0)
			flat.tristrip("xyzrgba",t)
--[[
			local s=p.time--((1-p.a)*64)
			gl.Color(p.a,p.a,p.a,p.a)
			local bulbs=cake.sheets.get("bulbs")
			bulbs:draw(p.id,p.px,p.py,p.pr,s,s)
]]
		end
	end	
	
local function draw_circ(px,py,r1,r2,s)
	local t={}

	local x,y
	for i=0,s do
	
		x=-math.sin(i*2*math.pi/s)
		y=math.cos(i*2*math.pi/s)

		t[#t+1]=px + r1 * x
		t[#t+1]=py + r1 * y
		t[#t+1]=0

		t[#t+1]=1
		t[#t+1]=0
		t[#t+1]=0
		t[#t+1]=0

		t[#t+1]=px + r2 * x
		t[#t+1]=py + r2 * y
		t[#t+1]=0

		t[#t+1]=1
		t[#t+1]=1
		t[#t+1]=0
		t[#t+1]=0
	
	end

	flat.tristrip("xyzrgba",t)
	

end	
-- BOOM
	do
		local f={}		emits.boom=f
		function f.create(t)
			t.f=f
			local e=emits.base.create(t)
			return v
		end
		function f.pcreate(e,t)

			if not t then
				t={
					px=e.px,
					py=e.py,
					vr=mrandom(-4,4,1/64),
					life=128,
					id=e.id,
					r1=mrandom(32,64,1/64),
					r2=mrandom(32,64,1/64),
				}
			end

			local p=emits.base.pcreate(e,t)
			p.a=1
			p.r1=t.r1 or 64
			p.r2=t.r2 or 64
			return p
		end
		function f.pupdate(p)
			emits.base.pupdate(p)

			p.a=p.a*(30/32)

		end
		function f.pdraw(p)
			
			emits.base.pdraw(p)

			gl.Color(p.a,p.a,p.a,0)

			gl.PushMatrix()
			gl.Translate(p.px,p.py,0)
			gl.Rotate(p.pr,0,0,1)
			
			draw_circ(0,0,p.r1+p.time*16,p.r1+p.time*16+p.r2,12)

			if p.time<p.r1 then
				draw_circ(0,0,0,p.r1-p.time,12)
			end

			gl.PopMatrix()
			
		end
	end	
	

		
	
	function emits.loads()
	end
	
	function emits.clean()
	end
	
	function emits.setup()
		
		emits.tab={}
		
	end
	
	function emits.update()
	
		for i=#emits.tab,1,-1 do local it=emits.tab[i]
			it:update()
			if it.state=="dead" then table.remove(emits.tab,i) end
		end
		
	end

	function emits.draw()

		for i=#emits.tab,1,-1 do local it=emits.tab[i]
			it:draw()
		end

		gl.Color(1,1,1,1)	
	end

	return emits
end
