-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require


local function print(...) _G.print(...) end

local wstr=require("wetgenes.string")
local pack=require("wetgenes.pack")

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

local brag="I just ate over {score} pixels dodging the bear in #DmazeD #PLAY #THE #GAME! https://play.google.com/store/apps/details?id=com.wetgenes.dmazed"


M.bake=function(oven,gui)

	gui=gui or {} 
	gui.modname=M.modname

	gui.pages={} -- put functions to fill in pages in here
	

	local sgui=oven.rebake("wetgenes.gamecake.spew.gui")
	
	local wprofiles=oven.rebake("wetgenes.gamecake.spew.profiles")
	local wsettings=oven.rebake("wetgenes.gamecake.spew.settings")

	local wscores=oven.rebake("wetgenes.gamecake.spew.scores")

	local beep=oven.rebake("dmazed.beep")
	
	local main=oven.rebake("dmazed.main")


	function gui.setup()
	
		gui.master=oven.rebake("wetgenes.gamecake.widgets").setup({})
	
		gui.page()
	end
	
	function gui.hooks(act,w)
	
--print(act,w.id)
		
		if act=="over" then sgui.anim.bounce(w,1/16) end

		if act=="click" then
			if w.id=="start" then

				wscores.set(0)
				main.level=0
				main.herospeed=0
				main.next=oven.rebake("dmazed.main_game")
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

		local top=master:add({hx=480,hy=480,class="fill",font="Vera",text_size=24})

		top:add({hx=480,hy=360})
		
		top:add({hx=40,hy=40})
		top:add({hx=100,hy=40,color=0xffcccccc,text="Hello",style="indent"})
		top:add({hx=300,hy=40,color=0xffcccccc,text=wprofiles.get("name"),id="profiles",hooks=gui.hooks,solid=true})
		top:add({hx=40,hy=40})

		top:add({hx=480,hy=20})

		top:add({hx=20,hy=40})
		top:add({hx=200,hy=40,color=0xffcccccc,text="Menu",id="menu",hooks=gui.hooks,solid=true})
		top:add({hx=40,hy=40})
		top:add({hx=200,hy=40,color=0xffcccccc,text="Start",id="start",hooks=gui.hooks,solid=true})
		top:add({hx=20,hy=40})

		top:add({hx=480,hy=20})
		
		master.go_back_id="menu"
		master.go_forward_id="start"
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

		gui.master:call_descendents(function(w) if w.hooks then return end sgui.anim.bounce(w,1) end)

		if gui.master.go_forward_id then
			gui.master.activate_by_id(gui.master.go_forward_id)
		end
		
		return ret
	end

	function gui.spage(pname)

		sgui.strings.brag=brag

		sgui.page_hook=gui.page
		gui.page("menu")
		sgui.page(pname)
	end
	

	function gui.clean()
		sgui.page_hook=nil
		gui.master=nil	
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
