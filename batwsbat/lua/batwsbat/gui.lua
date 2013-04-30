-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require


local function print(...) _G.print(...) end

local wstr=require("wetgenes.string")
local pack=require("wetgenes.pack")

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

local brag="I just scored over {score} points in #batwsbat #PLAY #THE #GAME! http://play.4lfa.com/gamecake"


M.bake=function(oven,gui)

	gui=gui or {} 
	gui.modname=M.modname

	gui.pages={} -- put functions to fill in pages in here
	
	local wdata=oven.rebake("wetgenes.gamecake.widgets.data")


	local sgui=oven.rebake("wetgenes.gamecake.spew.gui")
	local sprofiles=oven.rebake("wetgenes.gamecake.spew.profiles")
	local ssettings=oven.rebake("wetgenes.gamecake.spew.settings")
	local sscores=oven.rebake("wetgenes.gamecake.spew.scores")

--	local beep=oven.rebake(oven.modgame..".beep")
	local main=oven.rebake(oven.modgame..".main")
	local game=oven.rebake(oven.modgame..".main_game")
	
	gui.data={}

	gui.master=oven.rebake("wetgenes.gamecake.widgets").setup({hx=640,hy=480})

	function gui.setup()
	
--		gui.master=oven.rebake("wetgenes.gamecake.widgets").setup({})
	
		gui.page()
	end
	
	function gui.hooks(act,w)
	
--print(act,w.id)

		if act=="value" then
			if w.id=="handicap" then
				game.setup()
			end
		end
		
		if act=="click" then
			if w.id=="start" then
				sscores.set(0,1)
				sscores.set(0,2)
				main.next=game
			elseif w.id=="menu" then
				gui.spage("settings")
			elseif w.id=="profiles" then
				gui.spage("profiles")
			end
		end
		
	end

	function gui.initdata() -- call this later
		gui.data.handicap=wdata.new_data({id="handicap",class="number",hooks=gui.hooks,num=0,min=-5,max=5,step=1})
	end

	
	function gui.pages.settings_game(master)
		gui.pages.menu(master)
	end
	
	function gui.pages.menu(master)

		local top=master:add({hx=640,hy=480,class="fill",font="Vera",text_size=24})

		top:add({hx=640,hy=320})
		top:add({hx=640,hy=40})


--		top:add({hx=640,hy=40,text="Handicap",text_color=0xffffffff})
		top:add({hx=160,hy=40})
		top:add({class="slide",color=0xffcccccc,hx=320,hy=40,datx=gui.data.handicap,data=gui.data.handicap,hooks=gui.hooks})
		top:add({hx=160,hy=40})

--[[
		top:add({hx=40,hy=40})
		top:add({hx=180,hy=40,color=0xffcccccc,text="Hello",style="indent"})
		top:add({hx=380,hy=40,color=0xffcccccc,text=sprofiles.get("name"),id="profiles",hooks=gui.hooks})
		top:add({hx=40,hy=40})
]]
		top:add({hx=640,hy=20})

		top:add({hx=150,hy=40})
		top:add({hx=150,hy=40,color=0xffcccccc,text="Menu",id="menu",hooks=gui.hooks})
		top:add({hx=40,hy=40})
		top:add({hx=150,hy=40,color=0xffcccccc,text="Start",id="start",hooks=gui.hooks})
		top:add({hx=150,hy=40})

		top:add({hx=640,hy=20})
		
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
	
	gui.initdata()
	
	return gui
end
