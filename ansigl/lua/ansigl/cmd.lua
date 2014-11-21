-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local global=require("global")

local pack=require("wetgenes.pack")
local wstr=require("wetgenes.string")

local function dprint(a) print(wstr.dump(a)) end

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M


M.start=function(opts)
	local dowin=false
	
local help=[[

Example commandlines.

	gamecake ansigl.cake filename.ansi
Render the given ansi file, without a filename nothing will be shown.

	gamecake ansigl.cake filename.ansi --fullscreen
Render in fullscreen mode.
	
]]
	
	opts.ansibins={}
	for i=1,#opts do
		local v=opts[i]
		
-- try and read an ansi file
		local fp=io.open(v,"rb")
		if fp then
			local it={}
			it.filename=v
			it.data=fp:read("*all")
			
			opts.ansibins[#opts.ansibins+1]=it
			fp:close()
		end
		
		if v=="--fullscreen" then opts.show="full" end

	end

	if #opts.ansibins>0 then
		dowin=true
	else
		print(help)
	end

	if dowin then
		global.oven=require("wetgenes.gamecake.oven").bake(opts).preheat()
		return oven:serv()
	end
end
