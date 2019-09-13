-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math

local function dprint(a) print(wstr.dump(a)) end

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,game)
	local game=game or {}
	game.oven=oven
	
	game.modname=M.modname
	
	game.name="game"

	local cake=oven.cake
	local opts=oven.opts
	local canvas=cake.canvas
	local font=canvas.font
	local flat=canvas.flat
	local gl=oven.gl
	local sheets=cake.sheets
	
	local sgui=oven.rebake("wetgenes.gamecake.spew.gui")

	local balls=oven.rebake(oven.modgame..".balls")
	local bats=oven.rebake(oven.modgame..".bats")
	local emits=oven.rebake(oven.modgame..".emits")

	local gui=oven.rebake(oven.modgame..".gui")
	local main=oven.rebake(oven.modgame..".main")
--	local beep=oven.rebake(oven.modgame..".beep")

	local sscores=oven.rebake("wetgenes.gamecake.spew.scores")
	local srecaps=oven.rebake("wetgenes.gamecake.spew.recaps")



game.back="imgs/title"

game.loads=function()

end
		
game.setup=function()

	game.loads()

--	beep.stream("game")

	bats.setup()
	balls.setup()

	emits.setup()
	
	game.scoreid=0
	game.scoret=0

	game.setup_done=true

end

game.clean=function()

--	bats.clean()
--	balls.clean()

end

game.msg=function(m)

--	print(wstr.dump(m))

	bats.msg(m)

end

game.update=function()

	bats.update()
	balls.update()
	emits.update()
	
	local s1=sscores.get(1)
	local s2=sscores.get(2)

-- table tenis score rules, 2 points ahead and a score of 11 or more to win
	
	if game.scoreid>0 and game.scoret>0 then
	
		local t=game.scoret
		t=t-3
		game.scoret=t
		
		local px=400
		local py=250
		local rz=0
		local ss=1
		
		if t>100 then
			ss=((130-t)/30)
			ss=math.sqrt(ss)
		else
			local c=(100-t)/4
			py=py+c*c
			if game.scoreid == 2 then
				rz=rz+c*-5
			else
				rz=rz+c*5
			end
		end
		
		local s=sheets.get( "imgs/score"..game.scoreid )
		game.sdraw=function()
		s:draw(1, px , py, rz , ss*800,ss*500)
		end
	else
		game.scoreid=0
		game.sdraw=nil


	end

		if s1>1 and s1>s2+1 then 
			main.next=oven.rebake(oven.modgame..".main_menu")
		end
		
		if s2>1 and s2>s1+1 then 
			main.next=oven.rebake(oven.modgame..".main_menu")
		end	
end

game.draw=function()

	gl.Color(1,1,1,1)
	if main.now.name=="game" then
		sheets.get("imgs/gameback"):draw(1,400,250,nil,800,500)
	end
	
	local a=1/4
	gl.Color(0,0,0,1)
	if main.now.name=="game" then
		gl.Color(0,0,0,1)
	else
		gl.Color(0,0,0,0.5)
	end

	font.set(cake.fonts.get("Blackout Midnight")) -- default font
	font.set_size(350,0)

	local s=tostring( sscores.get(1) )
	local w=font.width(s)
	font.set_xy( 100 , 30 )
	font.draw( s )

	local s=tostring( sscores.get(2) )
	local w=font.width(s)
	font.set_xy( 700-w , 30 )
	font.draw( s )


	gl.Color(0,0.25,0,0)

	local px=400
	local py=10

	local sx=400
	local sy=10
	
	local sx2=sx+2
	local sy2=sy+2

	local px2=400
	local py2=500-10

--[[
	flat.tristrip("xyz",{	
		px-sx,py-sy,0,
		px+sx,py-sy,0,
		px-sx,py+sy,0,
		px+sx,py+sy,0,
		px+sx,py+sy,0,

		px-sx2,py-sy2,0,
		px-sx2,py-sy2,0,
		px+sx2,py-sy2,0,
		px-sx2,py+sy2,0,
		px+sx2,py+sy2,0,
		px+sx2,py+sy2,0,

		px2-sx,py2-sy,0,
		px2-sx,py2-sy,0,
		px2+sx,py2-sy,0,
		px2-sx,py2+sy,0,
		px2+sx,py2+sy,0,
		px2+sx,py2+sy,0,

		px2-sx2,py2-sy2,0,
		px2-sx2,py2-sy2,0,
		px2+sx2,py2-sy2,0,
		px2-sx2,py2+sy2,0,
		px2+sx2,py2+sy2,0,
	})
]]	
	

	bats.draw()
	balls.draw()
	emits.draw()
	
	if game.sdraw then game.sdraw() end


		
--	sscores.draw("arcade2")


end

	return game
end
