-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local wstring=require("wetgenes.string")


--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(basket,map)
	map=map or {}
	map.modname=M.modname
	
	local yarn_ascii=basket.rebake("yarn.ascii")

-- build your own dungeon
--
-- a little bit hacky but hey, i didnt knw how i was going to do it when i started :)

	function map.build(opts)
		
		local build={}

		build.opts=opts

		local asc={}
		local asc_xh=0
		local asc_yh=0	


		if opts.mode=="town" then

			opts.bigroom=true

		end



		function build.rand_weight_change()

			local asc
			build.rx={}
			build.ry={}
			
			build.ry[-1]=0
			for y=0,asc_yh-1 do
				build.ry[y]=0
				for x=0,asc_xh-1 do
					asc=build.get_asc(x,y)
					if asc~=yarn_ascii.dot then
						build.ry[y]=build.ry[y]+1
						build.ry[-1]=build.ry[-1]+1
					end
				end
			end
			
			build.rx[-1]=0
			for x=0,asc_xh-1 do
				build.rx[x]=0
				for y=0,asc_yh-1 do
					asc=build.get_asc(x,y)
					if asc~=yarn_ascii.dot then
						build.rx[x]=build.rx[x]+1
						build.rx[-1]=build.rx[-1]+1
					end
				end
			end
		end

		function build.rand_weight_xy()

			local r
			
			r=build.rand(0,build.rx[-1]-1)
			for i=0,asc_xh-1 do
				r=r-build.rx[i]
				if r<=0 then
					build.x=i
					break
				end
			end

			r=build.rand(0,build.rx[-1]-1)
			for i=0,asc_yh-1 do
				r=r-build.ry[i]
				if r<=0 then
					build.y=i
					break
				end
			end
			
		end

		function build.rand_xy_door(room)
			local r=build.rand(1,4) -- pick a wall
			
			if r==1 then 
				build.x=room.x-1
				build.y=build.rand(room.y+1,room.y+room.yh-2)
				build.vx=-1
				build.vy=0
			elseif r==2 then 
				build.x=room.x+room.xh
				build.y=build.rand(room.y+1,room.y+room.yh-2)
				build.vx=1
				build.vy=0
			elseif r==3 then 
				build.x=build.rand(room.x+1,room.x+room.xh-2)
				build.y=room.y-1
				build.vx=0
				build.vy=-1
			elseif r==4 then 
				build.x=build.rand(room.x+1,room.x+room.xh-2)
				build.y=room.y+room.yh
				build.vx=0
				build.vy=1
			end
			return r
		end

		function build.rand(a,b)
			if a>=b then return a end
			return math.random(a,b)
		end
		function build.rand_xy()
			build.x=build.rand(0,asc_xh-1)
			build.y=build.rand(0,asc_yh-1)
		end

		function build.get_asc(x,y)
			if x<0 then return nil end
			if y<0 then return nil end
			if x>=asc_xh then return nil end
			if y>=asc_yh then return nil end
			return asc[1+x+y*asc_xh]
		end

		function build.set_asc(x,y,a)
			if x<0 then return nil end
			if y<0 then return nil end
			if x>=asc_xh then return nil end
			if y>=asc_yh then return nil end
			asc[1+x+y*asc_xh]=a
			return true
		end

		function build.room_rand()
			build.rand_weight_xy()
			build.xh=build.rand(1,4)
			build.yh=build.rand(1,4)
			build.x=build.x-build.xh
			build.y=build.y-build.yh
			build.xh=build.xh+build.rand(2,5)
			build.yh=build.yh+build.rand(2,5)
		--	if build.xh==2 and build.yh==2 then build.xh=3 end -- do not allow 2x2 rooms

			if opts.rooms and #build.rooms < #opts.rooms then
				local r=opts.rooms[ #build.rooms+1 ]
				build.xh=r.xh
				build.yh=r.yh
				build.r=r
			else
				if opts.only_these_rooms then
					return
				end
			end
			
			if build.room_check() then build.room_dig() end
		end
		function build.room_check()
			if opts.bigroom then -- bigroom rooms need more space
				for y=build.y-1-2,build.y+build.yh+2 do
					for x=build.x-1-2,build.x+build.xh+2 do
						local a=build.get_asc(x,y)
						if (not a) or (a==yarn_ascii.dot) then return false end
					end
				end
			else
				for y=build.y-1,build.y+build.yh do
					for x=build.x-1,build.x+build.xh do
						local a=build.get_asc(x,y)
						if (not a) or (a==yarn_ascii.dot) then return false end
					end
				end
			end
			return true
		end
		function build.room_dig()
			for y=build.y,build.y+build.yh-1 do
				for x=build.x,build.x+build.xh-1 do
					build.set_asc(x,y,yarn_ascii.dot)
				end
			end
			build.rand_weight_change()
			local r={}
			r.x=build.x
			r.y=build.y
			r.xh=build.xh
			r.yh=build.yh
			r.doors={}
			table.insert(build.rooms,r)
			table.insert(build.rooms_groups,{r})
			if build.r then r.opts=build.r build.r=nil end -- map room opts 
			return r
		end

		function build.bigroom_dig()
			local r={}
			r.x=1
			r.y=1
			r.xh=asc_xh-2
			r.yh=asc_yh-2
			r.doors={}
			table.insert(build.rooms_groups,{r})
			if build.r then r.opts=build.r build.r=nil end -- map room opts 
			return r
		end

		function build.room_remove(r)

			for y=r.y,r.y+r.yh-1 do
				for x=r.x,r.x+r.xh-1 do
					build.set_asc(x,y,yarn_ascii.dash)
				end
			end
			
			build.rand_weight_change()
			
			for i,v in ipairs(build.rooms) do
				if v==r then
					table.remove(build.rooms,i)
				end
			end
			
			for i,rg in ipairs(build.rooms_groups) do
				for i,v in ipairs(rg) do
					if v==r then
						table.remove(rg,i)
					end
				end
			end
		end


		-- try and connect all the rooms

		function build.room_find(x,y)

			for i,v in ipairs(build.rooms) do
				if v.x<=x and v.x+v.xh>x and v.y<=y and v.y+v.yh>y then -- hit
					return v
				end
			end
			
			if opts.bigroom then -- hit a wall, or we hit the bigroom
			
				if x==0 or x==asc_xh-1 or y==0 or y==asc_yh-1 then -- map border
					return nil
				end

				for i,v in ipairs(build.rooms) do
					if v.xh>1 or v.yh>1 then -- ignore alleys
						if v.x-1<=x and v.x+v.xh+1>x and v.y-1<=y and v.y+v.yh+1>y then -- hit room border
							return nil
						end
					end
				end
				
		-- finally we hit the bigroom by default

				return build.bigroom
				
			end
			
			return nil
		end

		function build.alleys_merge_find(r1,r2)

		local g1,g2

			for g,v in ipairs(build.rooms_groups) do
				for r,v in ipairs(v) do
					if v==r1 then g1=g end
					if v==r2 then g2=g end
				end
			end
			
			return g1,g2
		end

		function build.alleys_merge(r1,r2)

		local g1,g2=build.alleys_merge_find(r1,r2)

		--print(g1.." - "..g2)
			if g1~=g2 then
				for i,v in ipairs(build.rooms_groups[g2]) do -- merge groups
					table.insert(build.rooms_groups[g1],v)
				end
				table.remove(build.rooms_groups,g2) -- destroy old groups
			end
		end

		function build.alleys_rand()

			for i=1000,1,-1 do -- check quite a lot
			
		--print(i..":"..#build.rooms_groups)
			
				if #build.rooms_groups<=1 then break end -- all connected, we will probably drop out here 
					
				local r2=nil
				local g=build.rooms_groups[ 1+(i % #build.rooms_groups) ] -- simple group weighting
				local r=g[ build.rand(1,#g) ]
				local door=build.rand_xy_door(r)
				local door_hit=0
			
		--		if not r.doors[door] then -- only one room per room side
				
				local fail=true
				--	print("start "..build.x.." , "..build.y)
				if build.get_asc(build.x,build.y)==yarn_ascii.hash then -- can start digging
					if build.vx~=0 then
						local y=build.y
						for x=build.x,build.x+build.vx*1000 do
							local a=build.get_asc(x,y)
							if a==nil then break end -- hit edge
							if a==yarn_ascii.dot then -- found another alley/room
								r2=build.room_find(x,y)
								build.xh=x-build.x
								build.yh=1
								fail=false
								break
							end
							if build.get_asc(x,y-1)==yarn_ascii.dot then
								r2=build.room_find(x,y-1)
								break
							elseif build.get_asc(x,y+1)==yarn_ascii.dot then
								r2=build.room_find(x,y+1)
								break
							end
	--[[
							if r2 then
								build.xh=x-build.x+1
								build.yh=1
								fail=false
								break
							end
	]]
						end
					elseif build.vy~=0 then
						local x=build.x
						for y=build.y,build.y+build.vy*1000 do
							local a=build.get_asc(x,y)
							if a==nil then break end -- hit edge
							if a==yarn_ascii.dot then -- found another alley/room
								r2=build.room_find(x,y)
								build.yh=y-build.y
								build.xh=1
								fail=false
								break
							end
							if build.get_asc(x-1,y)==yarn_ascii.dot then
								r2=build.room_find(x-1,y)
								break
							elseif build.get_asc(x+1,y)==yarn_ascii.dot then
								r2=build.room_find(x+1,y)
								break
							end
	--[[
							if r2 then
								build.yh=y-build.y+1
								build.xh=1
								fail=false
								break
							end
	]]
						end
					end
				end
				
				if not fail and r2 and r2.max_doors then
					if #r2.doors >= r2.max_doors then -- too many doors
						fail=true
						r2=nil
					end
				end

				if not fail then
				
				
					local g1,g2=build.alleys_merge_find(r,r2)
					
					local c1,c2
					
		if build.x==r.x or build.x==r.x+r.xh-1 or build.y==r.y or build.y==r.y+r.yh-1 then c1=true end
		if build.x+build.xh-1==r2.x or build.x+build.xh-1==r2.x+r2.xh-1 or build.y+build.yh-1==r2.y or build.y+build.yh-1==r2.y+r2.yh-1 then c2=true end
					
					if g1~=g2 and not c1 and not c2 then -- only if it connects two groups

						local alley=build.room_dig()
						table.insert(r.doors,alley)
						table.insert(alley.doors,r)
						table.insert(r2.doors,alley)
						table.insert(alley.doors,r2)
						
						build.alleys_merge(r,alley)
						build.alleys_merge(r,r2)
						
					end
					
				end
				
		--		end
			end
			
		end

		-- remove all rooms that are not in the biggest connection group
		function build.rooms_prune()

			if #build.rooms_groups<=1 then return end
			
			local mx=build.rooms_groups[1]
			
			for i,v in ipairs(build.rooms_groups) do
			
				if #v > #mx then mx=v end -- biggest
				
			end

			for i,v in ipairs(build.rooms_groups) do
			
				if v==mx then
					-- main group
				else
					for i,v in ipairs(v) do
						build.room_remove(v)
					end
				end
			end
			
			build.rooms_groups={mx} -- only one group remains
			
		end


	-- fill level with solid
		asc_xh=opts.xh or 40
		asc_yh=opts.yh or 30-2
		
		local i=0
		for y=0,asc_yh-1 do
			for x=0,asc_xh-1 do
			
				i=1+x+y*asc_xh
				asc[i]=yarn_ascii.hash

			end
		end
		
--		math.randomseed(os.time())
		
		build.rooms={}
		build.rooms_groups={} -- every room starts in its own group, then we try and join them all into one

		if opts.bigroom then
			build.bigroom=build.bigroom_dig()
		end
		
		build.rand_weight_change()
		for i=1,100 do
			build.room_rand()
		end
		
		if opts.bigroom then
			for y=0,asc_yh do
				for x=0,asc_xh do
					if build.room_find(x,y)==build.bigroom then -- add the main big room
						build.set_asc(x,y,yarn_ascii.dot)
					end
				end
			end
		end
		
		build.alleys_rand()
		
		build.rooms_prune()
		
		
	-- check we got all the special rooms
		local gotroom={}
		for i,v in ipairs(build.rooms) do
--print(wstring.dump(v))
			if v.opts then
				gotroom[v.opts]=true
			end
		end
		if opts.rooms then
			for i,v in ipairs(opts.rooms) do
				if not gotroom[v] then
					return map.build(opts) -- try again
				end
			end
		end
		
		return build
		
	end

	return map
end
