-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math

local function dprint(a) print(wstr.dump(a)) end

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,play)
	local play=play or {}
	play.oven=oven
	
	play.modname=M.modname

	local cake=oven.cake
	local opts=oven.opts
	local canvas=cake.canvas
	local font=canvas.font
	local flat=canvas.flat
	local gl=oven.gl
	local sheets=cake.sheets
	
--	local sgui=oven.rebake("wetgenes.gamecake.spew.gui")

--	local gui=oven.rebake(oven.modgame..".gui")
	local main=oven.rebake(oven.modgame..".main")
--	local beep=oven.rebake(oven.modgame..".beep")

--	local sscores=oven.rebake("wetgenes.gamecake.spew.scores")
--	local srecaps=oven.rebake("wetgenes.gamecake.spew.recaps")

	local screen=oven.rebake(oven.modgame..".play_screen")
	
play.back="imgs/title"

play.loads=function()

end
		
play.setup=function()

	play.loads()
	
	screen.setup()

	play.reset(1)

end

play.clean=function()

	screen.clean()


end

play.msg=function(m)

--	print(wstr.dump(m))

	
end

play.update=function()

	local t=screen.update()
	play.newcam=play.newcam or t
end

play.frame_draw=0
play.frame_disp=0
play.reset=function(a)

	for i=1,2 do
		screen.draw_into_start(i)
		gl.ClearColor(0,0,0,1)
		gl.Clear(gl.COLOR_BUFFER_BIT+gl.DEPTH_BUFFER_BIT)
		screen.draw_into_stop(i)
	end
	
	play.frame_draw=a
	play.frame_disp=1+(a%2)
	
	screen.draw_into_start(a)
	gl.ClearColor(1,0,0,1)
	gl.Clear(gl.COLOR_BUFFER_BIT+gl.DEPTH_BUFFER_BIT)
	screen.draw_into_stop(a)

end

play.next_frame=function()
	play.frame_draw=play.frame_disp
	play.frame_disp=1+(play.frame_draw%2)
end


play.draw=function()

	if main.cam=="raw" then -- just show a rawcam feed
	
		screen.draw_feed(play.frame_disp,play.frame_draw,function()
			local p=gl.program("nudgel_rawcam")
			gl.UseProgram( p[0] )

			gl.Uniform1i( p:uniform("tex0"), 0 )
			gl.Uniform1i( p:uniform("cam0"), 1 )

			gl.ActiveTexture(gl.TEXTURE1)
			gl.BindTexture(gl.TEXTURE_2D,screen.cams[screen.cam_idx])
			gl.ActiveTexture(gl.TEXTURE0)

			return p
		end)	
		play.next_frame()
			
		screen.draw(play.frame_draw, (854/2) , -(480/2)*1.2 )
	
		return
	end
	


	
	screen.draw_into_start(play.frame_draw)
--	font.set("Vera") -- 32 pixels high
	font.set_size(32,0) -- 32 pixels high

	if math.random(100)<10 then
		local cs={
			{1,0,0,1},
			{0,1,0,1},
			{0,0,1,1},
			{1,1,0,1},
			{1,0,1,1},
			{0,1,1,1},
--			{1,1,1,1},
		}
		local c=cs[math.random(#cs)]
		gl.Color(c[1],c[2],c[3],c[4])
		local t=wstr.split_whitespace("Art gallery and performance space in Bradford (UK) hosting exhibitions, concerts, film screenings and other events")
		local s=(t[math.random(#t)])
		font.set_xy(256+(math.random(32)-16)-(font.width(s)/2),256+(math.random(32)-16)-16) -- 32 pixels high
		font.draw(s)

	end
	
	screen.draw_into_stop(play.frame_draw)

	gl.Color(1,1,1,1)


--	if play.newcam then
--		play.newcam=false
--	if math.random(100)<10 then
		screen.draw_feed(play.frame_disp,play.frame_draw,function()
			local p=gl.program("nudgel_cam")
			gl.UseProgram( p[0] )
			
			gl.Uniform1i( p:uniform("tex0"), 0 )
			gl.Uniform1i( p:uniform("cam0"), 1 )

			gl.ActiveTexture(gl.TEXTURE1)
			gl.BindTexture(gl.TEXTURE_2D,screen.cams[screen.cam_idx])

			gl.ActiveTexture(gl.TEXTURE0)

			return p
		end)
		play.next_frame()
--	end
--	end

--[[
	screen.draw_feed(play.frame_disp,play.frame_draw,function()
		local p=gl.program("nudgel_dark")
		gl.UseProgram( p[0] )
		return p
	end)
	play.next_frame()
]]

	screen.draw_feed(play.frame_disp,play.frame_draw,function()
		local p=gl.program("nudgel_test")
		gl.UseProgram( p[0] )
		local cc={(math.random(128)-64)/64,(math.random(128)-64)/64}
		cc[1]=0.5+cc[1]/32
		cc[2]=0.5+cc[2]/32
		gl.Uniform4f( p:uniform("center"), cc[1],cc[2],cc[1],cc[2] )
		gl.Uniform4f( p:uniform("distort"), 0.25,0.25,1.0,0.03 )
--		gl.Uniform4f( p:uniform("distort"), 1,0.25,1.0,0.03 )
		return p
	end)	
	play.next_frame()
		
--	screen.draw(play.frame_draw,(854/2)/256)
	screen.draw(play.frame_draw, (854/2) , -(480/2)*1.2 )
	



end

	return play
end
