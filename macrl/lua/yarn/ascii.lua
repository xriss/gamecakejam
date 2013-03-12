-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

-- shared attributes, across cells, items and chars
-- we metamap .attr in these tables so cell.get is really cell.attr.get

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(basket,ascii)
	ascii=ascii or {}
	ascii.modname=M.modname

	ascii.space=string.byte(" ",1)
	ascii.under=string.byte("_",1)
	ascii.star =string.byte("*",1)
	ascii.hash =string.byte("#",1)
	ascii.dash =string.byte("-",1)
	ascii.pipe =string.byte("|",1)
	ascii.plus =string.byte("+",1)
	ascii.dot  =string.byte(".",1)
	ascii.equal=string.byte("=",1)
	ascii.at   =string.byte("@",1)

	return ascii
end
