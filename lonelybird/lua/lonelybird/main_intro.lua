-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math

local function dprint(a) print(wstr.dump(a)) end

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,intro)
	local intro=intro or {}
	intro.oven=oven
	
	intro.modname=M.modname

	local cake=oven.cake
	local opts=oven.opts
	local canvas=cake.canvas
	local font=canvas.font
	local flat=canvas.flat
	local gl=oven.gl
	local sheets=cake.sheets
	
	local sgui=oven.rebake("wetgenes.gamecake.spew.gui")

	local gui=oven.rebake(oven.modgame..".gui")
	local main=oven.rebake(oven.modgame..".main")
	local beep=oven.rebake(oven.modgame..".beep")

	local sscores=oven.rebake("wetgenes.gamecake.spew.scores")
	local srecaps=oven.rebake("wetgenes.gamecake.spew.recaps")

	local layout=cake.layouts.create{}


	intro.firsttime=true

intro.loads=function()

end
		
intro.setup=function()

	intro.loads()

	intro.state=1
	
	intro.texts={
[[

Loneliness is a real issue.

Every gravestone you pass is a real person who died alone...

]],
[[

These gravestoes represent people who have been forgotten.

People like you and me.

]],
[[

Their funerals have been paid for by the council.

just peole between Jan 2012 - Feb 2014

]],
[[

What about other places and other years?

What about tomorrow?

]],
	}

	intro.text=intro.texts[1]

end

intro.clean=function()

end

intro.msg=function(m)

--	print(wstr.dump(m))

	if m.action==-1 then intro.click() end

end

intro.click=function()

	intro.state=intro.state+1
	intro.text=intro.texts[intro.state]

	beep.play("click")
	
end

intro.update=function()

	if intro.state>#intro.texts or not intro.firsttime then
		intro.firsttime=false
		main.next=oven.rebake(oven.modgame..".main_menu")
	end

end

intro.draw=function()
	
	if main.day==1 then
		sheets.get("imgs/day"):draw(1,512/2,512/2,nil,1024,512)
	else
		sheets.get("imgs/night"):draw(1,512/2,512/2,nil,1024,512)
	end

	sheets.get("imgs/ground"):draw(1,512/2,512/2,nil,1024,512)

--	sheets.get("imgs/title"):draw(1,512/2,512/2,nil,512,512)
--	sscores.draw("arcade2")

	sheets.get("imgs/txt"):draw(1,512/2,512/2,nil,512,512)

if intro.text then	

	gl.Color(1,1,1,1)

	font.set(cake.fonts.get("Vera"))
	font.set_size(24,0)

	local y=220
	if type(intro.text)=="string" then
		intro.text=font.wrap(wstr.trim(intro.text),{w=512-128})
	end
	for i,s in ipairs(intro.text) do
		font.set_xy(256-(font.width(s)/2),y)
		font.draw(s)
		y=y+24
	end

	gl.Color(1,1,1,1)
end
	
	
	if main.frame<30 then
		sheets.get("imgs/tap"):draw(1,512/2,512/2,nil,512,512)
	end
	
	sheets.get("imgs/back"):draw(1,512/2,512/2,nil,1024,1024)

	
end

	return intro
end
