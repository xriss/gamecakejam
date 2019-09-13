-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math


--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,items)
	items=items or {}
	items.modname=M.modname

	local gl=oven.gl
	local cake=oven.cake
	local opts=oven.opts
	local canvas=cake.canvas
	local font=canvas.font
	local flat=canvas.flat
	local sheets=cake.sheets

	local bikes=oven.rebake(oven.modgame..".bikes")
	local beep=oven.rebake(oven.modgame..".beep")
	
items.loads=function()

end
		
items.setup=function()

	items.loads()
	
	items.list={}
	
	items.vx=-1
	items.vy=0
end


items.clean=function()

	items.list=nil
end

items.msg=function(m)

end


items.update=function()
	
	for i=#items.list,1,-1 do local v=items.list[i]
		v:update()
		if v.remove_from_list then -- set this flag to remove from list
			table.remove(items.list,i) -- safe to do as we iterate backwards
		end
	end
	
-- easy just to sort the items to fix the draw order
	table.sort(items.list,function(a,b)
		return a.py > b.py
	end)
	
end

items.draw=function()
	
	gl.PushMatrix()
	gl.Translate(bikes.px,bikes.py,0)
		
	for i=#items.list,1,-1 do local v=items.list[i]
		v:draw()
	end
	
	gl.PopMatrix()

end
	
items.insert=function(item,opts)
	item=item or items.create(nil,opts)
	items.remove(item)
	table.insert(items.list,item)
	return item
end

items.remove=function(item)
	for i=#items.list,1,-1 do local v=items.list[i]
		if item==v then
			table.remove(items.list,i)
		end
	end
end


items.create=function(item,opts)

	item=item or {}

	item.setup=function(item,opts)
		opts=opts or {}
		item.px=opts.px or 512+256
		item.py=opts.py or (((math.random(32768)%4)*90)-180)
		
		item.vx=opts.vx or -1
		item.vy=opts.vy or 0

		item.draw_index=opts.draw_index or ((math.random(32768)%2)+1)
		item.draw_size=opts.draw_size or 64

		return item
	end

	item.clean=function(item)
	end

	item.update=function(item)
		item.px=item.px+item.vx
		item.py=item.py+item.vy
		
		if item.px < -(512+256) then
			item.remove_from_list=true
		end
		
		for i,bike in ipairs(bikes.list) do
			local dx=bike.px-item.px
			local dy=(bike.py-90)-item.py
			local dd=dx*dx+dy*dy
			if dd<90*90 then
				beep.play(bike.sfx1)
				if item.draw_index==1 then
					bike.score=bike.score+1
				else
					bike.score=bike.score-2
				end
				if bike.score<0 then bike.score=0 end -- no negative scores
				item.remove_from_list=true
				break
			end
		end

	end

	item.draw=function(item)

		local ss=sheets.get("imgs/items")
		
--		gl.PushMatrix()

		local v=item
		ss:draw(v.draw_index,v.px,v.py,v.rz,v.draw_size,v.draw_size)
	
--		gl.PopMatrix()
	end
	
	return item:setup(opts)
end


	return items
end

