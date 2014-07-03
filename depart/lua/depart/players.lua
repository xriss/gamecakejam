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

	local bikes=oven.rebake(oven.modgame..".bikes")
	
players.setup=function()

	players.list={}
	
end

players.reset=function()

	for n,v in pairs(players.list) do
		v.bike=nil
	end
end

players.pulsemsg=function(it,msg)

	local player=players.list[it.ip]
	if not player then -- add and remember
		player={}
		player.ip=it.ip
		players.list[it.ip]=player
	end
	
	player.rotation=tonumber(msg.rotation or 0) or 0
	
	if not player.bike and msg.touched=="1" then -- try and give them a bike when they click
		player.bike=bikes.get_player_a_bike()
		if player.bike then player.bike.player=player end -- got one
	end
	if player.bike then
		player.bike.rotation=player.rotation
	end
	
	local ret={}
	
	ret.avatar=0
		
	if player.bike then
		ret.avatar=player.bike.avatar.draw_index
	end

	return ret
end


players.pulse=function(it)

	local line=(it.data:gmatch("[^\r\n]+"))() -- get first line
	if not line then return end
	local parts=wstr.split(line," ") -- second part of it
	if not parts or not parts[2] then return end
	local q=wstr.split(parts[2],"?") -- strip location as we only care about paramaters
	if not q or not q[2] then return end
	q=q[2] -- the query string
	
	
	local qs=wstr.split(q,"&")
	local m={}
	for i,v in ipairs(qs) do
		local a=wstr.split(v,"=")
		if a[1] and a[2] then
			m[ a[1] ]=a[2]
		end
	end

--	dprint(wstr.dump(m))

	it.ret=players.pulsemsg(it,m)
	
	it.ret_code=200
	it.ret_data=m.callback.."("..wjson.encode(it.ret)..");\n"

end

players.update=function()

end

	return players
end

