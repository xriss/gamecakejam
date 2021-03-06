-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local wstr=require("wetgenes.string")

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(basket,rooms)
	rooms=rooms or {}
	rooms.modname=M.modname

local strings={}
local keys={}


-----------------------------------------------------------------------------
--
-- add new room data
--
-----------------------------------------------------------------------------
function rooms.add_room(name,map,key)
	if map then
		strings[name]=map
	end
	if key then
		keys[name]=key
	end
end
local room=rooms.add_room


-----------------------------------------------------------------------------
--
-- build room info from an ascii map and a key
--
-----------------------------------------------------------------------------
function rooms.string_to_room(s,key)

	if not key then key=keys.base end

	local r={}

	local lines=wstr.split_lines(s)
	for i,v in ipairs(lines) do lines[i]=wstr.trim(v).." " end -- trim, but add space back on end
	
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
function rooms.get_room(name)

	local r

	if strings[name] then	
		r=rooms.string_to_room( strings[name] , keys[name] )
	end

	return r
end




-- basic key, every map string uses this by default and then adds more or overides
keys.base={
	["# "]="wall",
	[". "]="floor",
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


room("controls",[[
# # # # # # # # # # #
# . . . . . . . . . #
# . . @1. @2. @3. . #
# . . . . . . . . . #
# . . @4. @5. @6. . #
# . = = = = = = = . #
# . . . . . . . . . #
# # # # # # # # # # #
]],{
	["@1"]="control.colson",
	["@2"]="control.burke",
	["@3"]="control.gantner",
	["@4"]="control.tech1",
	["@5"]="control.tech2",
	["@6"]="control.tech3",
	["= "]="console",
})

room("rescue1",[[
# # # # # # # # # # #
# . . . . . . . . . #
# . . @4. @5. @6. . #
# . . @4. @5. @6. . #
# . . @4. @5. @6. . #
# . . . . @1. . . . #
# . . . . . . . . . #
# # # # # # # # # # #
]],{
	["@4"]="victim.tech4",
	["@5"]="victim.tech5",
	["@6"]="victim.tech6",
	["@1"]="spencer",
})
room("rescue_exit",[[
# # # # #
# . . . #
# . = . #
# . . . #
# # # # #
]],{
	["= "]="wood_plank",
})


room("shaft",[[
# # # # #
# . L . #
# . = . #
# . . . #
# # # # #
]],{
	["= "]="lift_vent",
	["L "]="wood_plank",
})

room("entrance",[[
# # # # #
# . . . #
# B = @ #
# . . . #
# # # # #
]],{
	["= "]="helipad",
	["@ "]="spawn",
	["B "]="binoculars",
})

room("collapsed",[[
# # # # # # #
# . x . x . #
# x x x x x #
# . x x x . #
# x x x x x #
# . x . x . #
# # # # # # #
]],{
	["= "]="helipad",
	["x "]="rubble",
})

room("lazer",[[
# # # # #
# = = = #
# = = = #
# = = = #
# # # # #
]],{
	["= "]="lazer",
})

room("entrance3",[[
# # # # #
# . . . #
# . @ . #
# . . . #
# # # # #
]],{
	["@ "]="spawn",
})

room("blockage",[[
# # # # # #
# x . . x #
# . x x . #
# . x x . #
# x . . x #
# # # # # #
]],{
	["x "]="blockage",
})

function rooms.setup()

basket.call.add{
	name="room",
}

end


	return rooms
end
