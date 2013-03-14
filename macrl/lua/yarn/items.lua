-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(basket,items)
	items=items or {}
	items.modname=M.modname

-- a single item


	local yarn_attrs=basket.rebake("yarn.attrs")
	local yarn_fight=basket.rebake("yarn.fight")
	local yarn_levels=basket.rebake("yarn.levels")


	items.get=function(name,pow,xtra)
		return items.create(yarn_attrs.get(name,pow,xtra))
	end
	
	function items.create(t)

		
		local item={}

		item.is=yarn_attrs.create(t) -- allow attr access via item.is.wood syntax
--		item.metatable={__index=item.is} -- or without the is if we do not fear nameclash
--		setmetatable(item,item.metatable)

		item.class=t.class
		
		item.time_passed=basket.level.time_passed
		
		function item.del()
			if item.cell then -- remove link from old cell
				item.cell.items[item]=nil
			end
		end

	-- remove from cell but remember which cell
		function item.un_cell()
			local c=item.cell
			if c then -- remove link from old cell but remember where it was in item attrs
				item.is.cell_xp=c.xp
				item.is.cell_yp=c.yp
				c.items[item]=nil
			end
			item.cell=nil
			return c
		end
	--put back in the cell it wasremoved from
		function item.re_cell()
			local c=basket.level.get_cell(item.is.cell_xp,item.is.cell_yp)
			item.is.cell_xp=nil
			item.is.cell_yp=nil
			item.set_cell(c)
			return c
		end
		


		function item.set_cell(c)
		
			if item.cell then -- remove link from old cell
				item.cell.items[item]=nil
			end
			
			item.cell=c
			if not item.cell.items then item.cell.items={} end -- make space in non cells
			item.cell.items[item]=true
			
			if item==basket.player then
				local it=c.get_item() -- see something on the floor?
				if it==item then it=nil end --not us
				if it then
					basket.set_msg( it.view_text() )
				else
					basket.set_msg( "" )
				end
			end
			
			if item.is.can.make_room_visible then -- this item makes the room visible (ie its the player)
				if item.cell.room then
					for i,v in item.cell.neighboursplus() do -- apply to neighbours and self
						if v.room and ( not v.room.is.get.visible() ) then -- if room is not visible
--print("setting room visible")
							local n=v.room.set_visible(true)
							if item.is.can.explore_heal then
								if n>0 then
									yarn_fight.heal(item,n) -- restore when we explore
								end
							end
						end
					end
				end
			end
			
		end
		
		function item.asc()
			local a=item.is.asc
			if type(a)=="function" then -- smart ascii
				return t(item)
			else
				return a
			end
		end

		function item.img(t)
			t=t or {}
			local img=item.is.img
			if type(img)=="function" then
				img(item,t) -- expect to always set t.asc and t.img
			else
				t.img=img -- may be nil
				t.asc=item.asc()
				return t
			end
		end
		
		function item.view_text()
			return "You see "..(item.is.desc or "something").."."
		end

		function item.look_text()
			local ss={}
			ss[#ss+1]=item.is.longdesc or item.is.desc
			ss[#ss+1]="\n"
			
			if item.is.pow>0 then
				ss[#ss+1]="+"..(item.is.pow).."\n"
			elseif item.is.pow<0 then
				ss[#ss+1]="-"..(-item.is.pow).."\n"
			end
			
			if (item.dam_min and item.dam_min~=0) or (item.dam_max and item.dam_max~=0) then
				ss[#ss+1]="\n"
				ss[#ss+1]="damage "..math.floor(item.dam_min).." to "..math.floor(item.dam_max).."\n"
			end

			if (item.def_add and item.def_add~=0) or (item.def_mul and item.def_mul~=1) then
				ss[#ss+1]="\n"
				ss[#ss+1]="protection "..math.floor(-item.def_add).." and "..math.floor(100*(1-item.def_mul)).."% damage\n"
			end	
		
			return table.concat(ss)
		end

		function item.desc_text()
			local s=item.is.desc
			if item.is.pow>0 then
				s=s.."+"..item.is.pow
			elseif item.is.pow<0 then
				s=s.."-"..(-item.is.pow)
			end
			return s
		end

		function item.move(vx,vy)
			local x=item.cell.xp+vx
			local y=item.cell.yp+vy
			local c=basket.level.get_cell(x,y)
			
			if c and c.is.name=="floor" then -- its a cell we can move into
			
				local char=c.get_char()

				if char then -- interact with another char?
					if char.is.can.use and item.is.can.operate then

						local usename=char.is.can.use
						
						if char.is.can[usename] then

							char.is.can[usename](char , item )
							
						elseif usename=="menu" then -- alternative menu

							basket.level.main.menu.show_item_menu(char)

						end
						
					elseif char.is.can.fight and item.is.can.fight then
					
						if char.is.player or item.is.player then -- do not fight amongst selfs				
							yarn_fight.hit(item,char)
							return 1
						end
						
					end
				else -- just move
					item.set_cell(c)
					return 1 -- time taken to move
				end
				
			end
			return 0
		end

		function item.die()
			if item.is.player then -- we deaded
				local main=basket.level.main
				main.soul.last_stairs=nil
				main.save()
				basket.level=basket.level.destroy()

				hp=item.is.hp -- regen
				
				basket.level=yarn_level.create(yarn_attrs.get("level.home",1,{xh=40,yh=28}),main)
				main.menu.hide()
				
				-- setup cyro stuff again
				local v
				v=basket.level.find_item("cryo_door") v.can.set_close(v)
				v=basket.level.find_item("cryo_bed") v.can.set_open(v)
				
				-- reposition next to the bed
				v=basket.level.find_item("cryo_bed")
				for i,v in v.cell.neighbours() do
					if v.is_empty() then --empty so place palyer here
						basket.level.player.set_cell( v )
						break
					end
				end



				
				basket.level.add_msg("You feel dead...")

			else
			
				local p=basket.level.new_item( name.."_corpse" )
				p.set_cell( cell )
				
				if item.loot then
					for n,p in pairs(item.loot) do
						if math.random() < p then
							local l=basket.level.new_item( n )
							l.set_cell( cell )
						end
					end
				end

				basket.level.del_item(item)
			end
		end

		function item.update()
		
			if item.can.roam=="random" then
			
				if 	item.time_passed<basket.level.time_passed then
			
					local vs={ {1,0} , {-1,0} , {0,1} , {0,-1} }
					
					vs=vs[basket.level.rand(1,4)]
					
					item.move(vs[1],vs[2])
					
					item.time_passed=time_passed+1
				end
				
			end
			
		end

	-- create a save state for this data
		function item.save()
			local sd={}
			
			sd=yarn_attr.save(item.is)
			
			return sd
		end

	-- reload a saved data (create and then load)
		function item.load(sd)
			item.is=yarn_attr.load(sd)
--			item.metatable.__index=item.is
			
			for _,n in ipairs(yarn_attr.keys_name_and_subnames(item.is.name)) do
			
				basket.level.cellfind[n]=item.cell -- last generated cell of this type
				
				local l=basket.level.celllist[n] or {} -- all generated cells of this type
				l[#l+1]=item.cell
				basket.level.celllist[n]=l
				
			end
		end

		return item
		
	end

	return items
end

