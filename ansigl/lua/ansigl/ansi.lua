-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wstr=require("wetgenes.string")

local function dprint(a) print(wstr.dump(a)) end

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

-- create a charmap, to decode ansi into
M.cmap=function(opts)
	opts=opts or {}
	local cmap=opts.cmap or {}

-- size of screen
	cmap.xh=opts.xh or 80
	cmap.yh=opts.yh or 80
	cmap.tab={}

	cmap.reset=function()
		-- cusor position
		cmap.x=0
		cmap.y=0

		-- foreground/background color	
		cmap.bg=0
		cmap.fg=7
		
		-- add this to the char value (deals with bold/italic etc
		cmap.base=0
		cmap.blink=0 -- bright backgrounds (add to index)
		cmap.bold=0  -- bright foregrounds (add to index)
		cmap.italic=false
		cmap.underline=false

		-- char data stored as 3 values {c,bg,fg} per char in a big array (test with array first)
		for i=1,cmap.yh*cmap.xh*3 do cmap.tab[i]=0 end -- set all to 0
	end
	cmap.reset()
	cmap.set=function(i,a,b,c)
		i=1+i*3
		cmap.tab[i]=a
		cmap.tab[i+1]=b
		cmap.tab[i+2]=c
	end
	cmap.get=function(i)
		i=1+i*3
		return cmap.tab[i],cmap.tab[i+1],cmap.tab[i+2]
	end


	cmap.print=function(str)
		for i in cmap.print_looper(str) do
		end
	end
	cmap.print_looper=function(str)
		local idx=1
		return function()
			idx=cmap.print_char(str,idx)
			return idx
		end
	end
	cmap.print_char=function(str,idx)
		if not idx then return nil end

		local peekc=function()
			return str:byte(idx)
		end

		local getc=function()
			local c=str:byte(idx)
			idx=idx+1
			return c
		end

		local scroll_y=function()
			cmap.y=cmap.y-1
			for i=1,cmap.xh do table.remove(cmap.tab,1) table.remove(cmap.tab,1) table.remove(cmap.tab,1) end
			for i=1,cmap.xh do cmap.tab[#cmap.tab+1]=0 cmap.tab[#cmap.tab+1]=0 cmap.tab[#cmap.tab+1]=0 end
		end
		local inc_y=function()
			cmap.y=cmap.y+1
			if cmap.y>=cmap.yh then scroll_y() end
		end
		local inc_x=function()
			cmap.x=cmap.x+1
			if cmap.x>=cmap.xh then cmap.x=0 inc_y() end
		end

		local sgr=function(c)
			if c==0 then
				cmap.bg=0
				cmap.fg=7
				cmap.bold=0
				cmap.blink=0
				cmap.italic=false
				cmap.underline=false
			elseif c==1 then
				cmap.bold=8
			elseif c==3 then
				cmap.italic=true
			elseif c==4 then
				cmap.underline=true
			elseif c==5 then
				cmap.blink=8
			elseif c==7 or c==27 then
				local t=cmap.fg
				cmap.fg=cmap.bg
				cmap.bg=t
			elseif c==22 then
				cmap.bold=0
			elseif c==23 then
				cmap.italic=false
			elseif c==24 then
				cmap.underline=false
			elseif c==25 then
				cmap.blink=0
			elseif c>=30 and c<=37 then
				cmap.fg=c-30
			elseif c>=40 and c<=47 then
				cmap.bg=c-40
			else
				print("unknown sgr",c)
			end
		end
		
		local escape=function(c)
			local s=""
			
			if c then -- single char escape
				s=string.char(c)
			else -- find control string
				while true do
					local c=getc()
					if c>=64 and c<=126 then
						s=s..string.char(c)
						break
					else
						s=s..string.char(c)
					end
				end
			end

			local c=string.sub(s,-1)
			local a={}
			
			if #s>1 then -- get args
				local s=string.sub(s,1,-2)
				for w in s:gmatch("[^;]+") do a[#a+1]=tonumber(w) end
			end
			
			if c=="m" then
				if not a[1] then -- reset
					sgr(0)
				else
					for i,v in ipairs(a) do sgr(v) end -- set a bunch
				end
			elseif c=="A" then
				cmap.y=cmap.y-(a[1] or 1)
				if cmap.y<0 then cmap.y=0 end
			elseif c=="B" then
				cmap.y=cmap.y+(a[1] or 1)
				if cmap.y>=cmap.yh then cmap.y=cmap.yh-1 end
			elseif c=="C" then
				cmap.x=cmap.x+(a[1] or 1)
				if cmap.x>=cmap.xh then cmap.x=cmap.xh-1 end
			elseif c=="D" then
				cmap.x=cmap.x-(a[1] or 1)
				if cmap.x<0 then cmap.x=0 end
			else
				print("unknown escape",c,a[1],a[2],a[3],a[4])
			end

		end

		if idx>#str then return nil end
		
		local c1=getc()
		local c2=peekc()
		
		if c1==0x0a then 	-- lf

			inc_y()
			cmap.x=0

		elseif c1==0x0d then 	-- cr
		
		elseif c1==0x1a then 	-- end of stream, stop
		
			return nil

		elseif c1==0x09 then 	-- tab
			cmap.x=cmap.x+8

		elseif c1==0x9b then -- escape
		
			escape()
		
		elseif c1==0x1b and c2==0x5b then 	-- escape

			idx=idx+1
			escape()			

		elseif c1==0x1b and c2>=64 and c2<=95  then 	-- escape1

			idx=idx+1
			escape(c2)

		else 			-- normal char

			cmap.set( cmap.x + cmap.y*cmap.xh , cmap.base+c1 , cmap.bg+cmap.blink , cmap.fg+cmap.bold )
			inc_x()

		end

		return idx
	end
	

	return cmap
end
