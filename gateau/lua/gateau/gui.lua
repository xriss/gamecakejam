-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require


local function print(...) _G.print(...) end

local wwin=require("wetgenes.win") -- system independent helpers
local wstr=require("wetgenes.string")
local pack=require("wetgenes.pack")
local ls=function(it) print(wstr.dump(it)) end
--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

local brag="I just scored over {score} points in #gateau #PLAY #THE #GAME! http://play.4lfa.com/gamecake"


M.bake=function(oven,gui)

	gui=gui or {} 
	gui.modname=M.modname

	gui.pages={} -- put functions to fill in pages in here
	
	local cake=oven.cake
	local sheets=cake.sheets
	local canvas=cake.canvas
	local font=canvas.font


	local sgui=oven.rebake("wetgenes.gamecake.spew.gui")
	local sprofiles=oven.rebake("wetgenes.gamecake.spew.profiles")
	local ssettings=oven.rebake("wetgenes.gamecake.spew.settings")
	local sscores=oven.rebake("wetgenes.gamecake.spew.scores")

--	local beep=oven.rebake(oven.modgame..".beep")
	local main=oven.rebake(oven.modgame..".main")
	local launch=oven.rebake(oven.modgame..".launch")
	
	gui.master=oven.rebake("wetgenes.gamecake.widgets").setup({})

	function gui.setup()
		sgui.setup()
		gui.page()
	end
	
	gui.hook_over={}
	gui.hook_click={}
	
	function gui.hooks(act,w)
	
--print(act,w.id)

		if act=="over" then sgui.anim.bounce(w,1/16) end
		
--print( "hook_"..tostring(act) )

		if w.id and act and gui["hook_"..act] then
			local f=gui["hook_"..act][w.id]
			if f then
				return f(w)
			end
		end
			
		if act=="over" then
		elseif act=="click" then
			if w.id=="start" then
				sscores.set(0)
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

		local top=master:add({hx=768,hy=432,class="fill",font="Vera",text_size=16})
		
		
		local butsiz=128
		local butpad=8
		local butwid=math.floor( (768-butpad) / (butsiz+butpad) )
		local buthid=math.floor( (432-butpad) / (butsiz+butpad) )
		
		local butxp=math.floor(( (768-butpad) - ( (butsiz+butpad)*butwid ) )/2)
		local butyp=math.floor(( (432-butpad) - ( (butsiz+butpad)*buthid ) )/2)

print(butxp,butyp,butwid,buthid)

local line
local datfill=function(w,v)
	local tt=v.title
	local hx=butsiz
	local hy=25
	local px=0
	local py=0
	local fy=w:bubble("text_size") or 12
	local fyp=1
	local f=w:bubble("font") or 1

	font.set(cake.fonts.get(f))
	font.set_size(fy,0)

	local lines=font.wrap(tt,{w=w.hx}) -- break into lines
	py=butsiz-(#lines*(fy+fyp))-8
	w:add({px=0-2,py=py-2,hx=hx+4,hy=butsiz-py+4,color=0xcc000000})
	for i=1,#lines do
		w:add({px=0,py=py,hx=hx,hy=hy,text_color=0xffffffff,text=lines[i]})
		py=py+fy+fyp
	end
end
gui.master.go_forward_id=nil

	top:add({hx=768,hy=butyp})

for i,v in ipairs(main.list) do
	if not gui.master.go_forward_id then
		gui.master.go_forward_id="gateau_"..v.id
	end
	if (i-1)%butwid==0 then
		top:add({hx=768,hy=butpad})
		line=top:add({hx=768,hy=butsiz,class="fill"})
		line:add({hx=butxp,hy=butsiz})
	end
	line:add({hx=butpad,hy=butsiz})
	local w=line:add({solid=true,hx=butsiz,hy=butsiz,color=0xffcccccc,sheet="gateau/"..v.id.."/icon",sheet_px=butsiz/2,sheet_py=butsiz/2,id="gateau_"..v.id,hooks=gui.hooks,user=v})
	datfill(w,v)

	gui.hook_over[w.id]=function(w)
		top.sheet="gateau/"..w.user.id.."/screen"
		local sh=sheets.get(top.sheet)
		top.sheet_px=768/2
		top.sheet_py=432/2
		top.sheet_hx=(sh.img.width/sh.img.height)*432 -- cover 432 high
		top.sheet_hy=432
		if top.sheet_hx < 768 then -- else cover 768 wide
			top.sheet_hx=768
			top.sheet_hy=(sh.img.height/sh.img.width)*768
		end
		top.sheet_hx=top.sheet_hx*1.25 -- then scaleup 
		top.sheet_hy=top.sheet_hy*1.25

		top.color=0x88888888
--			print("OVER->"..w.id)
	end

	gui.hook_click[w.id]=function(w)
		launch.run(w.user.id)
		oven.next=true -- exit
	end
end

	line:add({hx=butpad,hy=butsiz})


		
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
