-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math


--module
local M={ modname=(...) } ; package.loaded[M.modname]=M


M.bake=function(oven,main)
	main=main or {}
	main.modname=M.modname

	oven.modgame="macrl"

	
	local gl=oven.gl
	local cake=oven.cake
	local opts=oven.opts
	local canvas=cake.canvas
	local font=canvas.font
	local flat=canvas.flat
	
	local view=cake.views.create({
		parent=cake.views.get(),
		mode="full",
		vx=opts.width,
		vy=opts.height,
		vz=opts.height*4,
		fov=0,
	})

	local skeys=oven.rebake("wetgenes.gamecake.spew.keys").setup(1)
	local srecaps=oven.rebake("wetgenes.gamecake.spew.recaps").setup(1)
	local sscores=oven.rebake("wetgenes.gamecake.spew.scores").setup(1)


print("yarn setup")
	main.basket=require("yarn.basket").bake({oven=oven})
	main.basket.modgame=oven.modgame
	main.basket.rebake(oven.modgame..".rules.code").setup()


--	main.page="menu"
--	main.wait=60
	
main.loads=function()

	cake.fonts.loads({1,"Vera"}) -- load 1st builtin font, a basic 8x8 font
	
	cake.sheets.loads_and_chops{
		{"imgs/tiles",8/128,8/128,4/128,4/128,1/128,1/128},
	}
	cake.sheets.loads_and_chops{
		{"imgs/tiles.6x6",8/128,8/128,4/128,4/128,1/128,1/128},
	}
	cake.sheets.loads_and_chops{
		{"imgs/title",1,1,1/2,1/2},
	}
	
end
		
main.setup=function()

	main.loads()
	
	main.last=nil
	main.now=nil
	main.next=nil
	
	main.next=oven.rebake(oven.modgame..".main_menu")

	for i,v in ipairs(opts) do
		if type(v)=="string" then
			if v=="game" then
				main.next=oven.rebake(oven.modgame..".main_game")
			end
		end
	end
	
	main.change()
end

function main.change()

-- handle state changes

	if main.next then
	
		if main.now and main.now.clean then
			main.now.clean()
		end
		
		main.last=main.now
		main.now=main.next
		main.next=nil
		
		if main.now and main.now.setup then
			main.now.setup()
		end
		
	end
	
end		

main.clean=function()

	if main.now and main.now.clean then
		main.now.clean()
	end

end

main.swipe={fx=0,fy=0,dx=0,dy=0,on=false}

-- turn mouse swipes and taps into fake keys
main.swipekeys=function(m)

--print(wstr.dump(m))

	if m.class=="mouse" then
		local sw=main.swipe
		
		local sensitivity=16 -- should factor in DPI...
		
		local function unkey()
			if sw.last then
				sw.last=nil
				main.msg{
					class="key",
					action=-1,
					keyname=sw.last,
				}
			end
		end
		local function dokey(n)
			unkey()
			sw.last=n
			main.msg{
				class="key",
				action=1,
				keyname=sw.last,
			}
		end

		if m.action==1 then -- remember first touch point for swipe
			sw.fx=m.x
			sw.fy=m.y
			sw.dx=m.x -- keep track of swipe movements
			sw.dy=m.y
			sw.on=true
		end
		
		local swiped=false
		if sw.on then
			
			local dx=m.x-sw.dx
			local dy=m.y-sw.dy
			
			if dx*dx > dy*dy then -- check x
				if dx<-sensitivity then
					dokey("left")
					swiped=true
				elseif dx>sensitivity then
					dokey("right")
					swiped=true
				end
			else -- check y
				if dy<-sensitivity then
					dokey("up")
					swiped=true
				elseif dy>sensitivity then
					dokey("down")
					swiped=true
				end
			end
		end
		
		if swiped then
			sw.fx=nil
			sw.fy=nil
			sw.dx=m.x -- keep track of swipe movement chunks
			sw.dy=m.y
		end

		if m.action==-1 then -- was this a click? check if sw.fx
			if sw.fx then -- no movement, so it was a click
				dokey("enter")
			else
				unkey()
			end
			sw.on=false
		end
		
	
	end


end


main.msg=function(m)
--	print(wstr.dump(m))

	view.msg(m) -- fix mouse coords

--	if skeys.msg(m) then m.skeys=true end -- flag this msg as handled by skeys

	if main.now and main.now.msg then
		main.now.msg(m)
	end

	
end

main.update=function()

	main.change()

--	srecaps.step()
	
	if main.now and main.now.update then
		main.now.update()
	end

end

main.draw=function()
	
	cake.views.push_and_apply(view)
	canvas.gl_default() -- reset gl state
		
	gl.ClearColor(pack.argb4_pmf4(0xf000))
	gl.Clear(gl.COLOR_BUFFER_BIT+gl.DEPTH_BUFFER_BIT)

	gl.PushMatrix()
	
	font.set(cake.fonts.get(1)) -- default font
	font.set_size(32,0) -- 32 pixels high

	if main.now and main.now.draw then
		main.now.draw()
	end
	
	gl.PopMatrix()
	
	cake.views.pop_and_apply()

end
		
	return main
end

