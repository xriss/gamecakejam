-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(state,grapes)
	local grapes=grapes or {}
	grapes.state=state

	local gl=state.cake.gl
	
	local main=state.rebake("cloids.main")
	local game=state.rebake("cloids.main_game")
	local menu=state.rebake("cloids.main_menu")
	local shots=state.rebake("cloids.shots")
	local splats=state.rebake("cloids.splats")

	local wscores=state.rebake("wetgenes.gamecake.spew.scores")

	
grapes.setup=function()

	grapes.items={}

end

grapes.clean=function()
end

grapes.add=function(tab)
	local it={}

	it.argb=tab.argb	
	it.px=tab.px or 0
	it.py=tab.py or 0
	it.vx=tab.vx or 0
	it.vy=tab.vy or 0
	it.rz=tab.rz or 0
	it.siz=1
	it.age=0
	
	if grapes.items[ #grapes.items ] then
		it.link=grapes.items[ #grapes.items ]
	end
	
	grapes.items[ #grapes.items+1 ]=it
	return it
end

grapes.update=function()

	for i=1,#grapes.items do
		if i>#grapes.items then break end
		
		local it=grapes.items[i]
		
--		it.age=it.age+1
		
--		if it.age>maxage-50 then it.siz=(maxage-it.age)/50 end
		
--		if it.age>maxage then it.dead=true end
		
--		it.vx=it.vx*31/32
--		it.vy=it.vy*31/32

		local master=it.link
		if master and master.link then master=master.link end


		if master then
			local dx=master.px-it.px
			local dy=master.py-it.py
			
			local dd=dx*dx + dy*dy
			local d=math.sqrt(dd)
			if d==0 then d=1 end
			
			local nx=dx/d
			local ny=dy/d
			
			it.vx=it.vx+nx*1
			it.vy=it.vy+ny*1
		
			it.vx=it.vx*14/16
			it.vy=it.vy*14/16
		end		

		it.px=it.px+it.vx
		it.py=it.py+it.vy
		
		if it.px<-360 then it.px=-360 if it.vx<0 then it.vx=it.vx*-1 end end
		if it.px> 360 then it.px= 360 if it.vx>0 then it.vx=it.vx*-1 end end
		if it.py<-240 then it.py=-240 if it.vy<0 then it.vy=it.vy*-1 end end
		if it.py> 240 then it.py= 240 if it.vy>0 then it.vy=it.vy*-1 end end
		
		
		for i,v in ipairs(shots.items) do
			if not v.dead then
			
				local dx=v.px - it.px
				local dy=v.py - it.py
				
				if dx*dx + dy*dy < 32*32 then
				
					if it.link then
						it.link=nil
						it.vx=it.vx+math.random(-200,200)/100
						it.vy=it.vy+math.random(-200,200)/100
						
						splats.add({
							argb=it.argb,
							px=it.px,
							py=it.py,
							})
							
						wscores.add(100)

					else
					
						it.dead=true
						splats.add({
							argb=it.argb,
							px=it.px,
							py=it.py,
							})
							
						wscores.add(1000)
						
					end
					
					
					v.dead=true
					break
				end
			end
		end
		
		if it.dead then -- hacks
			table.remove(grapes.items,i)
			i=i-1
		end
	end

	if #grapes.items==0 then -- won
		menu.won=true
		main.next=state.rebake("cloids.main_menu")		
	end

end

grapes.draw=function()

	for i,it in ipairs(grapes.items) do
	
		gl.Color(pack.argb4_pmf4(it.argb))

state.cake.sheets.get("imgs/grape"):draw(1,(720/2)+it.px,(480/2)+it.py,it.rz,it.siz*32,it.siz*32)
	
	end
	
	gl.Color(1,1,1,1)

end
	
	
	return grapes
end
