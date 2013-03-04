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

	local cake=oven.cake
	local opts=oven.opts
	local canvas=cake.canvas
	local font=canvas.font
	local flat=canvas.flat
	local gl=oven.gl
	local sheets=cake.sheets

	local beep=oven.rebake("dmazed.beep")
	local main=oven.rebake("dmazed.main")
	local gui=oven.rebake("dmazed.gui")
	local cells=oven.rebake("dmazed.cells")
	local hero=oven.rebake("dmazed.hero")
	local monster=oven.rebake("dmazed.monster")
	local darkness=oven.rebake("dmazed.darkness")
	local floaters=oven.rebake("dmazed.floaters")
	local talkers=oven.rebake("dmazed.talkers")

	local wscores=oven.rebake("wetgenes.gamecake.spew.scores")

	local recaps=oven.rebake("wetgenes.gamecake.spew.recaps")


game.loads=function()

end
		
game.setup=function()


	game.count=100
	
-- sanity
	main.herospeed=main.herospeed or 0
	main.level=main.level or 0

	main.level=main.level+1

	local rs={
		{"floor","walls"},
		{"floor4","walls1"},
		{"floor4","walls2"},
		{"floor3","walls"},
		{"floor5","walls"},
		{"floor5","walls1"},
		{"floor6","walls"},
		{"floor7","walls2"},
		{"floor7","walls1"},
		{"floor8","walls"},
		{"floor8","walls2"},
		{"floor9","walls"},
		{"floor9","walls1"},
		{"floor9","walls3"},
		{"floor10","walls3"},
		{"floor10","walls1"},
		{"floor2","walls3"},
		{"floor2","walls2"},
		{"floor1","walls3"},
		{"floor1","walls2"},
	}
	local r=main.level
	while r>#rs do r=r-#rs end
	game.floor="imgs/"..rs[r][1]
	game.walls="imgs/"..rs[r][2]
		
	game.loads()

	gui.setup()
	gui.page("game")
	
	cells.setup()
	hero.setup()
	monster.setup()
	talkers.setup()
	darkness.setup()
	floaters.setup()

--	beep.play("start")


	beep.stream("game")
	
	game.time=0
end

game.clean=function()

	floaters.clean()
	darkness.clean()
	talkers.clean()
	monster.clean()
	hero.clean()
	cells.clean()
	
	wscores.clean()
	gui.clean()

end

game.msg=function(m)

--	print(wstr.dump(m))
	
	if m.class=="mouse" then
		if m.action==1 then -- click
			game.swipe={m.x,m.y,m.x,m.y}
		elseif m.action==-1 then -- release
			game.swipe=nil
		elseif m.action==0 then --move
			if game.swipe then
				game.swipe[3]=m.x
				game.swipe[4]=m.y
			end
		end
	end

	if gui.msg(m) then return end -- gui can eat msgs
	
end

game.update=function()

	game.time=game.time+1


	if recaps.get("up") then
		hero.move="up"
		hero.lastswipe=nil
	elseif recaps.get("down") then
		hero.move="down"
		hero.lastswipe=nil
	elseif recaps.get("left") then
		hero.move="left"
		hero.lastswipe=nil
	elseif recaps.get("right") then
		hero.move="right"
		hero.lastswipe=nil
	elseif game.swipe then
		local function acc() game.swipe[1]=game.swipe[3]  game.swipe[2]=game.swipe[4] end
		local x=game.swipe[3]-game.swipe[1]
		local y=game.swipe[4]-game.swipe[2]
		local xx=x*x
		local yy=y*y
		if xx+yy > 8*8 then
			if xx > yy then
				if x>=0 then
					hero.move="right"
					hero.lastswipe=hero.move
					acc()		
				else
					hero.move="left"
					hero.lastswipe=hero.move
					acc()
				end
			else
				if y>=0 then
					hero.move="down"
					hero.lastswipe=hero.move
					acc()
				else
					hero.move="up"
					hero.lastswipe=hero.move
					acc()
				end
			end
		end
	else
		hero.move=hero.lastswipe
	end
	
	
	cells.update()
	hero.update()
	monster.update()
	talkers.update()
	darkness.update()
	floaters.update()

	wscores.update()

	gui.update()
	
--	if cells.next then
--		if game.count>0 then game.count=game.count-1 else
--			main.next=cells.next
--		end
--	end

end

game.draw=function()

	sheets.get(game.floor):draw(1,240,240,nil,480,480)

	cells.draw()
	hero.draw()
	monster.draw()
	talkers.draw()
	darkness.draw()

	floaters.draw()

	if hero.item>0 then
		local sheet=sheets.get("imgs/items")
		oven.gl.Color(1,1,1,1)
		sheet:draw(hero.item,480-24,24+16,nil,48,48)
	end
	
	do
		local x=480-80-48-16
		local y=8
		local s="L"..main.level.." "..hero.held.."/78"
		font.set(cake.fonts.get(1))
		font.set_size(16)
		oven.gl.Color(0,0,0,1)
		font.set_xy( x+2,y+2 )
		font.draw(s)
		oven.gl.Color(1,1,1,1)
		font.set_xy( x,y )
		font.draw(s)
	end
	
	wscores.draw("arcade2")

	gui.draw()

end

	return game
end
