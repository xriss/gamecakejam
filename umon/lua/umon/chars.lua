-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math

local function dprint(a) print(wstr.dump(a)) end

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,chars)
	local chars=chars or {}
	chars.oven=oven
	
	chars.modname=M.modname

	local cake=oven.cake
	local opts=oven.opts
	local canvas=cake.canvas
	local font=canvas.font
	local flat=canvas.flat
	local gl=oven.gl
	local sheets=cake.sheets
	

	local gui=oven.rebake(oven.modgame..".gui")
	local main=oven.rebake(oven.modgame..".main")
	local play=oven.rebake(oven.modgame..".main_play")
--	local beep=oven.rebake(oven.modgame..".beep")

	local console=oven.rebake("wetgenes.gamecake.mods.console")


local char={} ; char.__index=char

char.setup=function(it,opt)
	local it=it or {}
	setmetatable(it,char) -- allow : functions
	
	it.px=opt.px or 0
	it.py=opt.py or 0

	it.flava=opt.flava or "none"
	
	it.char=opt.char or 17
	
	it.frame=opt.frame or 0

	
	return it
end
char.clean=function(it)
end
char.update=function(it)
	it.frame=(it.frame+1)%64
end
char.draw=function(it)

	local i=it.char
	local px=it.px
	local py=it.py
	local f=math.floor(it.frame/16)

	gl.Color(0,0,0,0.75)
	sheets.get("imgs/char_01"):draw(i+f,px-3,py,nil,32*3,32*3)
	sheets.get("imgs/char_01"):draw(i+f,px+3,py,nil,32*3,32*3)
	sheets.get("imgs/char_01"):draw(i+f,px,py-3,nil,32*3,32*3)

	gl.Color(1,1,1,1)
	sheets.get("imgs/char_01"):draw(i+f,px,py,nil,32*3,32*3)


end


chars.loads=function()

end
		
chars.setup=function()

	chars.loads()
	chars.tab={}
	
	for i=1,16 do
				chars.add{
			px=-400+i*50,py=8*3,
			flava="base",
			char=1+(i-1)*4,
			frame=(i*8)%64,
		}
	end
end

chars.clean=function()

	for i,v in ipairs(chars.tab) do
		char.clean(v)
	end
	
end

chars.msg=function(m)

--	print(wstr.dump(m))

end

chars.update=function()

	for i=#chars.tab,1,-1 do
		local it=chars.tab[i]
		it:update()
		if it.flava=="dead" then
			table.remove(chars.tab,i)
		end
	end

end

chars.draw=function()
	
	for i,it in ipairs(chars.tab) do
		it:draw()
	end

	console.display ("chars "..#chars.tab)

end

chars.add=function(opt)

	local it=char.setup({},opt)
	chars.tab[#chars.tab+1]=it

end

chars.remove=function(it)

	for i,v in ipairs(chars.tab) do
		if v==it then
			table.remove(chars.tab,i)
			return
		end
	end

end


	return chars
end
