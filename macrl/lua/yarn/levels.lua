-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local wstr=require("wetgenes.string")

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(basket,levels)
	levels=levels or {}
	levels.modname=M.modname

-- a collection of everything

	local yarn_map  =basket.rebake("yarn.map")
	local yarn_rooms=basket.rebake("yarn.rooms")
	local yarn_cells=basket.rebake("yarn.cells")
	local yarn_items=basket.rebake("yarn.items")
	local yarn_attrs=basket.rebake("yarn.attrs")


	levels.get=function(name,pow,xtra)
		return levels.create(yarn_attrs.get(name,pow,xtra))
	end

	function levels.create(t)

		local level={}

		level.is=yarn_attrs.create(t)
		
--		level.metatable={__index=level.is}
--		setmetatable(level,level.metatable)

--		level.level=level -- we are the level, so level.level==level
--		level.main=up
--		level.menu=up.menu
--		level.soul=up.soul

--		level.time_passed=0
--		level.time_update=0
		
		level.xh=t.xh or 40
		level.yh=t.yh or 30-2

		level.rooms={}
		level.items={}
		level.flags={}
			
		level.cells={}
		level.cellfind={}
		level.celllist={}
		
		level.can=can or {}

	-- create default blank cells
		for y=0,level.yh-1 do
			for x=0,level.xh-1 do
				local i=x+y*level.xh
				level.cells[i]=yarn_cells.create(yarn_attrs.get("cell",0,{ xp=x, yp=y, id=i }))
			end
		end


	--	function draw_map(m) map.draw_map(m) end
		function level.get_asc(x,y)
			local cell=level.get_cell(x,y)
			return (cell and cell.asc())
		end

	-- use to find a unique named item in this level
		function level.find_item(name)
			for v,b in pairs(level.items) do
				if v.name==name then
					return v
				end
			end
		end


	-- use all items of a given name
		function level.find_items(name)
			local ret={}
			for v,b in pairs(level.items) do
				if v.name==name then
					ret[#ret+1]=v
				end
			end
			return ret
		end
		
		function level.get_cell(x,y)
			if x<0 then return nil end
			if x>=level.xh then return nil end
			if y<0 then return nil end
			if y>=level.yh then return nil end
			return level.cells[ x+y*level.xh ]
		end

	-- iterate an area of cells	
		function level.cpairs(x,y,w,h)
			return function(a,i)
				local px=i%w
				local py=(i-px)/w
				if py>=h then return end
				return i+1,level.get_cell(x+px,y+py)
			end, level.cells, 0
		end
		
		function level.new_item(n,l)
			local at
			if type(n)=="string" then
				at=yarn_attrs.get(n,l)
			else
				at=n
				n=at.name
			end
			local item=yarn_items.create( at ,level)
			level.items[item]=true -- everything lives in items list
			
			for i,v in pairs(item.is.can) do -- every item puts its can functions in the levels can table
				level.is.can[i]=v
			end
			-- this means we can easily add uniquely named can functions to a level using any item

			return item
		end
		function level.del_item(item)
			level.items[item]=nil
			item.del()
		end
		
		function level.rand(a,b)
			if a>=b then return a end
			return math.random(a,b)
		end

	-- get a random room	
		function level.rand_room()
			local n=0
			for i,v in ipairs(level.rooms) do if v.xh>1 and v.yh>1 then n=n+1 end end -- count rooms
			n=level.rand(1,n)
			for i,v in ipairs(level.rooms) do
				if v.xh>1 and v.yh>1 then
					n=n-1
					if n<1 then return v end -- found it
				end
			end
		end
		
	-- get a random cell in the given range
		function level.rand_cell(room)
			local x=level.rand(room.xp,room.xp+room.xh-1)
			local y=level.rand(room.yp,room.yp+room.yh-1)
			return level.get_cell(x,y)
		end

	-- get a random cell in a random room

		function level.rand_room_cell()
			return level.rand_cell(level.rand_room())
		end

	-- get a random empty cell in the given range
		function level.rand_empty(room)
			if not room then room={xp=0,yp=0,xh=level.xh,yh=level.yh} end
			local t={}
			for x=room.xp,room.xp+room.xh-1 do
				for y=room.yp,room.yp+room.yh-1 do
					local c=level.get_cell(x,y)
					if c and c.is.name=="floor" then
						local cn=0
						for i,v in pairs(c.items) do
							cn=cn+1
							break
						end
						if cn==0 then -- its a floor with nothing there so add it
							t[#t+1]=c
						end
					end
				end
			end
			local i=level.rand(1,#t) -- pick one
			return t[i] -- and return it
		end

		function level.destroy()
		end

	-- create a save state for this data
		function level.save()
			local sd={}
			
			local p=basket.player
			p.un_cell() -- remove from map as player will be saved seperately
			
			sd=yarn_attr.save(level.is)
			
	--		sd.player=p.save()
			sd.rooms={}
			sd.cells={}
			
			for i,v in ipairs(level.cells) do -- cells contain all items so they get saved here
				sd.cells[i]=v.save()
				if sd.cells[i].is.name=="wall" then
					if not sd.cells[i].visible then
						if not sd.cells[i].items then
							sd.cells[i]=nil				-- do not need to save cell as it is in default state
						end
					end
				end
			end
			
			for i,v in ipairs(level.rooms) do -- rooms are just areas of cells
				sd.rooms[i]=v.save()
			end
			
			p.re_cell() -- put playerback in map
			return sd
		end

	-- reload a saved data (create and then load)
		function level.load(sd)

			for i,v in pairs(sd.rooms) do -- create rooms
				level.rooms[i]=yarn_room.create(yarn_attrs.get("room",0,{ xp=v.xp, yp=v.yp, xh=v.xh, yh=v.yh, } ))
				level.rooms[i].load(v)
			end

			for i,v in pairs(level.cells) do -- modify cells from default state here, placing items and so on
				if sd.cells[i] then v.load(sd.cells[i]) end
			end
			
			level.is=yarn_attr.load(sd)
			level.metatable.__index=level.is

	--auto gen
			for i,v in ipairs(level.rooms) do v.find_doors() end
			
		end
		
-- setup stuff below

		function level.clean()
		end
		
		function level.setup(opts)
		
		print("creating new level for -> ",level.is.name," : ",level.is.pow)	


		-- set opts using rooms,this is where most of the brainwork happens	
			level.opts=basket.call.get_map(level.is.name,level.is.pow)
			level.flags=level.opts.flags -- these are importatn level state and should be saved
			level.opts.xh=level.xh
			level.opts.yh=level.yh
			level.build=yarn_map.build(level.opts) -- create an empty map, this is only a room layout
			
		-- now turn that generated map into real rooms we can put stuff in
			for i,v in ipairs(level.build.rooms) do
				level.rooms[i]=yarn_rooms.create(yarn_attrs.get("room",0,
					{ xp=v.x, yp=v.y, xh=v.xh, yh=v.yh, }) )
				level.rooms[i].opts=v.opts
			end

			for i,v in ipairs(level.rooms) do
				v.post_create()
			end

		-- find link door locations	
			for i,v in ipairs(level.rooms) do v.find_doors() end
		
--print(wstr.dump(level.rooms))
		-- fill in cells
			for i,r in ipairs(level.rooms) do
				if r.opts then -- special?
					local cs=r.opts.cells
					for y=1,#cs do
						local v=cs[y]
						for x=1,#v do
							local n=v[x]
							
--							if n=="floor" then -- do nothing
--								local c=level.get_cell(r.xp+x-1,r.yp+y-1)
--								c.is.set.name("floor")
--							else
								local c=level.get_cell(r.xp+x-1,r.yp+y-1)
								if level.opts.callback then
									level.opts.callback({call="cell",cell=c,name=n,room=r})
								end
--							end
						end
					end
					if level.opts.callback then
						level.opts.callback({call="room",room=r})
					end
				end
			end
			

			if level.opts.bigroom then

				for y=0,level.yh-1 do
					for x=0,level.xh-1 do
						local i=x+y*level.xh
						local cell=level.cells[i]
						if level.build.room_find(x,y)==level.build.bigroom then
							cell.is.set.name("floor")
							cell.is.set.visible(true)
							if level.opts.callback then
								level.opts.callback({call="cell",cell=cell,name="floor",room=level.build.bigroom})
							end
						end
						if y==0 or y==level.yh-1 or x==0 or x==level.xh-1 then
							cell.is.set.visible(true)
						end
					end
				end
				for i,r in ipairs(level.rooms) do
					if r.xh>1 and r.yh>1 then -- not corridors
						for x=r.xp-1,r.xp+r.xh do
							for y=r.yp-1,r.yp+r.yh do
								if x==r.xp-1 or x==r.xp+r.xh or y==r.yp-1 or y==r.yp+r.yh then
									local cell=level.get_cell(x,y)
									cell.is.set.visible(true)
								end
							end
						end
					end
				end
			end

			if level.opts.callback then
				level.opts.callback({call="level",name=level.is.name})
			end

			return level
		end

		return level
		
	end


	levels.key_repeat=nil
	levels.key_repeat_count=0
	
	function levels.key_clear()
		levels.key_repeat=nil
	end
	
	function levels.key_check()
		levels.key_repeat_count=levels.key_repeat_count+1
		if levels.key_repeat_count>=10 then
			levels.key_do(levels.key_repeat)
		end
	end
	
	function levels.key_do(key)
	
		if key=="space" or key=="enter"  or key=="return"  or key=="kpenter" or key==" " then
		
			basket.menu.show_player_menu(basket.player)
			
		end
		
		levels.key_repeat_count=0 -- always zero the repeat counter
	
		local vx=0
		local vy=0
		
		if key=="up" then
			vx=0
			vy=-1
		elseif key=="down" then
			vx=0
			vy=1
		elseif key=="left" then
			vx=-1
			vy=0
		elseif key=="right" then
			vx=1
			vy=0
		end
		
		if vx~=0 or vy~=0 then
			basket.player.move(vx,vy)
			return true
		end
	end
	
--	function levels.step(t,item)
--		if item then t=t end -- advance level time relative to actor..
--		basket.level.time_update=basket.level.time_update+t
--	end
	
	function levels.msg(m)
		if not m then
			levels.key_repeat=nil
			return
		end
		if m.class=="key" then
			if m.action==1 or m.action==0 then -- down or repeat
			
				levels.key_repeat=m.keyname
				levels.key_repeat_count=0
				
				levels.key_do(levels.key_repeat)
				
			elseif m.action==-1 then -- any up key cancels all repeats			
				levels.key_repeat=nil
			end
		end
	end
		
	function levels.update()
		levels.key_check()
				
		for v,b in pairs(basket.level.items) do
			v.update()
		end
		
	end


	return levels
end

