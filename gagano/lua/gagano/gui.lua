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

	function gui.setup()
	
		gui.master=oven.rebake("wetgenes.gamecake.widgets").setup({})
	
		gui.page("menu")
	end
	
	gui.hooks=function(act,widget)
			
		local id=widget and widget.id
		
		if act=="click" then
			if id=="start" then
				oven.game.next=oven.rebake("gagano.game_play")
			end
		end
	
	end
	
	function gui.pages.play(master)

--		local top=master:add({hx=720,hy=480,mx=720,my=480,class="flow",ax=0,ay=0,font="Vera",text_size=24})
--		top:add({sy=440,sx=720})
		
	end
	
	function gui.pages.menu(master)

		local top=master:add({hx=720,hy=480,mx=720,my=480,class="flow",ax=0,ay=0,font="Vera",text_size=16})
		top:add({sy=440,sx=720})
		local bot=top:add({sy=40,sx=720,mx=720,class="flow"})
		bot:add({sy=40,sx=200})
		bot:add({sx=200,sy=40,color=0xffffffff,text="Start!",id="start",hooks=gui.hooks})
		bot:add({sy=40,sx=200})
		
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
