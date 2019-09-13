-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math

local function dprint(a) print(wstr.dump(a)) end

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,intermission)
	local intermission=intermission or {}
	intermission.oven=oven
	
	intermission.modname=M.modname

	local cake=oven.cake
	local opts=oven.opts
	local canvas=cake.canvas
	local font=canvas.font
	local flat=canvas.flat
	local gl=oven.gl
	local sheets=cake.sheets
	
	local wgui=oven.rebake("wetgenes.gamecake.spew.gui")

	local gui=oven.rebake("dmazed.gui")
	local main=oven.rebake("dmazed.main")
	local beep=oven.rebake("dmazed.beep")

	local wscores=oven.rebake("wetgenes.gamecake.spew.scores")

	local recaps=oven.rebake("wetgenes.gamecake.spew.recaps")


	local display_insert=function(d)
		d.idx=idx
		if d.name then intermission.display[d.name]=d end
		intermission.display[d]=d
		if d.init then d.init(d) end
		return d
	end

	local display_remove=function(d)
		if d.name then intermission.display[d.name]=nil end
		intermission.display[d]=nil
		return d
	end

	local display_get=function(d)
		return intermission.display[d]
	end



intermission.loads=function()

end
		
intermission.setup=function()

	intermission.loads()

	beep.stream("intermission")

-- reset
	intermission.display={
	}

	local base_init=function(d)
		d.px=240
		d.py=240
		d.vx=0
		d.vy=0
		d.frame=1
		d.rotate=0
		d.size=64
		d.framebase=1
	end
	local base_update=function(d)
		d.px=d.px+d.vx
		d.py=d.py+d.vy
		local f=math.floor(d.px/(d.size/4))%4
		if     f==0 then f=1
		elseif f==1 then f=0
		elseif f==2 then f=2
		elseif f==3 then f=0
		end
		d.frame=d.framebase+f
	end
	local base_draw=function(d)
		if d.sheet then
			d.sheet:draw(d.frame,d.px,d.py,d.rotate,d.size,d.size)
		end
	end

	display_insert{
		name="hero",
		init=function(d)
			base_init(d)
			d.sheet=sheets.get("imgs/pilu")
		end,
		update=function(d)
			base_update(d)
		end,
		draw=function(d)
			base_draw(d)
		end,
	}

	display_insert{
		name="bear",
		init=function(d)
			base_init(d)
			d.sheet=sheets.get("imgs/bear")
		end,
		update=function(d)
			base_update(d)
		end,
		draw=function(d)
			base_draw(d)
		end,
	}


	local anim=(math.floor(main.level/4)-1)%2
	if anim<0 then anim=0 end
--	anim=1
	
--setup main
	display_insert{
		name="main",
		init=function(d)
			local hero=display_get("hero")
			local bear=display_get("bear")
			
			if anim==0 then
			
				hero.px=480+64
				bear.px=480+64+360

				hero.vx=-2
				bear.vx=-3
				
				hero.size=64
				bear.size=128
				bear.py=bear.py-32
				
				hero.framebase=1+3+3+3
				bear.framebase=1+3+3+3

				
			elseif anim==1 then
			
				hero.px=-64-360
				bear.px=-64

				hero.vx=3
				bear.vx=2
				
				hero.size=128
				bear.size=64
				hero.py=hero.py-32
				
				hero.framebase=1+3+3
				bear.framebase=1+3+3
				
			end

		end,
		update=function(d)
		
			local hero=display_get("hero")
			local bear=display_get("bear")
			
			hero:update()
			bear:update()

			if anim==0 then
				if bear.px<-64 then intermission.done=true end
			elseif anim==1 then
				if hero.px>480+64 then intermission.done=true end
			end

		end,
		draw=function(d)
		
			display_get("hero"):draw()
			display_get("bear"):draw()
		end,
	}

	intermission.done=false
	
end

intermission.clean=function()

end


intermission.msg=function(m)

--	print(wstr.dump(m))
	
end

intermission.update=function()

	local m=display_get("main")
	if m then
		if m.update then m.update(m) end
	end
	
	if intermission.done then
		main.next=oven.rebake("dmazed.main_game")
	end
end

intermission.draw=function()

--	layout.viewport()
	
--	sheets.get(intermission.back):draw(1,240,240,nil,480,480)
	
	wscores.draw("arcade2")


	local m=display_get("main")
	if m then
		if m.draw then m.draw(m) end
	end

	local x=240
	local y=60
	local s="INTERMISSION"
	font.set(cake.fonts.get("Vera"))
	font.set_size(24)
	local w=font.width(s)
	oven.gl.Color(1,1,1,1)
	font.set_xy( x-(w/2),y )
	font.draw(s)
	
end

	return intermission
end
