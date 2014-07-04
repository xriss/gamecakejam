-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math

local function dprint(a) print(wstr.dump(a)) end

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,hud)
	local hud=hud or {}
	hud.oven=oven
	
	hud.modname=M.modname

	local cake=oven.cake
	local opts=oven.opts
	local canvas=cake.canvas
	local font=canvas.font
	local flat=canvas.flat
	local gl=oven.gl
	local sheets=cake.sheets
	
	
	local bikes=oven.rebake(oven.modgame..".bikes")
	local serv=oven.rebake(oven.modgame..".serv")

	local gui=oven.rebake(oven.modgame..".gui")
	local main=oven.rebake(oven.modgame..".main")
--	local beep=oven.rebake(oven.modgame..".beep")


hud.loads=function()

end

		
hud.setup=function()

	hud.loads()
	
	hud.time=60*60*2

end


hud.clean=function()

end


hud.msg=function(m)
	
end


hud.update=function()

	hud.time=hud.time-1
	if hud.time<0 then
		hud.time=0 
		main.next=oven.rebake(oven.modgame..".main_menu")
	end

	if bikes.list then

		hud.avatars={}
		for i,bike in ipairs(bikes.list) do
			if bike.player then -- only care to display real players
				local avatar={}
				hud.avatars[#hud.avatars+1]=avatar
				
				avatar.draw_index=bike.avatar.draw_index -- what to draw
				
				avatar.score=bike.score
				avatar.px=bike.px/16384
			end
		end

		table.sort(hud.avatars,function(a,b) return (a.score+a.px)<(b.score+b.px) end)

	end
	
end


hud.draw=function(step)

	if hud.avatars then
		local x=512 - (#hud.avatars*64/2)
		local y=32

		local ss=sheets.get("imgs/bikes")

		font.set(cake.fonts.get("Vera")) -- default font
		font.set_size(24,0)

		for i,v in ipairs(hud.avatars) do

			gl.Color(0,0,0,0.5)
			ss:draw(v.draw_index,x+4,y+4,0,64,64)

			gl.Color(1,1,1,1)
			ss:draw(v.draw_index,x,y,0,64,64)

			local s=tostring(v.score)
			local sw=font.width(s) -- how wide the string is

			font.set_xy(x-sw/2+1,y+32+1)
			gl.Color(0,0,0,1)
			font.draw(s)
			font.set_xy(x-sw/2-1,y+32-1)
			gl.Color(1,1,1,1)
			font.draw(s)
		
			x=x+64
		end
	end

	if hud.time and hud.time>0 then

	local s="Visit http://"..(serv.ip or "....").."/ to join!"
	local sw=font.width(s) -- how wide the string is

	local x=32
	local y=512-32
	font.set_xy(x+1,y+1)
	gl.Color(0,0,0,1)
	font.draw(s)
	font.set_xy(x-1,y-1)
	gl.Color(1,1,1,1)
	font.draw(s)

		font.set_size(48,0)

		local sc=math.floor(hud.time/60)
		local mn=math.floor(sc/60)
		sc=sc%60
		local s=string.format("%02d:%02d",mn,sc)
		local sw=font.width(s) -- how wide the string is

		local x=1024-32-sw
		local y=8
		font.set_xy(x+1,y+1)
		gl.Color(0,0,0,1)
		font.draw(s)
		font.set_xy(x-1,y-1)
		gl.Color(1,1,1,1)
		font.draw(s)
	end

end


	return hud
end
