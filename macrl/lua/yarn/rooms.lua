-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local wstring=require("wetgenes.string")

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(basket,rooms)
	rooms=rooms or {}
	rooms.modname=M.modname
	
-- a local area of cells

	local yarn_attrs=basket.rebake("yarn.attrs")


	function rooms.create(t)

		local room={}

		room.is=yarn_attrs.create(t)
--		metatable={__index=room.is}
--		setmetatable(room,metatable)

		room.xp=t.xp or 0
		room.yp=t.yp or 0
		room.xh=t.xh or 0
		room.yh=t.yh or 0
		room.doors={} -- a cell->room table of links to bordering rooms
		
	-- point to this room from the cells we cover, only one room pointer per cell

		for y=room.yp,room.yp+room.yh-1 do
			for x=room.xp,room.xp+room.xh-1 do
				local cell=basket.level.get_cell(x,y)
				cell.room=room
			end
		end
		
	 -- call this after adding all the rooms to the level to find all the doors
	 -- and mark each room as linked to its neighbours

		function room.find_doors()
		
			for y=room.yp,room.yp+room.yh-1 do
				for x=room.xp,room.xp+room.xh-1 do
				
					local cell=basket.level.get_cell(x,y)
					
					for i,v in cell.neighbours() do
					
						if v.room and cell.room and v.room~=cell.room then -- connected to a different room?
						
							room.doors[cell]=v.room
							cell.door=v.room

						end
					end
				
				end
			end
		end


	-- set this room and every cell in and around this room to visible 
	-- return number of cells that where revealed, this can then be used to heal
		function room.set_visible(v)
		local n=0
			for _,cell in basket.level.cpairs(room.xp-1,room.yp-1,room.xh+2,room.yh+2) do
				if not cell.is.get.visible() then
					n=n+1
					cell.is.set.visible(v)
				end
			end
			room.is.set.visible(v)
			return n
		end

		
		function room.post_create()
			for _,cell in basket.level.cpairs(room.xp,room.yp,room.xh,room.yh) do
--print(wstring.dump(room))
--print(cell)
				cell.is.set.name("floor")
			end
		end

	-- create a save state for this data
		function room.save()
			local sd={}
			
			sd=yarn_attrs.save(room.is)
			
			sd.xp=xp
			sd.yp=yp
			sd.xh=xh
			sd.yh=yh

			
			return sd
		end

	-- reload a saved data (create and then load)
		function load(sd)
			room.is=yarn_attrs.load(sd)
--			room.metatable.__index=room.is

			room.xp=sd.xp
			room.yp=sd.yp
			room.xh=sd.xh
			room.yh=sd.yh

		end
		
		return room
	end

	return rooms
end
