-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(basket,can)
	can=can or {}
	can.modname=M.modname

local yarn_fight=basket.rebake("yarn.fight")

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
		basket.level.step(1)
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
		if by.can.operate then return {"talk","look"} end
		return {"look"}
	end,
	talk=function(it,by)
		if by.can.operate then
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
		if by.can.operate then
			if by.items and by.items[it] then
				if it.can.equip then
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
		basket.level.step(1)
	end,
	get=function(it,by)
		it.set_cell(by)
		basket.menu.hide()
		basket.level.step(1)
	end,
	drop=function(it,by)
		it.is.equiped=false
		it.set_cell(by.cell)
		basket.menu.hide()
		basket.level.step(1)
	end,
	equip=function(it,by)
		it.is.equiped=true
		basket.menu.hide()
		basket.level.step(1)
	end,
	unequip=function(it,by)
		it.is.equiped=false
		basket.menu.hide()
		basket.level.step(1)
	end,
	look=function(it,by)
		basket.menu.show_text(it.desc_text(),it.look_text())
	end,
}

	return can
end
