-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local wstring=require("wetgenes.string")


--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(basket,code)
	code=code or {}
	code.modname=M.modname
	
local function ascii(a) return string.byte(a,1) end

local can=basket.rebake(basket.modgame..".rules.can")

local sscores=basket.oven.rebake("wetgenes.gamecake.spew.scores")

-----------------------------------------------------------------------------
-- look up an items attrs data
-----------------------------------------------------------------------------
function code.get_item(dd,name,pow,xtra)
--print("get item",name)
	local aa=wstring.split(name,".")
	
	if #aa>1 then -- must be two parts or more
		local p=tonumber(aa[#aa]) -- the last bit may be a number
		if p then
			pow=p -- override with power in name
			aa[#aa]=nil
			name=table.concat(aa,".")
		end
	end
	
	pow=pow or 0 -- pow is a +1 -1 etc, base item adjustment

	local d,parent_name


	d=dd[name.."."..pow] or dd[name] -- check with a trailing .pow first

	if not d then return nil end -- no data to get?

	if aa[2] then
		aa[#aa]=nil -- lose trailing part
		parent_name=table.concat(aa,".") -- and build parents name
	end
	
	local it={}
	
	for i,v in pairs(d) do it[i]=v end -- copy 1 deep only
	if d.powadd then for i,v in pairs(d.powadd) do it[i]=(it[i] or 0)+ (v*pow) end end
	if d.powmul then for i,v in pairs(d.powmul) do it[i]=(it[i] or 0)* math.pow(v,pow) end end
		
	it.pow=pow -- remember pow
	it.name=name -- make sure name is always base name without POW
	
	for i,v in pairs(xtra or {}) do
		it[i]=v
	end
	
	if parent_name then -- we can inherit, so try it
		return code.get_item(dd,parent_name,pow,it) or it -- recurse if we can. merging these things together
	end
	
	return it
end



-----------------------------------------------------------------------------
-- add a new item into the attrs data
-----------------------------------------------------------------------------
function code.add_item(v)
	v.id=#basket.data+1 -- every data gets a unique id
	basket.data[ v.id ] = v
	if v.name then
		basket.data[ v.name ] = v -- we can also look up by name		
	end
end

-----------------------------------------------------------------------------
-- step time forward with slowness modifier
-----------------------------------------------------------------------------
function code.step(n,c)
	if not c then c=basket.player end -- player by default
	local s=code.speed(c)
	basket.step(n*s)
	return n*s
end
function code.speed(c) -- returns speed, higher is slower...
	local count=0
	for v,b in pairs(c.items or {}) do
		count=count+1
	end
	return count
end

-----------------------------------------------------------------------------
-- convert time in ticks into an englidh string
-----------------------------------------------------------------------------
function code.time_str(t)
	local r=t
	local sc=r%60
	r=math.floor(r/60)
	local mn=r%60
	r=math.floor(r/60)
	local hr=r%60
	r=math.floor(r/60)

	if sc>0 then
		if hr>0 then return hr.." hours, "..mn.." minutes and "..sc.." seconds" end
		if mn>0 then return mn.." minutes and "..sc.." seconds" end
		return sc.." seconds"
	else
		if hr>0 then return hr.." hours and "..mn.." minutes" end
		return mn.." minutes"
	end
end

function code.time_remaining()
	if basket.level then
		return code.time_str( 18000 - (basket.time) )
	else return "" end
end

-----------------------------------------------------------------------------
-- display a sak menu, when item it is used by the player by
-----------------------------------------------------------------------------
function code.sak(it,by)
	local sak=it.is.sak
	if not sak then return end
	
	local menu=basket.menu

	local top={}
	local tab={}

	top.title=it.desc_text()

-- add cancel option
	tab[#tab+1]={
		text=[[..]],
		call=function(t)
			menu.back()
		end
	}
	
	local tim=sak.basetime	
	local gots={}
	for i,n in ipairs(sak.needs) do
		local tadd=n[2] -- time penalty
		for v,b in pairs(by.items or {}) do
--			if not v.is.equiped then
				if v.is[n[1]] then
					gots[v]=true -- allocate item, it may be used for more than one need
					tadd=0 -- no penalty
					break
				end
--			end
		end
		tim=tim+tadd
	end
	local items={}
	for v,b in pairs(gots) do
		items[#items+1]=v
	end
	
	local text=sak.action.."\n\nThis will take "..code.time_str(tim)
	if #items>0 then
		text=text.." and use up the following loots:\n"
		for i,v in ipairs(items) do
			text=text.."\n"..v.desc_text()
		end
	end
	tab[#tab+1]={
		text=text,
		call=function(t)
			menu.hide()
			for i,v in ipairs(items) do
				basket.level.del_item(v) -- destroy items we used
			end
			basket.step(tim)
			sak.done(by,it)
		end
	}

	top.display=menu.build_request(tab)
		
	menu.show(top)


end

function code.find_sak(cell)
	for i,v in cell.neighboursplus() do
		for item,b in pairs(v.items) do
			if item.is.sak then return item end
		end				
	end
end

function code.explore(it,n)
	sscores.add(n)
end

-----------------------------------------------------------------------------
-- setup everythings attributes
-----------------------------------------------------------------------------
function code.setup()

	basket.data=basket.data or {} -- data is built in here
	
	basket.call.get=code.get_item -- everything is an item
	basket.call.add=code.add_item
	basket.call.explore=code.explore


-- and setup everything else, everything is an item its all just broken into files to make it easier to find
	basket.rebake(basket.modgame..".rules.items").setup()
	basket.rebake(basket.modgame..".rules.chars").setup()
	basket.rebake(basket.modgame..".rules.rooms").setup()
	basket.rebake(basket.modgame..".rules.levels").setup()


end

	return code
end
