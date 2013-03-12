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

-----------------------------------------------------------------------------
-- look up an items attrs data
-----------------------------------------------------------------------------
function code.get_item(dd,name,pow,xtra)
--print("get item",name)
	local aa=wstring.split(name,"%.")
	
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
-- setup everythings attributes
-----------------------------------------------------------------------------
function code.setup()

	basket.data=basket.data or {} -- data is built in here
	
	basket.call.get=code.get_item -- everything is an item
	basket.call.add=code.add_item


-- and setup everything else, everything is an item its all just broken into files to make it easier to find
	basket.rebake(basket.modgame..".rules.items").setup()
	basket.rebake(basket.modgame..".rules.chars").setup()
	basket.rebake(basket.modgame..".rules.maps").setup()
	basket.rebake(basket.modgame..".rules.levels").setup()


end

	return code
end
