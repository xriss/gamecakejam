-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math

local function dprint(a) print(wstr.dump(a)) end

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,hud)
	local hud=hud or {}
	hud.oven=oven
	
	hud.modname=M.modname

	local cake=oven.cake
	local opts=oven.opts
	local canvas=cake.canvas
	local font=canvas.font
	local fonts=cake.fonts
	local flat=canvas.flat
	local gl=oven.gl
	local sheets=cake.sheets
	
	local sgui=oven.rebake("wetgenes.gamecake.spew.gui")

	local gui=oven.rebake(oven.modgame..".gui")
	local main=oven.rebake(oven.modgame..".main")
--	local beep=oven.rebake(oven.modgame..".beep")
	local bullets=oven.rebake(oven.modgame..".bullets")
	local enemies=oven.rebake(oven.modgame..".enemies")
	local explosions=oven.rebake(oven.modgame..".explosions")
	local beep=oven.rebake(oven.modgame..".beep")
	local ships=oven.rebake(oven.modgame..".ships")

	local sscores=oven.rebake("wetgenes.gamecake.spew.scores").setup(1)
	local srecaps=oven.rebake("wetgenes.gamecake.spew.recaps")




hud.loads=function()

end
		
hud.setup=function()

	sscores.reset()
	enemies.level=0
	hud.number=0
	
end

hud.clean=function()

	sscores.final_score({})

end

hud.msg=function(m)

--	print (wstr.dump(m))

end

hud.update=function()

	local number=sscores.get(1)
	
	if 	   number>=hud.number+100000 then hud.number=hud.number+100000
	elseif number>=hud.number+ 10000 then hud.number=hud.number+ 10000
	elseif number>=hud.number+  1000 then hud.number=hud.number+  1000
	elseif number>=hud.number+   100 then hud.number=hud.number+   100
	elseif number>=hud.number+    10 then hud.number=hud.number+    10
	elseif number>=hud.number+     1 then hud.number=hud.number+     1
	end
		
end

hud.draw=function()
	
--	sscores.draw("arcade2")
--	print(number)
	font.set("Akashi")
	
	local s=(wstr.str_insert_number_commas(hud.number))
	font.set_size(42)
	font.set_xy(256-font.width(s)/2,3)
	gl.Color(1,1,1,1) 
	font.draw(s)
	
	local t={
		{score=     0,color=0xffffffff,string=""},
		{score=  1000,color=0xffffffff,string="oi, wotcha doing killin' mah shawties?"},
		{score=  5000,color=0xffffffff,string="hey, i'm talking to you. stop ignoring me!"},
		{score= 10000,color=0xffffffff,string="ok, so you're probably not reading this then."},
		{score= 15000,color=0xffffffff,string="or maybe you are but there's no possible way i can hear you. can i?"},
		{score= 20000,color=0xffffff00,string="i know you're definitely reading this."},
		{score= 25000,color=0xffffffff,string="actions speak louder than words, you know."},
		{score= 30000,color=0xff1e90ff,string="and your actions are telling me you're a hostile entity."},
		{score= 35000,color=0xffffffff,string="cease shooting or i... i will react!"},
		{score= 40000,color=0xffff0000,string="i'm warning you."},
		{score= 45000,color=0xffffffff,string="right, that's it. i'm gonna get you for this."},
		{score= 50000,color=0xffff00ff,string="fly, my pretties."},
		{score= 55000,color=0xffff0000,string="FLY AND NEVER STOP."},
		{score= 60000,color=0xffffffff,string="now, now. thre's no use in getting panicky."},
		{score= 65000,color=0xffffffff,string="it's only a neverending stream of your just desserts."},
		{score= 70000,color=0xffffffff,string="this buffet spread is on me."},
		{score= 75000,color=0xffffff00,string="why? well, you started it."},
		{score= 80000,color=0xffffffff,string="now you're gonna have to end it too."},
	}
	
	local chat=t[#t]
	local chat_width=400
	
	for i,v in ipairs(t) do
		if v.score>=hud.number then
			chat=v
			break
		end
	end
	
	font.set_size(16)
	if ships[1].state=="dead" and ships[2].state=="dead"  then
		t={color=0xffff0000,string="FLY AND NEVER STOP."}
		font.set_size(38)
		chat_width=512
		chat=t
	end	
	gl.Color(gl.C8(chat.color))
	
	
	local lines=font.wrap(chat.string,{w=chat_width})
	for i,v in ipairs(lines) do
		font.set_xy(256-font.width(v)/2,53+(i-1)*16)
		font.draw(v)
	end
	
end

hud.score=function(num)
	
	sscores.add(num)
	
end

hud.reset=function()

	sscores.set(0)
	
end

	return hud
end
