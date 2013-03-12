-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

-- The yarn canvas is a table of characters (8x8) to fit in a 320x240 screen 40x30 chars (bottom 2 are status)
-- this gives us a "real" display option of 16x16 icons/tiles on a 640x480 screen, best pixelart size?
-- This can be printed in a normal font by using a space after every char. 
-- IE we can telnet this baby over the internets

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(basket,canvas)
	canvas=canvas or {}
	canvas.modname=M.modname

	local yarn_ascii=basket.rebake("yarn.ascii")

	canvas.asc={}
	canvas.xh=40
	canvas.yh=30
	
	local i
	for y=0,canvas.yh-1 do
		for x=0,canvas.xh-1 do
		
			i=1+x+y*canvas.xh
			
			canvas.asc[i]=yarn_ascii.space
		end
	end
	

	function canvas.print(x,y,s)

		local id=1+x+y*canvas.xh
		
		for i=1,#s do
		
			if canvas.asc[id] then
			
				canvas.asc[id]=string.byte(s,i)
			
			end
			
			id=id+1
		
		end
		
	end

	function canvas.draw_box(x,y,xh,yh)

		local sc=string.rep("#",xh)
		canvas.print(x,y,sc)
		for i=1,yh-2 do
			local s="#"..string.rep(" ",xh-2).."#"
			canvas.print(x,y+i,s)
		end
		canvas.print(x,y+yh-1,sc)
		
		
	end

	function canvas.draw_fill(x,y,xh,yh)

		local sc=string.rep(" ",xh)
		for i=1,yh do
			canvas.print(x,y+i-1,sc)
		end
		
	end


	function canvas.tostring(opts)
	local opts=opts or {}

	local i=0
	local t={}

		-- pull in from level
		for y=0,canvas.yh-1 do
			for x=0,canvas.xh-1 do
				i=1+x+y*canvas.xh
				local a=basket.level.get_asc(x,y)
				if a then canvas.asc[i]=a end
			end
		end
		
		local function put(y,s)
			s=tostring(s or "")
			canvas.print(0,y,"                                        ")
			canvas.print(math.floor((40-#s)/2),y,s)
		end

	-- todo
	--	local wrap=strings.smart_wrap(level.get_msg(),40)	
		basket.menu.draw()
	
	local wrap={"Testing123"}
		
		if #wrap<1 then
			put(29,"")
		elseif #wrap<2 then
			put(28,"")
		end
		for i=30-#wrap,29 do
			put(i,wrap[i-(29-#wrap)])
		end
		
		
		local ret={}
		for y=0,canvas.yh-1 do

			for x=0,canvas.xh-1 do
			
				i=1+x+y*canvas.xh
	--			t[x+1]=asc[i]%256

				if opts.charwidth==2 then -- put a space after each char
				
					t[x*2+1]=canvas.asc[i]%256
					t[x*2+2]=32
				
				else
				
					t[x+1]=canvas.asc[i]%256
				
				end
			end
			
			local s=string.char(unpack(t))
			
			ret[#ret+1]=s
			
			if not opts.table then -- no need for nl in table mode
				ret[#ret+1]="\n"
			end
	--print(s)
			
		end
		
		if opts.table then -- return a table of strings to draw
			return ret
		else
			return table.concat(ret)
		end
	end

	return canvas
end
