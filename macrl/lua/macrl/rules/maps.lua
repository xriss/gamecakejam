-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(basket,maps)
	maps=maps or {}
	maps.modname=M.modname
	
function maps.setup()
end




local strings={}
local keys={}


-----------------------------------------------------------------------------
--
-- add new room data
--
-----------------------------------------------------------------------------
function maps.add_room(name,map,key)
	if map then
		strings[name]=map
	end
	if key then
		keys[name]=key
	end
end
local room=maps.add_room


-----------------------------------------------------------------------------
--
-- build room info from an ascii map and a key
--
-----------------------------------------------------------------------------
function maps.string_to_room(s,key)

	if not key then key=keys.base end

	local r={}

	local lines=strings.split_lines(s)
	for i,v in ipairs(lines) do lines[i]=strings.trim(v).." " end -- trim, but add space back on end
	
	local xh=0
	for i,v in ipairs(lines) do if #v>xh then xh=#v end end -- find maximum line length

	local ls={}
	for i,v in ipairs(lines) do if #v==xh then ls[#ls+1]=v end end -- only keep lines of this length
	local yh=#ls
	xh=math.floor(xh/2) -- 2 chars to one cell
	
	xh=xh-2
	yh=yh-2
	
	if xh<0 then xh=0 end
	if yh<0 then yh=0 end
	
	r.xh=xh
	r.yh=yh
	
	r.name="unnnamed"
	
	r.cells={}
	for n=2,#ls-1 do -- skip top/bottom line
		local l=ls[n]
		local t={}
		r.cells[ #r.cells+1 ]=t
		for i=1+2,#l-2,2 do -- skip left/right chars
			local ab=l:sub(i,i+1)
			t[#t+1]=key[ab] or keys.base[ab] or "space"
		end
	end
	return r
end


-----------------------------------------------------------------------------
--
-- get room info by name
--
-----------------------------------------------------------------------------
function maps.get_room(name)

	local r

	if strings[name] then	
		r=maps.string_to_room( strings[name] , keys[name] )
	end

	return r
end




-- basic key, every map string uses this by default and then adds more or overides
keys.base={
	["# "]="wall",
	[". "]="space",
	["- "]="item_spawn",
	["= "]="bigitem_spawn",
	["@ "]="player_spawn",
	["< "]="stairs",
}


room("bigroom",[[
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . #
# . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . #
# . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . #
# . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . #
# . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . #
# . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . #
# . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . #
# . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . #
# . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . #
# . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . #
# . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . #
# . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . #
# . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . #
# . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . #
# . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . #
# . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . #
# . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . #
# . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . #
# . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . #
# . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . #
# . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . #
# . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . #
# . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . #
# . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . #
# . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . #
# . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
]])

room("pub",[[
# # # # # # # #
# . . . . . . #
# . = = = = . #
# . = = = = . #
# . . . . . . #
# # # # # # # #
]])

room("bank",[[
# # # # # #
# . . . . #
# . = = . #
# . = = . #
# . . . . #
# # # # # #
]])

room("shop",[[
# # # # # #
# . . . . #
# . = = . #
# . = = . #
# . = = . #
# . = = . #
# . . . . #
# # # # # #
]])

room("hotel",[[
# # # # # # #
# . . . . . #
# . = = = . #
# . = = = . #
# . = = = . #
# . . . . . #
# # # # # # #
]])


room("home_bedroom",[[
# # # # # # # # # #
# . . . . . . . . #
# . # # # # # # . #
# . # =1@ . . =2. #
# . # # # # # # . #
# . . . . . . . . #
# # # # # # # # # #
]],{
	["=1"]="cryo_bed",
	["=2"]="cryo_door",
})

room("home_mainroom",[[
# # # # # # # # # #
# . . . . . . . . #
# . = = . . = = . #
# . = = . . = = . #
# . = = . . = = . #
# . = = . . = = . #
# . . . . . . . . #
# # # # # # # # # #
]])

room("home_stairs",[[
# # # # # # #
# . . . . . #
# . # # # . #
# . . < # . #
# . # # # . #
# . . . . . #
# # # # # # #
]],{
	["< "]="stairs.home",
})

room("dump_stairs",[[
# # # # # #
# . . . . #
# . < @1. #
# . . . . #
# # # # # #
]],{   
	["< "]="stairs.dump",
	["@1"]="sensei.dump",
})



room("stairs",[[
# # # # #
# . . . #
# . < . #
# . . . #
# # # # #
]],{
	["< "]="stairs",
})

room("redroom",[[
# # # # # #
# . . . . #
# . @1@2. #
# . . . . #
# # # # # #
]],{
	["@1"]="sensei.twin1",
	["@2"]="sensei.twin2",
})

	return maps
end
