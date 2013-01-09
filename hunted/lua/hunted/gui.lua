-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require


local function print(...) _G.print(...) end

local wstr=require("wetgenes.string")
local pack=require("wetgenes.pack")

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M


M.bake=function(state,gui)

	gui=gui or {} 
	gui.modname=M.modname

	gui.pages={} -- put functions to fill in pages in here
	
	
	local main=state.rebake("hunted.main")

	function gui.setup()
	
		gui.master=state.rebake("wetgenes.gamecake.widgets").setup({})
	
		gui.page()
	end
	
	function gui.hooks(act,w)
	
		print(act,w.id)
		
		if act=="click" then
			if w.id=="start" then
				main.next=state.rebake("hunted.main_game")
			end
		end
		
	end

	
	function gui.pages.menu(master)

		local top=master:add({hx=480,hy=480,mx=480,my=480,class="flow",ax=0,ay=0,font="Vera",text_size=24})

		top:add({sx=480,sy=400})
		
		top:add({sx=480,sy=40,color=0xffcccccc,text="Start",id="start",hooks=gui.hooks})
		
		top:add({sx=480,sy=40})
		
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
