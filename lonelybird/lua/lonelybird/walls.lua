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
	local beep=oven.rebake(oven.modgame..".beep")

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
			w.y=128+(v.month)*((512-256)/12)
			w.gap=64+128*(((v.cost)/1000)-1)

			w.csv=v
			
			it.walls[#it.walls+1]=w
			
			it.max=x

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
	it.csv=args.csv -- copy in extra data
	
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
			
			beep.play("score")

		end
	end
	

end

wall.draw=function(it)

	sheets.get("imgs/gravedown"):draw(1,it.px,it.py-(it.gap/2),nil,128,512)
	sheets.get("imgs/graveup"):draw(1,it.px,it.py+(it.gap/2),nil,128,512)

	gl.Color(0,0,0,1)

	font.set(cake.fonts.get("awesome"))
	font.set_size(32,0)

	local s=it.csv.month.."/"..it.csv.day
	local w=font.width(s)
	local x=it.px-(w/2)
	local y=it.py+(it.gap/2)+26
	
	font.set_xy(x,y)
	font.draw(s)

	local s=tostring(it.csv.year)
	local w=font.width(s)
	local x=it.px-(w/2)
	local y=it.py-(it.gap/2)-26-54
	
	font.set_xy(x,y)
	font.draw(s)

	gl.Color(1,1,1,1)

end


local signs={
"LS3","LS4","LS5","LS6","LS7","LS8","LS9","LS10",
"LS11","LS12","LS13","LS14","LS16","LS18","LS19","LS20",
"LS22","LS25","LS26","LS27","LS28","WF10"
}

walls.addlevel=function()

	walls.its={}

	local r=math.random(#levels.pick)

	local l=levels.pick[r]
	
	local xx=512
	

	walls.px=l.max

	walls.sign={}
	walls.sign.px=xx+64
	walls.sign.py=16
	walls.sign.postcode=l.postcode
	walls.sign.idx=nil
	
	for i,v in ipairs(signs) do
		if v==l.postcode then walls.sign.idx=i end
	end
	
	

	
	for i,v in ipairs(l.walls) do
		wall.setup({px=xx+v.x,py=v.y,gap=v.gap,csv=v.csv})
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

	walls.sign.px=walls.sign.px+ground.vx
	walls.px=walls.px+ground.vx

	for i=#walls.its,1,-1 do local it=walls.its[i]
		it:update()
	end


	if walls.px<-512 then
		walls.addlevel()
	end
	
end

walls.draw=function()

	if walls.sign.idx then
		sheets.get("imgs/postcode"):draw(walls.sign.idx,walls.sign.px,walls.sign.py,nil,2000/8,405/3)
	end
	
	for i=#walls.its,1,-1 do local it=walls.its[i]
		it:draw()
	end
		
end

	return walls
end
