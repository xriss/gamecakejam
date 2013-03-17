-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(basket,can)
	can=can or {}
	can.modname=M.modname

local yarn_fight=basket.rebake("yarn.fight")
local yarn_levels=basket.rebake("yarn.levels")

local code=basket.rebake(basket.modgame..".rules.code")

local sscores=basket.oven.rebake("wetgenes.gamecake.spew.scores")

-----------------------------------------------------------------------------
--
-- base can flags and functions for a fighter
--
-----------------------------------------------------------------------------
can.fight={
	fight=true,
	roam="random",
	acts=function(it,by)
		if it.can.fight and by.can.fight then return {"hit","look"} end
		return {"look"}
	end,
	hit=function(it,by)
		if it.can.fight and by.can.fight then yarn_fight.hit(by,it) end
		basket.menu.hide()
		code.step(1)
	end,
	look=function(it,by)
		basket.menu.show_text(it.desc_text(),it.look_text())
	end,
}

-----------------------------------------------------------------------------
--
-- base can flags and functions for a talker
--
-----------------------------------------------------------------------------
can.talk={
	use="talk",
	acts=function(it,by)
		if by.is.can.operate then return {"talk","look"} end
		return {"look"}
	end,
	talk=function(it,by)
		if by.is.can.operate then
			basket.menu.show_talk_menu(it,by)
		end
	end,
	look=function(it,by)
		basket.menu.show_text(it.desc_text(),it.look_text())
	end,
}

-- a talker who also wanders
can.talkroam={}
for i,v in pairs(can.talk) do can.talkroam[i]=v end
can.talkroam.roam="random"


-----------------------------------------------------------------------------
--
-- base can flags and functions for an item
--
-----------------------------------------------------------------------------
can.item={
	acts=function(it,by)
		if by.is.can.operate then
			if by.items and by.items[it] then
				if it.is.can.equip then
					if it.is.equiped then
						return {"unequip","drop","look"}
					else
						return {"equip","drop","look"}
					end
				else
					return {"drop","look"}
				end
			else
				return {"get","get and equip","look"}
			end
		end
		return {"look"}
	end,
	["get and equip"]=function(it,by)
		it.set_cell(by)
		it.is.equiped=true
		basket.menu.hide()
		code.step(1)
	end,
	get=function(it,by)
		it.set_cell(by)
		basket.menu.hide()
		code.step(1)
	end,
	drop=function(it,by)
		it.is.equiped=false
		it.set_cell(by.cell)
		basket.menu.hide()
		code.step(1)
	end,
	equip=function(it,by)
		it.is.equiped=true
		basket.menu.hide()
		code.step(1)
	end,
	unequip=function(it,by)
		it.is.equiped=false
		basket.menu.hide()
		code.step(1)
	end,
	look=function(it,by)
		basket.menu.show_text(it.desc_text(),it.look_text())
	end,
}

-----------------------------------------------------------------------------
--
-- special use items
--
-----------------------------------------------------------------------------
local c={}
can.sak=c
for i,v in pairs(can.item) do c[i]=v end -- item base
	c.acts=function(it,by)
		local r={}--can.item.acts(it,by)
		table.insert(r,1,"use")
		return r
	end
	c.use=function(it,by)
		local t=code.find_sak(by.cell)
		if t then
			code.sak(t,by)
		else
			basket.menu.show_text(it.desc_text(),"There is nothing close by that your Swiss Army Knife can be used on.")
		end
	end

local c={}
can.watch=c
for i,v in pairs(can.item) do c[i]=v end -- item base
	c.acts=function(it,by)
		local r=can.item.acts(it,by)
--		if it.is.equiped then
--			table.insert(r,1,"There are "..code.time_remaining().." remaining.")
--		else
			table.insert(r,1,"use")
--		end
		return r
	end
	c.use=function(it,by)
		basket.menu.show_text(it.desc_text(),"There are "..code.time_remaining().." remaining.")
	end
-----------------------------------------------------------------------------
--
-- base can flags and functions for an non interactive item
--
-----------------------------------------------------------------------------
can.look={
	use="look",
	acts=function(it,by)
		return {"look"}
	end,
	look=function(it,by)
		basket.menu.show_text(it.desc_text(),it.look_text())
	end,
}

-----------------------------------------------------------------------------
--
-- base can flags and functions for an non interactive item
--
-----------------------------------------------------------------------------
can.scrump={
	use="scrump",
	acts=function(it,by)
		return {"scrump"}
	end,
	scrump=function(it,by)
		code.step(2)
		local items={}
		for i,v in pairs(it.is.scrump.items) do
			if math.random()<v[2] then
				local t=basket.level.new_item(v[1])
				t.set_cell( it.cell )
				items[#items+1]=t
			end
		end
		basket.level.del_item(it) -- destroy items we used
		if #items>0 then
			local t="You search "..it.desc_text().." and found the following useful components:\n"
			for i,v in ipairs(items) do
				t=t.."\n"..v.desc_text()
			end
			basket.menu.show_notice(it.desc_text(),t)
		else
			basket.menu.show_notice(it.desc_text(),"You search "..it.desc_text().." and found nothing useful.")
		end
		sscores.add(it.is.scrump.score)
	end,
}

	return can
end
