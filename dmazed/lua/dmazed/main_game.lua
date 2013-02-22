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

	local wscores=oven.rebake("wetgenes.gamecake.spew.scores")

	local recaps=oven.rebake("wetgenes.gamecake.spew.recaps")


game.loads=function()

end
		
game.setup=function()

	game.count=100

	main.level=main.level+1
	
	game.loads()

	gui.setup()
	gui.page("game")
	
	cells.setup()
	hero.setup()

	beep.play("start")

end

game.clean=function()

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


	if recaps.get("up") then
		hero.move="up"
	elseif recaps.get("down") then
		hero.move="down"
	elseif recaps.get("left") then
		hero.move="left"
	elseif recaps.get("right") then
		hero.move="right"
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
					acc()
				else
					hero.move="left"
					acc()
				end
			else
				if y>=0 then
					hero.move="down"
					acc()
				else
					hero.move="up"
					acc()
				end
			end
		end
	else
		hero.move=nil
	end
	
	
	cells.update()
	hero.update()

	wscores.update()

	gui.update()
	
--	if cells.next then
--		if game.count>0 then game.count=game.count-1 else
--			main.next=cells.next
--		end
--	end

end

game.draw=function()

	sheets.get("imgs/floor"):draw(1,240,240,nil,480,480)

	cells.draw()
	hero.draw()

	wscores.draw("arcade2")

	gui.draw()

end

	return game
end
