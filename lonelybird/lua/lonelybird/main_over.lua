-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math

local function dprint(a) print(wstr.dump(a)) end

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,over)
	local over=over or {}
	over.oven=oven
	
	over.modname=M.modname

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
--	local beep=oven.rebake(oven.modgame..".beep")

	local sscores=oven.rebake("wetgenes.gamecake.spew.scores")
	local srecaps=oven.rebake("wetgenes.gamecake.spew.recaps")

	local layout=cake.layouts.create{}




over.loads=function()

end
		
over.setup=function()

	over.loads()

	over.state=1
	
	over.texts=nil

	local csv=main.last_wall_csv

-- available data is -> day,postcode,year,month,cost

	local v={}

	v.postcode=tostring(csv.postcode)
	v.cost=tostring(csv.cost)

	v.year=tostring(csv.year)
	v.month=tostring(csv.month)
	v.day=tostring(csv.day)
	
	v.month0=v.month
	if #v.month==1 then v.month0="0"..v.month end

	v.day0=v.day
	if #v.day==1 then v.day0="0"..v.day end

	local words={
		"On {year}-{month0}-{day0} in the {postcode} area of Leeds, someone died alone. The council had to arrange the funeral since no one else wanted to.",
		"Somewhere in {postcode} of Leeds, someone died today. Noone claimed them or missed them so the council had to arrange the funeral.",
		"Do you live in Leeds {postcode}? There was a death there on {day}-{month}-{year}. The council had to arrange the funeral since no one else wanted to.",
		"Leeds {postcode}, the person who died here on {day}-{month}-{year} couldn't afford their own funeral so the council had to arrange it.",
		"Shockingly, half of all older people consider the television their main form of company.",
		"Can you imagine anything worse than outliving all your friends and family? Everyone you know?",
		"Just another death for the council to take care of. Who were they? Why didn't anybody miss them?",
		
	}
	local s=words[math.random(#words)]

	over.texts=wstr.replace(s,v)
	
	
end

over.clean=function()

end

over.msg=function(m)

--	print(wstr.dump(m))

	if m.action==-1 then over.click() end

end

over.click=function()

	over.state=over.state+1
	
end

over.update=function()

	if over.state>=2 then
		main.next=oven.rebake(oven.modgame..".main_menu")
	end

end

over.draw=function()
	
	if main.day==1 then
		sheets.get("imgs/day"):draw(1,512/2,512/2,nil,1024,512)
	else
		sheets.get("imgs/night"):draw(1,512/2,512/2,nil,1024,512)
	end

	sheets.get("imgs/ground"):draw(1,512/2,512/2,nil,1024,512)

	sscores.draw("arcade2")

	sheets.get("imgs/gameover"):draw(1,512/2,512/2,nil,512,512)
	

	gl.Color(0,0,0,1)

	font.set(cake.fonts.get("Vera"))
	font.set_size(24,0)

	local y=200
	if type(over.texts)=="string" then
		over.texts=font.wrap(over.texts,{w=256})
	end
	for i,s in ipairs(over.texts) do
		font.set_xy(256-(font.width(s)/2),y)
		font.draw(s)
		y=y+24
	end

	gl.Color(1,1,1,1)


	if main.frame<30 then
		sheets.get("imgs/tap"):draw(1,512/2,512/2,nil,512,512)
	end

	
	sheets.get("imgs/back"):draw(1,512/2,512/2,nil,1024,1024)

	
end

	return over
end
