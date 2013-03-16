-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(basket,cells)
	cells=cells or {}
	cells.modname=M.modname

	-- a single location

	local yarn_attrs=basket.rebake("yarn.attrs")
	local yarn_items=basket.rebake("yarn.items")
	local yarn_ascii=basket.rebake("yarn.ascii")

	function cells.create(t,_level)

		local cell={}

		cell.is=yarn_attrs.create(t)

		cell.xp=t.xp or 0 -- we do not store the possiton in attrs
		cell.yp=t.yp or 0 -- as it is implied by array position.
		cell.id=t.id or 0
			
		cell.items={}
		
		cell.is.set.name("wall")
		cell.is.set.visible(false)
--		cell.is.set.visible(true)
		
		function cell.neighbours()
			local n_x_look={  0 , -1 , 1 , 0 }
			local n_y_look={ -1 ,  0 , 0 , 1 }
			return function(d,i)
				if i>4 then return nil,nil end -- no more edges
				return i+1 , basket.level.get_cell( cell.xp+n_x_look[i] , cell.yp+n_y_look[i] )
			end , d , 1
		end
		
		function cell.neighboursplus()
			local n_x_look={ 0,  0 , -1 , 1 , 0 }
			local n_y_look={ 0, -1 ,  0 , 0 , 1 }
			return function(d,i)
				if i>5 then return nil,nil end -- no more edges
				return i+1 , basket.level.get_cell( cell.xp+n_x_look[i] , cell.yp+n_y_look[i] )
			end , d , 1
		end

		function cell.borders()
			local n_x_look={ -1 ,  0 ,  1 , -1 , 1 , -1 , 0 , 1 }
			local n_y_look={ -1 , -1 , -1 ,  0 , 0 ,  1 , 1 , 1 }
			return function(d,i)
				if i>8 then return nil,nil end -- no more edges
				return i+1 , basket.level.get_cell( cell.xp+n_x_look[i] , cell.yp+n_y_look[i] )
			end , d , 1
		end
		
		function cell.bordersplus()
			local n_x_look={ 0, -1 ,  0 ,  1 , -1 , 1 , -1 , 0 , 1 }
			local n_y_look={ 0, -1 , -1 , -1 ,  0 , 0 ,  1 , 1 , 1 }
			return function(d,i)
				if i>9 then return nil,nil end -- no more edges
				return i+1 , basket.level.get_cell( cell.xp+n_x_look[i] , cell.yp+n_y_look[i] )
			end , d , 1
		end

		function cell.get_item() -- find any not big item
		for v,b in pairs(cell.items) do
				if not v.is.big then return v end
			end
		end
		
		function cell.get_char() -- there should only be one big item per cell
			for v,b in pairs(cell.items) do
				if v.is.big then return v end
			end
		end
		
		function cell.is_empty()
			if it.is.name=="floor" and not cell.get_char() then return true end
			return false
		end
		
		function cell.asc()
			if not cell.is.get.visible() then return yarn_ascii.space end
			
			local char=cell.get_char()
			local item=cell.get_item()
			
			if char then
				return char.asc()
			end
			
			if item then
				return item.asc()
			end
			
			if cell.is.name=="wall" then -- some cells are just walls
				return yarn_ascii.hash
			else
				return yarn_ascii.dot
			end
				
			return yarn_ascii.hash
		end

		local function img_dark(t)
			t.img="dark"
			t.asc=yarn_ascii.space
			return t
		end
		local function img_floor(t)
			t.img="floor"
			t.asc=yarn_ascii.dot
			return t
		end
		local function img_wall(t)
			t.img="wall"
			t.asc=yarn_ascii.hash
			return t
		end

		function cell.img(t)
			t=t or {}

			if not cell.is.get.visible() then
				return img_dark(t)
			end
			
			local char=cell.get_char()
			local item=cell.get_item()
			
			if char then
				return char.img(t)
			end
			
			if item then
				return item.img(t)
			end
			
			if cell.is.name=="wall" then -- some cells are just walls
				return img_wall(t)
			else
				return img_floor(t)
			end
				
			return img_dark(t)
		end

	-- create a save state for this data
		function cell.save()
			local sd={}
			sd=yarn_attrs.save(cell.is)
			
			sd.xp=nil
			sd.yp=nil
			sd.id=nil
			
			for v,b in pairs(cell.items) do
				sd.items=sd.items or {}
				sd.items[#sd.items+1]=v.save()
			end
			
			return sd
		end

	-- reload a saved data (create and then load)
		function cell.load(sd)

			cell.is=yarn_attrs.load(sd)

			if sd.items then
				for i,v in pairs(sd.items) do
					local item=yarn_items.create({level=level})
					cell.level.items[item]=true
					cell.items[item]=true
					item.set_cell(cell)
					item.load(v)
				end
			end
			
		end
		
		return cell
	end

	return cells
end

