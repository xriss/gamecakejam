-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

-- these attributes, live in an objects .is table
-- so we can write code such as -> if item.is.wood then
-- this mostly reads ok, the attributes are real gamedata
-- with the base table handling more transcient data and pointers to other tables
-- sub tables here are usually shared across items rather than instanced
-- so be careful not to modify

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(basket,attrs)
	attrs=attrs or {}
	attrs.modname=M.modname

	attrs.get=function(name,pow,xtra)
		local ret
--		print("do get",name,pow,xtra)
		if basket.call.get then
			ret=basket.call.get(basket.data,name,pow,xtra)
--			print("got",name)
		end
		return ret or xtra or {}
	end

-- pass in a table created by yarn_attrs.get
	function attrs.create(attr)

		attr=attr or {}
		
-- any state data you expect to persist must be stored in the base table
-- never change any of the sub tables, eg .can as these are
-- shared tables so any change will effect all other objects of the same class
-- all data goes into this main table

		attr.set={}
		attr.get={}
		attr.can=attr.can or {} -- this may be shared data but we always need a table

		function attr.set.name(v)       attr.name=v end
		function attr.get.name() return attr.name   end
		
		function attr.set.visible(v)       attr.visible=v end
		function attr.get.visible() return attr.visible   end
				
--	function get.visible() return true end -- debug

		return attr
		
	end

-- create a save state for this attr which contains enough information
-- to recreate this attr when combined with the attrdata tables
-- so this is a diff from an yarn_attrs.get
-- the result should be good to save as json
	function attrs.save(attr)

		local ad=yarn_attrs.get(attr.name,attr.pow) -- get base data to compare
		local sd={}
		for i,v in pairs(attr) do
			if ( type(ad[i])==type(v) ) and ad[i]==v then -- no change from base
			else
				if type(v)=="table" then --ignore tables, one deep save only
				else
					sd[i]=v -- this is something we are interested in
				end
			end
		end
	-- always include these two

		sd.name=attr.name
		sd.pow=attr.pow
		if sd.pow==0 then sd.pow=nil end
		
		return sd -- a table of changes to base data
	end

-- reload a saved data (use instead of create)
	function attrs.load(sd)
		return attrs.create( attrs.get(sd.name,sd.pow,sd) ) -- unpack and create
	end


-- names that have a .in them are sub classes
-- we need to be able to find them using their subclass
-- so turn a name with . into a list of possible names
-- the last part may be a number in which case it is the pow value
	function attrs.keys_name_and_subnames(s)
		local splits={}
		local i=1
		repeat
			i=s:find(".",i,true)
			if i then
				splits[ #splits+1 ] = s:sub(1,i-1)
				i=i+1
			end
		until not i
		splits[ #splits+1 ]=s -- add all last
		return splits
	end


	return attrs
end
