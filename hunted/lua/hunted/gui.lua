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
	

	local wscores=oven.rebake("wetgenes.gamecake.spew.scores")

	local beep=oven.rebake("hunted.beep")
	
	local main=oven.rebake("hunted.main")


	function gui.setup()
	
		gui.master=oven.rebake("wetgenes.gamecake.widgets").setup({})
	
		gui.page()
	end
	
	function gui.hooks(act,w)
	
--		print(act,w.id)
		
		if act=="click" then
			if w.id=="exit" then
				oven.next=true
			end
			if w.id=="start" then

				wscores.set(0)
				main.level=0
				main.next=oven.rebake("hunted.main_game")
			end
		end
		
	end

	
	function gui.pages.menu(master)

		local top=master:add({hx=480,hy=480,class="fill",ax=0,ay=0,font="Vera",text_size=24})


		top:add({hx=480,hy=400-40})
		
		top:add({hx=480,hy=40,color=0xffcccccc,text="Start",id="start",hooks=gui.hooks,solid=true})
		
		top:add({hx=480,hy=40})
		top:add({hx=100,hy=40,color=0xffffcccc,text="Exit",id="exit",hooks=gui.hooks,solid=true})
		top:add({hx=380,hy=40})
		
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
