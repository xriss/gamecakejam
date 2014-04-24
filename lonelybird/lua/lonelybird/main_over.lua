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
	local beep=oven.rebake(oven.modgame..".beep")

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
		"On {year}-{month0}-{day0} in the {postcode} area of Leeds, someone died alone. \n \n The council had to arrange the funeral since no one else wanted to.",
		"Loneliness affects people and is a real issue. \n \n When was the last time you called your grandma? Are they okay?",
		"Loneliness affects people and is a real issue. \n \n When was the last time you called your grandpa? Are they okay?",
		"Loneliness affects people and is a real issue. \n \n When was the last time you called your mom? Are they okay?",
		"Loneliness affects people and is a real issue. \n \n When was the last time you called your dad? Are they okay?",
		"Somewhere in {postcode} of Leeds, someone died today. \n \n No one claimed them or missed them so the council had to arrange the funeral.",
		"Do you live in Leeds {postcode}? \n \n There was a death there on {day}-{month}-{year}. The council had to arrange the funeral since no one else wanted to.",
		"Leeds {postcode}, the person who died here on {day}-{month}-{year} couldn't afford their own funeral so the council had to arrange it.",
		"Shockingly, half of all older people consider the television their main form of company.",
		"Can you imagine anything worse than outliving all your friends and family? \n \n Everyone you know?",
		"Just another death for the council to take care of. \n \n Who were they? Why didn't anybody miss them?",
		"The person who died here on {day}-{month}-{year} had family that won't provide for their funeral costs.",
		"When you die, will your family know about it? \n \n This person's family didn't so the council had to arrange the funeral.",
		"What happens when everyone you know has left you behind?",
		"Someone in Leeds {postcode} died here on {day}-{month}-{year}. No one knows their story or who they used to be. \n \n Could this be you?",
		"Someone in Leeds {postcode} died here on {day}-{month}-{year}. No one knows their story or who they used to be. \n \n Could this be someone you know?",
		"When you die, what will be your legacy? \n \n A funeral arranged by the council?",
		"Everyone has an answer to what they want to be when they grow up but what do you want to be when you grow old?",
		"This person died lonely with no one to take care of their funeral. We don't who they used to be, we don't know they were. \n \n Could this be someone you know?",
		"The council had to arrange for this person's funeral because no one in their family wanted to. \n \n Could this be someone you know?",
	}
	local s=words[math.random(#words)]

	over.texts=wstr.replace(s,v)
	
	beep.stream("over")
	
end

over.clean=function()

end

over.msg=function(m)

--	print(wstr.dump(m))

	if m.action==-1 then over.click() end

end

over.click=function()

	over.state=over.state+1
	
	beep.play("click")

end

over.update=function()

	if srecaps.get("fire_clr") then over.click() end

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
	font.set_size(21,0)

	local y=190
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
