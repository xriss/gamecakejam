-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math
local wv4l2=require("wetgenes.v4l2")
local wgrd=require("wetgenes.grd")

local function dprint(a) print(wstr.dump(a)) end

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,screen)
	local screen=screen or {}
	screen.oven=oven
	
	screen.modname=M.modname

	local cake=oven.cake
	local opts=oven.opts
	local canvas=cake.canvas
	local font=canvas.font
	local flat=canvas.flat
	local gl=oven.gl
	local sheets=cake.sheets
	local layouts=cake.layouts


	local sgui=oven.rebake("wetgenes.gamecake.spew.gui")

	local gui=oven.rebake(oven.modgame..".gui")
	local main=oven.rebake(oven.modgame..".main")
--	local beep=oven.rebake(oven.modgame..".beep")

	local framebuffers=oven.rebake("wetgenes.gamecake.framebuffers")
	
--	local sscores=oven.rebake("wetgenes.gamecake.spew.scores")
--	local srecaps=oven.rebake("wetgenes.gamecake.spew.recaps")

		
screen.loads=function()

	require(oven.modgame..".play_screen_glsl").create_shaders(oven)

end

screen.setup=function()

	screen.loads()

	screen.fbo=framebuffers.create(512,512,1)
	screen.lay=layouts.create{parent={x=0,y=0,w=512,h=512}}

	screen.fbos={}
	screen.fbos[1]=framebuffers.create(512,512,0)
	screen.fbos[2]=framebuffers.create(512,512,0)

	screen.cams={}
	screen.cams[1]=assert(gl.GenTexture())
	screen.cams[2]=assert(gl.GenTexture())
	screen.cam_idx=1
	screen.cam_fw=640/1024
	screen.cam_fh=480/512

-- create starting black textures so we can just update an area
	for i=1,2 do

		gl.BindTexture( gl.TEXTURE_2D , screen.cams[i] )
		
		gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_MIN_FILTER,gl.NEAREST)
		gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_MAG_FILTER,gl.NEAREST)
		gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_WRAP_S,	gl.CLAMP_TO_EDGE)
		gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_WRAP_T,	gl.CLAMP_TO_EDGE)

		gl.TexImage2D(
			gl.TEXTURE_2D,
			0,
			gl.RGB,
			1024,
			512,
			0,
			gl.RGB,
			gl.UNSIGNED_BYTE,
			string.rep("\0",3*1024*512) )
	end


	print( "VIDEO : ",pcall(function()
		local vid=assert(wv4l2.open(main.device or "/dev/video0"))

	--print(wstr.dump(wv4l2.capture_list(vid)))

		local t=wv4l2.capture_list(vid)
		local fmt
	--	dprint(t)
		for i,v in ipairs(t) do
	--		dprint(v)
			if (v.format=="Y10B") then fmt=v.format break end
			if (v.format=="UYVY") or (v.format=="YUYV") then fmt=v.format break end
		end
	--	print("FORMAT="..fmt)
		wv4l2.capture_start(vid,{width=640,height=480,buffer_count=2,format=fmt})


		print(wstr.dump(wv4l2.info(vid)))
		
		screen.vid=vid -- success
	end) )


end


screen.clean=function()

	if screen.fbo then screen.fbo:clean() end screen.fbo=nil
	
	for i,v in ipairs(screen.fbos) do
		v:clean()
	end


end


screen.update=function()

	if screen.vid then

		local t=wv4l2.capture_read_grd(screen.vid,screen.vidgrd and screen.vidgrd[0]) -- reuse last grd
		if t then
			screen.vidgrd=screen.vidgrd or wgrd.create(t)

			gl.BindTexture( gl.TEXTURE_2D , screen.cams[screen.cam_idx] )
			gl.TexSubImage2D(
				gl.TEXTURE_2D,
				0,
				0,0,
				640,480,
				gl.RGB,
				gl.UNSIGNED_BYTE,
				screen.vidgrd.data )
			gl.GenerateMipmap(gl.TEXTURE_2D)
			
			return true
		end
	
	end

	return false
end


screen.draw_bloom_setup=function()
--do return end

	local fbo=screen.fbos[1]
	fbo:bind_frame()
	gl.Viewport( 0 , 0 , 512 , 512 )

	local data={
		-1,	-1,		0,		0,	0,
		 1,	-1,		0,		1,	0,
		-1,	 1,		0,		0,	1,
		 1,	 1,		0,		1,	1,
	}

	local datalen=#data
	local datasize=datalen*4 -- we need this much vdat memory
	canvas.vdat_check(datasize) -- make sure we have space in the buffer
	
	pack.save_array(data,"f32",0,datalen,canvas.vdat)

	local p
	p=gl.program("bigtrouble_bloom_pick")
	gl.UseProgram( p[0] )

	gl.BindBuffer(gl.ARRAY_BUFFER,canvas.get_vb())
	gl.BufferData(gl.ARRAY_BUFFER,datasize,canvas.vdat,gl.DYNAMIC_DRAW)

	screen.fbo:bind_texture()
--	gl.Uniform1i( p:uniform("tex"), 0 )
	
	gl.VertexAttribPointer(p:attrib("a_vertex"),3,gl.FLOAT,gl.FALSE,20,0)
	gl.EnableVertexAttribArray(p:attrib("a_vertex"))
	
	gl.VertexAttribPointer(p:attrib("a_texcoord"),2,gl.FLOAT,gl.FALSE,20,12)
	gl.EnableVertexAttribArray(p:attrib("a_texcoord"))

	gl.DrawArrays(gl.TRIANGLE_STRIP,0,4)

	fbo.bind_frame() -- restore old frame
	canvas.layout.restore()
		
end


-- perform a blur to the input fbo, after this you may grab the outpub fbo and draw it
screen.draw_bloom_blur=function()

	local fbos=screen.fbos

	fbos[2]:bind_frame()
	gl.Viewport( 0 , 0 , fbos[2].w , fbos[2].h )

	local data={
		-1,	-1,		0,		0,				0,
		 1,	-1,		0,		fbos[2].uvw,	0,
		-1,	 1,		0,		0,				fbos[2].uvh,
		 1,	 1,		0,		fbos[2].uvw,	fbos[2].uvh,
	}

	local datalen=#data
	local datasize=datalen*4 -- we need this much vdat memory
	canvas.vdat_check(datasize) -- make sure we have space in the buffer
	
	pack.save_array(data,"f32",0,datalen,canvas.vdat)

	local p
	p=gl.program("bigtrouble_bloom_blur")
	gl.UseProgram( p[0] )

	gl.BindBuffer(gl.ARRAY_BUFFER,canvas.get_vb())
	gl.BufferData(gl.ARRAY_BUFFER,datasize,canvas.vdat,gl.DYNAMIC_DRAW)

	gl.ActiveTexture(gl.TEXTURE0)
	
	gl.VertexAttribPointer(p:attrib("a_vertex"),3,gl.FLOAT,gl.FALSE,20,0)
	gl.EnableVertexAttribArray(p:attrib("a_vertex"))
	
	gl.VertexAttribPointer(p:attrib("a_texcoord"),2,gl.FLOAT,gl.FALSE,20,12)
	gl.EnableVertexAttribArray(p:attrib("a_texcoord"))

	fbos[1]:bind_texture()
	gl.Uniform4f( p:uniform("pix_siz"), fbos[2].uvw/fbos[2].w,0,0,1 )
	gl.DrawArrays(gl.TRIANGLE_STRIP,0,4)


	fbos[1]:bind_frame()
	fbos[2]:bind_texture()
	gl.Uniform4f( p:uniform("pix_siz"), 0,fbos[2].uvh/fbos[2].h,0,1 )
	gl.DrawArrays(gl.TRIANGLE_STRIP,0,4)


	fbos[1].bind_frame() -- restore old frame

	canvas.layout.restore()

end

-- draw from buffer b into buffer a with f(p) used to select a program
-- and its uniforms
screen.draw_feed=function(a,b,f)

--print(a,b)

	local fbos=screen.fbos

	fbos[a]:bind_frame()
	gl.Viewport( 0 , 0 , fbos[a].w , fbos[a].h )

	local data={
		-1,	-1,		0,		0,				0,
		 1,	-1,		0,		fbos[b].uvw,	0,
		-1,	 1,		0,		0,				fbos[b].uvh,
		 1,	 1,		0,		fbos[b].uvw,	fbos[b].uvh,
	}

	local datalen=#data
	local datasize=datalen*4 -- we need this much vdat memory
	canvas.vdat_check(datasize) -- make sure we have space in the buffer
	
	pack.save_array(data,"f32",0,datalen,canvas.vdat)

	local p
	p=f() -- gl.program("bigtrouble_bloom_blur")
	gl.UseProgram( p[0] )

	gl.BindBuffer(gl.ARRAY_BUFFER,canvas.get_vb())
	gl.BufferData(gl.ARRAY_BUFFER,datasize,canvas.vdat,gl.DYNAMIC_DRAW)

	gl.ActiveTexture(gl.TEXTURE0)
	fbos[b]:bind_texture()
--	gl.Uniform1i( p:uniform("tex0"), 0 )
--	gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_MIN_FILTER,gl.NEAREST)
--	gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_MAG_FILTER,gl.NEAREST)
		
	gl.VertexAttribPointer(p:attrib("a_vertex"),3,gl.FLOAT,gl.FALSE,20,0)
	gl.EnableVertexAttribArray(p:attrib("a_vertex"))
	
	gl.VertexAttribPointer(p:attrib("a_texcoord"),2,gl.FLOAT,gl.FALSE,20,12)
	gl.EnableVertexAttribArray(p:attrib("a_texcoord"))

	gl.DrawArrays(gl.TRIANGLE_STRIP,0,4)
	
	
	fbos[a].bind_frame() -- restore old frame
	canvas.layout.restore()

end


-- clear fbo and prepare for drawing into
screen.draw_into_start=function(a)
	local fbos=screen.fbos

	fbos[a]:bind_frame()

	gl.MatrixMode(gl.PROJECTION)
	gl.PushMatrix()
	
	gl.MatrixMode(gl.MODELVIEW)
	gl.PushMatrix()

	screen.lay_orig=screen.lay.apply(nil,nil,0)

--	gl.ClearColor(0,0,0,1)
--	gl.DepthMask(gl.TRUE)
--	gl.Clear(gl.COLOR_BUFFER_BIT+gl.DEPTH_BUFFER_BIT)
--	gl.DepthMask(gl.FALSE)

end


-- finish drawing
screen.draw_into_stop=function(a)
local fbos=screen.fbos


--	screen.fbo:mipmap()
	
--	screen.draw_bloom_setup()
--	screen.draw_bloom_blur()

	gl.BindFramebuffer(gl.FRAMEBUFFER, 0)

	screen.lay_orig.restore()

	gl.MatrixMode(gl.PROJECTION)
	gl.PopMatrix()			
	gl.MatrixMode(gl.MODELVIEW)
	gl.PopMatrix()
	

end


-- draw fbo to the main screen
screen.draw=function(a,sx,sy)

	local fbos=screen.fbos

	gl.PushMatrix()
	gl.Translate(854/2,480/2,0)

	fbos[a]:bind_texture()
	gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_MIN_FILTER,gl.NEAREST)
--	gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_MAG_FILTER,gl.NEAREST)

--	local r,g,b,a=gl.color_get_rgba()
	local v3=gl.apply_modelview( {-sx,	 sy,	0,1} )
	local v1=gl.apply_modelview( {-sx,	-sy,	0,1} )
	local v4=gl.apply_modelview( { sx,	 sy,	0,1} )
	local v2=gl.apply_modelview( { sx,	-sy,	0,1} )

	local t={
		v3[1],	v3[2],	v3[3],	0,				0, 			
		v1[1],	v1[2],	v1[3],	0,				fbos[a].uvh,
		v4[1],	v4[2],	v4[3],	fbos[a].uvw,	0, 			
		v2[1],	v2[2],	v2[3],	fbos[a].uvw,	fbos[a].uvh,
	}
--[[
	local t={}

	for x=0,1,1/256 do
	
		local dd=1-((x-0.5)*(x-0.5)*0.5)
	
		local v4=gl.apply_modelview( {screen.fbo.w* (4*x-2),	screen.fbo.h* 2*dd,	0,1} )
		local v2=gl.apply_modelview( {screen.fbo.w* (4*x-2),	screen.fbo.h*-2*dd,	0,1} )

		t[#t+1]=v4[1]
		t[#t+1]=v4[2]
		t[#t+1]=v4[3]
		t[#t+1]=screen.fbo.uvw*x
		t[#t+1]=0

		t[#t+1]=v2[1]
		t[#t+1]=v2[2]
		t[#t+1]=v2[3]
		t[#t+1]=screen.fbo.uvw*x
		t[#t+1]=screen.fbo.uvh

	end
]]

	gl.Color(1,1,1,1)
	flat.tristrip("rawuv",t,"raw_tex")
--	flat.tristrip("rawuv",t,"bigtrouble_scanline")
--	flat.tristrip("rawuv",t,"bigtrouble_bleed")

--	gl.Color(0.75,0.75,0.75,1)
--	screen.fbos[1]:bind_texture()
--	flat.tristrip("rawuv",t,"bigtrouble_bloom")
--	gl.Color(1,1,1,1)

	gl.PopMatrix()
	
end


	return screen
end
