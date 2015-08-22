-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math
local wv4l2=require("wetgenes.v4l2")
local wgrd=require("wetgenes.grd")
local wzips=require("wetgenes.zips")

local function dprint(a) print(wstr.dump(a)) end

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,draw_screen)
	local draw_screen=draw_screen or {}
	draw_screen.oven=oven
	
	draw_screen.modname=M.modname

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
--	framebuffers.TEXTURE_MIN_FILTER=gl.NEAREST
--	framebuffers.TEXTURE_MAG_FILTER=gl.NEAREST
	
--	local sscores=oven.rebake("wetgenes.gamecake.spew.scores")
--	local srecaps=oven.rebake("wetgenes.gamecake.spew.recaps")

draw_screen.loads=function()

	local filename="lua/"..(oven.modgame..".draw_screen"):gsub("%.","/")..".glsl"
	gl.shader_sources( wzips.readfile(filename) , filename )

end

draw_screen.setup=function()

	draw_screen.loads()

	draw_screen.fbo=framebuffers.create(1024,1024,1)

	draw_screen.fbo:bind_texture()

	draw_screen.lay=layouts.create{parent={x=0,y=0,w=1024,h=1024}}

-- effect fbos 1 and 2 for bloom processing
	draw_screen.fxbos={}
	draw_screen.fxbos[1]=framebuffers.create(1024,1024,0)
	draw_screen.fxbos[2]=framebuffers.create(1024,1024,0)


end


draw_screen.clean=function()

	if draw_screen.fbo then draw_screen.fbo:clean() end draw_screen.fbo=nil

	for i,v in ipairs(draw_screen.fxbos) do
		v:clean()
	end
	
end


draw_screen.update=function()

end


draw_screen.draw_bloom_pick=function()
--do return end

	local fbo=draw_screen.fxbos[1]
	fbo:bind_frame()
	gl.Viewport( 0 , 0 , 1024 , 1024 )

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
	p=gl.program("bloom_screen_pick")
	gl.UseProgram( p[0] )

	gl.BindBuffer(gl.ARRAY_BUFFER,canvas.get_vb())
	gl.BufferData(gl.ARRAY_BUFFER,datasize,canvas.vdat,gl.DYNAMIC_DRAW)

	draw_screen.fbo:bind_texture()
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
draw_screen.draw_bloom_blur=function()

	local fbos=draw_screen.fxbos

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
	p=gl.program("bloom_screen_blur")
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



-- clear fbo and prepare for drawing into
draw_screen.draw_into=function(callback)

	local fbo=draw_screen.fbo
	
	fbo:bind_frame()

	gl.MatrixMode(gl.PROJECTION)
	gl.PushMatrix()
	
	gl.MatrixMode(gl.MODELVIEW)
	gl.PushMatrix()
	

	draw_screen.lay_orig=draw_screen.lay.apply(nil,nil,0)

	gl.ClearColor(0,0,0,1)
	gl.DepthMask(gl.TRUE)
	gl.Clear(gl.COLOR_BUFFER_BIT+gl.DEPTH_BUFFER_BIT)
	gl.DepthMask(gl.FALSE)

	gl.Translate(0,1024-600,0) -- fix the top position for a 800x600 view
--	gl.Scale(640/800,480/600,1)

		callback()

	fbo:mipmap()

	draw_screen.draw_bloom_pick()
	draw_screen.draw_bloom_blur()

	gl.BindFramebuffer(gl.FRAMEBUFFER, 0)

	draw_screen.lay_orig.restore()

	gl.MatrixMode(gl.PROJECTION)
	gl.PopMatrix()
	gl.MatrixMode(gl.MODELVIEW)
	gl.PopMatrix()

end


-- draw fbo to the main draw_screen
draw_screen.draw=function(sx,sy)

	sx=sx or 400
	sy=sy or 300

	local fbo=draw_screen.fbo

	gl.PushMatrix()
	gl.Translate((800)/2,(600)/2,0)

	
	for i=1,2 do
		
		local shadername
		
		if i==1 then -- normal
		
			gl.ActiveTexture(gl.TEXTURE0)
			fbo:bind_texture()
			gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_MAG_FILTER,gl.NEAREST)
			gl.Color(1.0,1.0,1.0,1)
			shadername="draw_screen?crt"
			
		else --bloom

			gl.ActiveTexture(gl.TEXTURE0)
			draw_screen.fxbos[1]:bind_texture()
			gl.Color(0.75,0.75,0.75,1)
			shadername="bloom_screen_draw?crt"
		
		end
	
		flat.tristrip("xyzuv",{

			-sx,	 sy,		0,		0,					0, 			
			-sx,	-sy,		0,		0,					(600+0)/1024,
			 sx,	 sy,		0,		(800+0)/1024,		0, 			
			 sx,	-sy,		0,		(800+0)/1024,		(600+0)/1024,

		},shadername,function(p)
--			local player=basket.player
	--		print(player.cell.xp,player.cell.yp)
--				gl.Uniform2f( p:uniform("focus"), player.cell.xp*16+8 , (480)-player.cell.yp*16-8 )
--				local xp=player.cell.xp*16+8+16
--				local yp=player.cell.yp*16+8+24
--				xp=xp-32 if xp<0 then xp=0 end if xp>640-64 then xp=640-32 end xp=xp+32
--				yp=yp-32 if yp<0 then yp=0 end if yp>480-64 then xp=480-32 end yp=yp+32
				
				gl.Uniform2f( p:uniform("focus"), 0 , (800)-0 )
				gl.Uniform1f( p:uniform("distortion"), 1/1 )
		end)

	end
	gl.Color(1.0,1.0,1.0,1)
	

	gl.PopMatrix()
	
end


	return draw_screen
end
