-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require


local function print(...) _G.print(...) end

local wstr=require("wetgenes.string")
local pack=require("wetgenes.pack")

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

local brag="I just scored over {score} points in #lonelybird #PLAY #THE #GAME! http://play.4lfa.com/gamecake"


M.bake=function(oven,gui)

	gui=gui or {} 
	gui.modname=M.modname

	gui.pages={} -- put functions to fill in pages in here
	

	local sgui=oven.rebake("wetgenes.gamecake.spew.gui")
	local sprofiles=oven.rebake("wetgenes.gamecake.spew.profiles")
	local ssettings=oven.rebake("wetgenes.gamecake.spew.settings")
	local sscores=oven.rebake("wetgenes.gamecake.spew.scores")

	local beep=oven.rebake(oven.modgame..".beep")
	local main=oven.rebake(oven.modgame..".main")


	gui.master=oven.rebake("wetgenes.gamecake.widgets").setup({})

	function gui.setup()
		sgui.setup()
		gui.page()
	end
	
	function gui.hooks(act,w)
	
print(act,w.id)
		
		if act=="over" then sgui.anim.bounce(w,1/16) end


		if act=="click" then
			if w.id=="start" then
				sscores.set(0)
				main.next=oven.rebake(oven.modgame..".main_game")
				beep.play("click")
			elseif w.id=="menu" then
				gui.spage("settings")
				beep.play("click")
			elseif w.id=="profiles" then
				gui.spage("profiles")
				beep.play("click")
			end
		end
		
	end

	
	function gui.pages.settings_game(master)
		gui.pages.menu(master)
	end
	
	function gui.pages.menu(master)

		local top=master:add({hx=512,hy=512,class="fill",font="awesome",text_size=36})


		top:add({hx=512,hy=512-160})


		top:add({hx=(512-220)/2,hy=60})
		top:add({hx=220,hy=60,color=0xff1E90FF,text="Menu",text_color=0xffffffff,color_over=0xff6BB6FF,id="menu",hooks=gui.hooks})
		top:add({hx=(512-220)/2,hy=60})

		top:add({hx=512,hy=10})
		
--[[
		top:add({hx=40,hy=40})
		top:add({hx=180,hy=40,color=0xffcccccc,text="Hello",style="indent"})
		top:add({hx=380,hy=40,color=0xffcccccc,text=sprofiles.get("name"),id="profiles",hooks=gui.hooks})
		top:add({hx=40,hy=40})

		top:add({hx=512,hy=20})
]]

		top:add({hx=(512-220)/2,hy=60})
		top:add({hx=220,hy=60,color=0xffff0000,text="Start",text_color=0xffffffff,color_over=0xffFF009D,id="start",hooks=gui.hooks})
		top:add({hx=(512-220)/2,hy=60})

--		top:add({hx=512,hy=20})

		master.go_back_id="start"
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
		
		gui.master:call_descendents(function(w) if not w.hooks then return end sgui.anim.bounce(w,1) end)

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
