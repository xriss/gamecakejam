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
	local sound=oven.rebake(oven.modgame..".play_sound")
	local parts=oven.rebake(oven.modgame..".play_parts")
	local lines=oven.rebake(oven.modgame..".play_lines")
	

play.loads=function()

end
		
play.setup=function()

	play.loads()
	
	screen.setup()
	sound.setup()
	parts.setup()
	lines.setup()

	play.reset(1)

end

play.clean=function()

	screen.clean()
	sound.clean()
	parts.clean()
	lines.clean()


end

play.msg=function(m)


	if m.class=="key" then
	
		if m.action==1 then
		
			if #m.keyname==2 and m.keyname:sub(1,1)=="f" then
			
				local n=m.keyname:sub(2,2):byte()-("0"):byte()
				
				main.mode=main.modes[n] or main.mode
				
				print("mode:"..main.mode)
			
			elseif m.keyname=="back" then
				main.inv=not main.inv -- color invert
			end
		
		end
	
	end
	
end

play.update=function()

	lines.update()

	local t=sound.update()
	play.newfft=play.newfft or t

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
	
--[[
	screen.draw_into_start(a)
	gl.ClearColor(1,0,0,1)
	gl.Clear(gl.COLOR_BUFFER_BIT+gl.DEPTH_BUFFER_BIT)
	screen.draw_into_stop(a)
]]

end

play.next_frame=function()
	play.frame_draw=play.frame_disp
	play.frame_disp=1+(play.frame_draw%2)
end


play.draw=function()

	local draw_black=function()
	
		screen.draw_feed(play.frame_disp,play.frame_draw,function()
			local p=gl.program("nudgel_blur")
			gl.UseProgram( p[0] )
			gl.Uniform4f( p:uniform("blur_step"), 0,1/512,0,0 )
			gl.Uniform1f( p:uniform("blur_fade"), 0/256 )
			return p
		end)	
		play.next_frame()
		
	end
	
	
	local draw_rgb=function()

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

	end
	
	local draw_dep=function(r,g,b,a)
	
		screen.draw_feed(play.frame_disp,play.frame_draw,function()
			local p=gl.program("nudgel_dep")
			gl.UseProgram( p[0] )

			gl.Uniform1i( p:uniform("tex0"), 0 )
			gl.Uniform1i( p:uniform("cam0"), 1 )
			gl.Uniform1i( p:uniform("cam1"), 2 )

			gl.Uniform4f( p:uniform("color"), r,g,b,a )
			
			gl.ActiveTexture(gl.TEXTURE2)
			gl.BindTexture(gl.TEXTURE_2D,screen.cams[1+(screen.cam_idx%2)])
			gl.ActiveTexture(gl.TEXTURE1)
			gl.BindTexture(gl.TEXTURE_2D,screen.cams[screen.cam_idx])
			gl.ActiveTexture(gl.TEXTURE0)

			return p
		end)	
		play.next_frame()

	end


	local draw_blur=function(fade)
		
		screen.draw_feed(play.frame_disp,play.frame_draw,function()
			local p=gl.program("nudgel_blur")
			gl.UseProgram( p[0] )
			gl.Uniform4f( p:uniform("blur_step"), 1/512,0,0,0 )
			gl.Uniform1f( p:uniform("blur_fade"), fade or 252/256 )
			return p
		end)	
		play.next_frame()

		screen.draw_feed(play.frame_disp,play.frame_draw,function()
			local p=gl.program("nudgel_blur")
			gl.UseProgram( p[0] )
			gl.Uniform4f( p:uniform("blur_step"), 0,1/512,0,0 )
			gl.Uniform1f( p:uniform("blur_fade"), fade or 252/256 )
			return p
		end)	
		play.next_frame()
	
	end
	
	local draw_parts=function()
	
		screen.draw_into_start(play.frame_draw)
		parts.draw( 1 , 1)  -- normal draw into current fbo
		screen.draw_into_stop(play.frame_draw)
		
	end

	local draw_lines=function(n)
	
		screen.draw_into_start(play.frame_draw)
		lines.draw(n)  -- normal draw into current fbo
		screen.draw_into_stop(play.frame_draw)

	end
	
	if main.mode=="rgb" then -- just show a rawcam feed
	
		draw_black()
		draw_rgb()

		gl.Color(1,1,1,1)
		screen.draw(play.frame_draw, main.flipx*main.flip*(854/2) , main.flip*(480/2)*1.2 , main.inv)
		
	elseif main.mode=="dep" then

		draw_black()
		draw_dep(1,1,1,1)

		gl.Color(1,1,1,1)
		screen.draw(play.frame_draw, main.flipx*main.flip*(854/2) , main.flip*(480/2)*1.2 , main.inv)

	elseif main.mode=="depblur" then

--		draw_black()
		draw_dep(1/16,1/16,1/16,1/16)
		draw_blur(1)

		gl.Color(1,1,1,1)
		screen.draw(play.frame_draw, main.flipx*main.flip*(854/2) , main.flip*(480/2)*1.2 , main.inv)

	elseif main.mode=="partdif" then

		parts.update("nudgel_parts_step_dif")

		draw_parts()
		draw_blur()

		gl.Color(1,1,1,1)
		screen.draw(play.frame_draw, main.flipx*main.flip*(854/2) , main.flip*(480/2)*1.2 , main.inv)

	elseif main.mode=="partfft" then

		parts.update("nudgel_parts_step")

		draw_parts()
		draw_blur()
		
		gl.Color(1,1,1,1)
		screen.draw(play.frame_draw, main.flipx*main.flip*(854/2) , main.flip*(480/2)*1.2 , main.inv)

	elseif main.mode=="line" then

--		draw_black()
		draw_blur((256-6)/256)
		draw_lines()
		
		gl.Color(1,1,1,1)
		screen.draw(play.frame_draw, main.flipx*main.flip*(854/2) , main.flip*(480/2)*1.2 , main.inv)

	elseif main.mode=="line2" then

--		draw_black()
		draw_blur((256-6)/256)
		draw_lines(2)
		
		gl.Color(1,1,1,1)
		screen.draw(play.frame_draw, main.flipx*main.flip*(854/2) , main.flip*(480/2)*1.2 , main.inv)

	elseif main.mode=="sound" then

--		draw_black()
--		draw_blur((256-6)/256)
--		draw_lines(2)
		
		gl.Color(1,1,1,1)
		sound.draw_fft(play.frame_draw, main.flipx*main.flip*(854/2) , main.flip*(480/2)*1.2 , main.inv)

	end
	
end

	return play
end
