-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math
local wjson=require("wetgenes.json")

local dprint=function(...) return print(wstr.dump(...)) end

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,players)
	players=players or {}
	players.modname=M.modname
	
players.setup=function()
	
end

players.reset=function()

end

players.pulse=function(it)

--"GET /depart?callback=jQuery111109870878029614687_1404405668994&rotation=169&touched=0&_=1404405669356 HTTP/1.1"

	local line=(it.data:gmatch("[^\r\n]+"))() -- get first line
	if not line then return end
	local parts=wstr.split(line," ")
	if not parts or not parts[2] then return end

	local q=wstr.split(parts[2],"?")
	if not q or not q[2] then return end
	q=q[2]
	
	
	local qs=wstr.split(q,"&")
	local m={}
	for i,v in ipairs(qs) do
		local a=wstr.split(v,"=")
		if a[1] and a[2] then
			m[ a[1] ]=a[2]
		end
	end

--	dprint(wstr.dump(m))
	
	it.ret={test="123",avatar=1}
	
	
	it.ret_code=200
	it.ret_data=m.callback.."("..wjson.encode(it.ret)..");\n"

end

players.update=function()

end

	return players
end

