-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math


module(...)


bake=function(game)
	local state=game.state
	local cake=state.cake
	local opts=state.opts
	local canvas=state.canvas
	local font=canvas.font
	local flat=canvas.flat
	local gl=cake.gl

	local play={}
	game.play=play
	
	function icehit(v)
		local f=function(p)
			local x=p.x-v.x
			local y=p.y-v.y
			if x*x+y*y < p.d*p.d then
				return true
			end
		end		
		return f{x=320,y=400,d=80} or f{x=320,y=360,d=30}
	end

function new_plane(id)

	local plane={}
	plane.id=id
	
	plane.score=0
	
	plane.spawn=function()
		plane.state="fly"
		plane.immune=50
		plane.x=50+math.random(0,540)
		plane.y=50+math.random(0,150)
		plane.vx=0
		plane.vy=0
		plane.rz=-90
		plane.vv=0
		plane.heat=0
		plane.pews={}
	end
	plane.spawn()
	
	plane.update=function()
	
		plane.heat=plane.heat-1
		plane.immune=plane.immune-1
		
		local i=1
		while plane.pews[i] do
			local v=plane.pews[i]
			v.update()
			if v.state=="dead" then table.remove(plane.pews,i) else i=i+1 end
		end
		
		if plane.fx then plane.fx.update() end

		if plane.state=="dead" then
			plane.dead_count=plane.dead_count+1
			if plane.dead_count>60 then
				plane.spawn()
			end
			return
		end
	
		if plane.rz>360 then plane.rz=plane.rz-360 end
		if plane.rz<0   then plane.rz=plane.rz+360 end

		if plane.x>640 then plane.x=plane.x-640 end
		if plane.x<0   then plane.x=plane.x+640 end

		if plane.y>480 then return plane.bang() end
		if plane.y<0   then return plane.bang() end
		if icehit(plane) then return plane.bang() end
		
		local r=math.pi*plane.rz/180
		local vx=-math.cos(r)
		local vy=-math.sin(r)
		
		plane.vv=plane.vv+(vy/8)
		plane.vv=plane.vv*(248/256)
		
		
		plane.vx=vx*plane.vv
		plane.vy=vy*plane.vv
		
		plane.vy=plane.vy+0.1
		plane.x=plane.x+plane.vx
		plane.y=plane.y+plane.vy
		
		if game.input["p"..plane.id.."_left"]  then plane.rz=plane.rz-4 end
		if game.input["p"..plane.id.."_right"] then plane.rz=plane.rz+4 end
		
		if plane.vv<=0 then
			if plane.rz>90+180 then plane.rz=plane.rz-360 end
			local d=(plane.rz-90) - ((plane.rz-90)*15/16)
			if d<-5 then d=-5 elseif d>5 then d=5 end
			plane.rz=plane.rz + d
		end

		if game.input["p"..plane.id.."_up"]  then plane.vv=plane.vv+0.2 end
--		if game.input["p"..plane.id.."_down"] then if plane.vv>0 then plane.vv=plane.vv-0.2 end end

		if game.input["p"..plane.id.."_fire"]  then plane.pew() end
		
	end
	plane.draw=function()
		if plane.state~="dead" then
			gl.Color(pack.argb4_pmf4(0xffff)) 
			if plane.immune>=0 then
				gl.Color(pack.argb4_pmf4(0x8fff)) 
			end
			cake.sheets:get("plane"..plane.id):draw(1,plane.x,plane.y,plane.rz,128/2,128/2)
		end
		if plane.fx then plane.fx.draw() end
		
		for i,v in ipairs(plane.pews) do
			v.draw()
		end

	end
	plane.pew=function()
		if plane.heat>0 then return end
		plane.heat=30
		local p={}
		p.score=0
		plane.pews[#plane.pews+1]=p
		p.x=plane.x
		p.y=plane.y
		local r=math.pi*plane.rz/180
		local vx=-math.cos(r)
		local vy=-math.sin(r)
		p.vx=vx*10 + plane.vx
		p.vy=vy*10 + plane.vy
		p.update=function()
			p.x=p.x+p.vx
			p.y=p.y+p.vy
			if p.x>640 or p.x<0 then p.state="dead" end
			if p.y>480 or p.y<0 then p.state="dead" end
			if icehit(p) then
				p.score=1
				p.vx=p.x-320
				p.vy=p.y-480
				local d=1/math.sqrt((p.vx*p.vx) + (p.vy*p.vy))
				p.vx=p.vx*d*10
				p.vy=p.vy*d*10
			end
			for i,v in ipairs(play.planes) do
				if v.state=="fly" and v.id~=plane.id then
					if v.immune < 0 then
						local x=v.x-p.x
						local y=v.y-p.y
						if x*x + y*y < 28*28 then
							v.bang()
							plane.score=plane.score+1+p.score
							p.state="dead"
						end	
					end
				end
			end
		end
		p.draw=function()
			cake.sheets:get("pew"):draw(1,p.x,p.y,0,16,16)
		end
	end
	plane.bang=function()
		plane.state="dead"
		plane.dead_count=0
		local fx={}	
		plane.fx=fx
		fx.age=0
		fx.x=plane.x
		fx.y=plane.y
		fx.rz=plane.rz
		fx.ss=1
		fx.update=function()
			fx.age=fx.age+1
			fx.rz=fx.rz+5
			fx.ss=fx.ss*15/16
			if fx.age>60 then
				plane.fx=nil
			end
		end
		fx.draw=function()
			gl.Color(1,1,1,0)
			cake.sheets:get("boom"):draw(1,fx.x,fx.y,fx.rz,fx.ss*128,fx.ss*128)
		end
	end
	
	play.planes[id]=plane
end


play.reset=function(state)
	play.planes={}
	new_plane(#play.planes+1)
	new_plane(#play.planes+1)
	new_plane(#play.planes+1)
	new_plane(#play.planes+1)
end


play.update=function(state)

	for i,v in ipairs(play.planes) do
		v.update()
	end
end

play.draw=function(state)
--print("draw")
	

	gl.Color(pack.argb4_pmf4(0xffff)) 
	cake.sheets:get("back"):draw(1,0,0,0,640,480)

	for i,v in ipairs(play.planes) do
		v.draw()
	end

	gl.Color(pack.argb4_pmf4(0xffff)) 
	cake.sheets:get("cone"):draw(1,0,0,0,640,480)

--	gl.Color(pack.argb4_pmf4(0xffff))
	gl.Color(1,1,1,0)
	cake.sheets:get("clouds"):draw(1,0,0,0,640,480)
	
	return play.drawscore()
	
end

play.drawscore=function(state)
	local max=0
	if play.planes then
		for i,v in ipairs{{32,32-16,0xffff},{640-32,32-16,0xf0f0},{32,480-32-16,0xff00},{640-32,480-32-16,0xff0f}}do
			local p=play.planes[i]
			if p then
				local s=string.format("%d",p.score)
				local sw=font:width(s) -- how wide the string is
				font:set_size(32,0) -- 32 pixels high
				gl.Color(pack.argb4_pmf4(v[3]))
				font:set_xy(v[1]-(sw/2),v[2])
				font:draw(s)
				if p.score>max then max=p.score end
			end
		end
	end
	return max
end
	return play
end

