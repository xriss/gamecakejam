-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require


local function print(...) _G.print(...) end

local wstr=require("wetgenes.string")
local pack=require("wetgenes.pack")

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

local brag="I just scored over {score} points in #gthang #PLAY #THE #GAME! http://play.4lfa.com/gamecake"


M.bake=function(oven,gui)

	gui=gui or {} 
	gui.modname=M.modname

	gui.pages={} -- put functions to fill in pages in here
	

	local sgui=oven.rebake("wetgenes.gamecake.spew.gui")
	local sprofiles=oven.rebake("wetgenes.gamecake.spew.profiles")
	local ssettings=oven.rebake("wetgenes.gamecake.spew.settings")

--	local beep=oven.rebake(oven.modgame..".beep")
	local main=oven.rebake(oven.modgame..".main")
	local hud=oven.rebake(oven.modgame..".hud")
	
	local about=oven.rebake("wetgenes.gamecake.spew.about.sinescroll")

	about.title="Gthang : Ain't nothin' but a"
	about.text=[[
*SKIP*
shi made this arrr arrr
*SKIP*
what you have in your hands is an experiment in lua learning and using the gamecake engine to make my first game.
*SKIP*
i like shmups and hopefully, after playing this one, so can you!
*SKIP*
there's a bit of juggling action that can happen during the game.
*SKIP*
there's also complex interaction but very simple controls. hopefully, you can figure it out yourself.
*SKIP*
oh yea, why is it called gthang? well, because of galaga, galaxian and gaplus of course. also, galactic dancing.
*SKIP*
Original Theme music brought to you by the ever lovely and super talented, Joshua Layton
*SKIP*
]]


	gui.master=oven.rebake("wetgenes.gamecake.widgets").setup({})

	function gui.setup()
		sgui.setup()
		gui.page()
	end
	
	function gui.hooks(act,w)
	
print(act,w.id)
		
		if act=="click" then
			if w.id=="start" then
				hud.reset()
				main.next=oven.rebake(oven.modgame..".main_game")
			elseif w.id=="menu" then
				gui.spage("settings")
			elseif w.id=="profiles" then
				gui.spage("profiles")
			end
		end
		
	end

	
	function gui.pages.settings_game(master)
		gui.pages.menu(master)
	end
	
	function gui.pages.menu(master)

		local top=master:add({hx=512,hy=768,class="fill",font="Akashi",text_size=24})

		top:add({hx=512,hy=568})
		
--		top:add({hx=6,hy=40})
--		top:add({hx=150,hy=40,color=0xffcccccc,text="Hello",style="indent"})
--		top:add({hx=350,hy=40,color=0xffcccccc,text=sprofiles.get("name"),id="profiles",hooks=gui.hooks})
--		top:add({hx=6,hy=40})

--		top:add({hx=512,hy=20})

		top:add({hx=156,hy=40})
		top:add({hx=200,hy=40,color=0xff000000,text="MENU",text_color=0xff00ffff,text_color_over=0xffff00ff,id="menu",hooks=gui.hooks})
		top:add({hx=156,hy=40})

		top:add({hx=512,hy=20})
		
		top:add({hx=156,hy=40})
		top:add({hx=200,hy=40,color=0xff000000,text="START",text_color=0xff00ffff,text_color_over=0xffff00ff,id="start",hooks=gui.hooks})
		top:add({hx=156,hy=40})

		top:add({hx=512,hy=20})
		
	end

	function gui.page(pname)
		local ret=false

		gui.master:clean_all()
		
		if pname then
			local f=gui.pages[pname]
			if f then
				f(gui.master) -- pass in the master so we could fill up other widgets
				ret=true
			end
		end

		gui.master:layout()
		
		return ret
	end

	function gui.spage(pname)

		sgui.strings.brag=brag

		sgui.page_hook=gui.page
		gui.page("menu")
		sgui.page(pname)
	end
	

	function gui.clean()
--		sgui.page_hook=nil
--		gui.master=nil
	end
	
	function gui.update()
		gui.master:update()
	end
	
	function gui.msg(m)
		gui.master:msg(m)
	end

	function gui.draw()
		gui.master:draw()		
	end
	
	return gui
end
