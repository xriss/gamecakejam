-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math

local function dprint(a) print(wstr.dump(a)) end

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,walls)
	local walls=walls or {}
	walls.oven=oven
	
	walls.modname=M.modname

	local cake=oven.cake
	local opts=oven.opts
	local canvas=cake.canvas
	local font=canvas.font
	local flat=canvas.flat
	local gl=oven.gl
	local sheets=cake.sheets
	
	
	local gui=oven.rebake(oven.modgame..".gui")
	local main=oven.rebake(oven.modgame..".main")
--	local beep=oven.rebake(oven.modgame..".beep")

	local ground=oven.rebake(oven.modgame..".ground")
--	local walls=oven.rebake(oven.modgame..".walls")
	local bird=oven.rebake(oven.modgame..".bird")
	local csv=oven.rebake(oven.modgame..".csv")

	local sscores=oven.rebake("wetgenes.gamecake.spew.scores")
	local srecaps=oven.rebake("wetgenes.gamecake.spew.recaps")

local levels={}

levels.data={}

levels.data={}
levels.pick={}

levels.fill=function()
	levels.pick={}
	for n,v in pairs(levels.data) do
		table.insert(levels.pick,v)
	end
end

levels.setup=function()

	for n,v in pairs(csv.postcodes) do -- pre create levels
	
		local it={}
		
		levels.data[n]=it
		
		it.csv=v
		
		it.postcode=n
		it.walls={}
		
		local x=512
		for i,v in ipairs(it.csv) do
			local w={}
			w.x=x
			w.y=64+(v.month)*((512-128)/12)
			w.gap=64+128*(((v.cost)/1000)-1)
			
			it.walls[#it.walls+1]=w
			
			x=x+256+((v.day)*16)
		end
	
	end
	
--	print(wstr.dump(levels.data))
	
	levels.fill()
	
end


local wall={}
walls.wall=wall

wall.setup=function(args)
	local it={}
	args=args or {}
	
	it.score=1
	
	it.px=args.px or 1024
	it.py=args.py or 512/2
	it.gap=args.gap or 128
	
	setmetatable(it,{__index=wall})
	
	table.insert(walls.its,it)
	
	return it
end

wall.clean=function(it)
end

wall.update=function(it)


	it.px=it.px+ground.vx
	
	local dx=it.px-bird.px
	local dy=it.py-bird.py
	local gap=(it.gap/2)-16
	if dx>-64 and dx<(64-16) then
		if dy<-gap or dy>gap then
			bird.die()
		end
	end
	
	if dx<0 then
		if it.score then
			sscores.add(it.score)
			it.score=nil
		end
	end
	

end

wall.draw=function(it)

	sheets.get("imgs/gravedown"):draw(1,it.px,it.py-(it.gap/2),nil,128,512)
	sheets.get("imgs/graveup"):draw(1,it.px,it.py+(it.gap/2),nil,128,512)

end


walls.addlevel=function()

	local l=levels.pick[1]
	
	for i,v in ipairs(l.walls) do
		wall.setup({px=v.x,py=v.y,gap=v.gap})
	end
--[[
	local px=0
	for i=1,16 do
		px=px+math.random(128,768)
		wall.setup({px=px,py=math.random(128,512-128),gap=math.random(80,160)})
	end
]]	
end


walls.loads=function()


end
		
walls.setup=function()

print("setting up levels")
	walls.loads()
	
	levels.setup()
	
	walls.its={}
	
	walls.addlevel()

--	beep.stream("walls")

end

walls.clean=function()

end

walls.msg=function(m)

--	print(wstr.dump(m))

	
end

walls.update=function()

	for i=#walls.its,1,-1 do local it=walls.its[i]
		it:update()
	end
	
end

walls.draw=function()

	for i=#walls.its,1,-1 do local it=walls.its[i]
		it:draw()
	end
		
end

	return walls
end
