-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require


local function print(...) _G.print(...) end

local wstr=require("wetgenes.string")
local pack=require("wetgenes.pack")

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M


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
	
print(act,w.id)
		
		if act=="click" then
			if w.id=="start" then

				wscores.set(0)
				main.level=0
				main.herospeed=0
				main.next=oven.rebake("dmazed.main_game")
			elseif w.id=="settings" then
				gui.spage("settings")
			elseif w.id=="profiles" then
				gui.spage("profiles")
			end
		end
		
	end

	
	function gui.pages.menu(master)

		local top=master:add({hx=480,hy=480,mx=480,my=480,class="flow",ax=0,ay=0,font="Vera",text_size=24})

		top:add({sx=480,sy=360})
		
		top:add({sx=40,sy=40})
		top:add({sx=100,sy=40,color=0xffcccccc,text="Hello",style="indent"})
		top:add({sx=300,sy=40,color=0xffcccccc,text=wprofiles.get("name"),id="profiles",hooks=gui.hooks})
		top:add({sx=40,sy=40})

		top:add({sx=480,sy=20})

		top:add({sx=20,sy=40})
		top:add({sx=200,sy=40,color=0xffcccccc,text="Settings",id="settings",hooks=gui.hooks})
		top:add({sx=40,sy=40})
		top:add({sx=200,sy=40,color=0xffcccccc,text="Start",id="start",hooks=gui.hooks})
		top:add({sx=20,sy=40})

		top:add({sx=480,sy=20})
		
	end

	function gui.page(pname)
	
		gui.master:clean_all()
		
		if pname then
			local f=gui.pages[pname]
			if f then
				f(gui.master) -- pass in the master so we could fill up other widgets
			end
		end

		gui.master:layout()
		
	end

	function gui.spage(pname)
		sgui.page_hook=gui.page
		gui.page()
		sgui.page(pname)
	end
	

	function gui.clean()
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
