-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math

local bit=require("bit")
local bnot = bit.bnot
local band, bor, bxor = bit.band, bit.bor, bit.bxor
local lshift, rshift = bit.lshift, bit.rshift

local pack=require("wetgenes.pack")
local wstr=require("wetgenes.string")
local hid=require("wetgenes.hid")

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,vr)
	vr=vr or {}
	vr.modname=M.modname
	
	vr.active=false
		
vr.setup=function()
	if hid.open_id then
		vr.dev = hid.open_id(0x2833, 0x0001, nil)	-- the oculus rift
	end
	if vr.dev then
	
		hid.set_nonblocking(vr.dev,1)
		assert(hid.send_feature_report(vr.dev, string.char(0x2,0xa0, 0x0a)..string.rep("\0", 14)))
		local buf = assert(hid.get_feature_report(vr.dev,0x6, 16))
		
		vr.active=true
	end
end

vr.clean=function()
	if not vr.active then return end

end

vr.update_rift=function()
	if not vr.active then return end

	-- Read a data
	while true do
		local buf = hid.read(vr.dev,62)
	--	printf("Data\n   ");

		if not buf then break end

--		bdump(buf)
		
		local head=pack.load(buf,{
			"u8","count",
			"u16","time",
			"u16","last",
			"u16","temp",
		},0)

		local tail=pack.load(buf,{
			"u16","magx",
			"u16","magy",
			"u16","magz",
		},56)
		
		-- fix the sign of a 21bit number
		local function sign21(n)
			if n>0x0fffff then return n-0x200000 end
			return n
		end

		-- take the 3 21 bit numbers are from the given 64 bits
		local function bag3x21(base)
			local b={} for i=1,8 do b[i]=pack.read(buf,"u8",base+i-1) end
			local t1=sign21( lshift(b[1],13) + lshift(b[2],5) + rshift(band(b[3],0xf8),3) )
			local t2=sign21( lshift(band(b[3],0x07),18) + lshift(b[4],10) + lshift(b[5],2) + rshift(band(b[6],0xc0),6) )
			local t3=sign21( lshift(band(b[6],0x3f),15) + lshift(b[7],7) + rshift(band(b[8],0xfe),1) )
			return t1,t2,t3
		end
		
		local data={}
		if head.count>2 then head.count=3 end
		for i=1,head.count do
			local d={}
			data[i]=d
			d.accx , d.accy , d.accz = bag3x21( 8 +     16*(i-1) )
			d.gyrx , d.gyry , d.gyrz = bag3x21( 8 + 8 + 16*(i-1) )
		end
		
		local x,y,z=data[1].gyrx , data[1].gyry , data[1].gyrz
		local dd=x*x + y*y + z*z
		local d=math.sqrt(dd)
		if d<0 then d=1 end
		x=x/d
		y=y/d
		z=z/d
		
		print( math.floor(d) , math.floor(x*100)/100,math.floor(y*100)/100,math.floor(z*100)/100 )

--		print( head.count , data[1].gyrx , data[1].gyry , data[1].gyrz ) 
		
--		print( data[1].accx , data[1].accy , data[1].accz , ".", data[1].gyrx , data[1].gyry , data[1].gyrz , ".", 
--		tail.magx, tail.magy, tail.magz , "-" ,  head.last*65536 + head.time, head.temp )
		
	end




end
	vr.update=vr.update_rift

	return vr
end

