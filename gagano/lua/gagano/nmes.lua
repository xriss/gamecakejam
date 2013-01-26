-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require


local function print(...) _G.print(...) end

local wstr=require("wetgenes.string")
local pack=require("wetgenes.pack")

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M


M.bake=function(oven,nmes)

	nmes=nmes or {} 
	nmes.modname=M.modname
	
	local cake=oven.cake
	local sheets=cake.sheets
	
	local meta={}
	
	local shots=oven.rebake("gagano.shots")
	local ship=oven.rebake("gagano.ship")
	local play=oven.rebake("gagano.game_play")
	
	function nmes.setup()
	
		nmes.base_score=1
	
		nmes.list={}

		local x=64
		local y=32
		local bx=32
		local img
		for i=1,30 do
		
			img="imgs/sub"
			if i>10 and i<=20 then
				img="imgs/shark"
			end
			
			nmes.add({x=x+16,y=y,img=img})
			
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
	
		nme.img=opts.img or "imgs/sub"
	
		nme.px=opts.x or 200
		nme.py=opts.y or 200
		
		nme.state="live"
		
		nmes.list[nme]=nme
	end
	
	function meta.clean(nme)
	end
	
	function meta.update(nme)
	
	local can_die = function()

		if ship.state~="dead" then
			local x=nme.px-ship.px
			local y=nme.py-ship.py
			if x*x + y*y < 32*32 then
				ship.state="dead"
				nme.state="dead"
				nme.rz=0+math.random(0,100)
				nme.sx=200+math.random(0,100)
				nme.sy=200+math.random(0,100)
			end
		end
		
		for i,v in pairs(shots.list) do
			local x=nme.px-v.px
			local y=nme.py-v.py
			if x*x + y*y < 32*32 then
				nme.state="dead"
				v.state="dead"
				
					nme.rz=0+math.random(0,100)
					nme.sx=200+math.random(0,100)
					nme.sy=200+math.random(0,100)
					
					cake.beep("sfx/die")
					
					
					if nme.img=="imgs/shark" then
						nmes.base_score=nmes.base_score*2
					else
						nmes.base_score=1
					end

					play.score=play.score+nmes.base_score

				break
			end
		end
	end
	
		if nme.state=="live" then
		
			if math.random(0,1000) < 5 then
				nme.state="swoop"
				nme.vx=(math.random(0,256)-128)/64
			end
			
			can_die()
			
		elseif nme.state=="swoop" then
		
			nme.py=nme.py+5
			nme.px=nme.px+nme.vx
			
			if nme.py>480+64 then
				nme.px=math.random(64,720-64)
				nme.py=-64
				nme.state="swoop"
			end
		
			can_die()
		
		elseif nme.state=="dead" then
		
			nme.rz=nme.rz-5
			nme.sx=nme.sx-5
			nme.sy=nme.sy-5
			
			if nme.sx<=0 or nme.sy<=0 then
				nmes.list[nme]=nil
				
				nmes.add({x=math.random(64,720-64),y=-64,img=nme.img})
				nmes.add({x=math.random(64,720-64),y=-64,img=nme.img})
				
			end
		end
	end
	
	function meta.draw(nme)
		if nme.state=="live" then
		
			sheets.get(nme.img):draw(1,nme.px,nme.py)
			
		elseif nme.state=="swoop" then
		
			sheets.get(nme.img):draw(1,nme.px,nme.py)
			
		elseif nme.state=="dead" then
		
			sheets.get("imgs/boom"):draw(1,nme.px,nme.py,nme.rz,nme.sx,nme.sy)
		end
	end
	
	return nmes
end
