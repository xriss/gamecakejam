-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math
local wzips=require("wetgenes.zips")

local function dprint(a) print(wstr.dump(a)) end

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,parts)
	local parts=parts or {}
	parts.oven=oven
	
	parts.modname=M.modname

	local cake=oven.cake
	local gl=oven.gl
	
	local framebuffers=oven.rebake("wetgenes.gamecake.framebuffers")

	local main=oven.rebake(oven.modgame..".main")
	local screen=oven.rebake(oven.modgame..".play_screen")
	local sound=oven.rebake(oven.modgame..".play_sound")
	

parts.loads=function()

	local filename="lua/"..(oven.modgame..".play_parts"):gsub("%.","/")..".glsl"
	gl.shader_sources( wzips.readfile(filename) , filename )

end
		
parts.setup=function()

	parts.loads()
	
	parts.size=64

	parts.fbos={}
	parts.fbos[1]=framebuffers.create(parts.size*2,parts.size*2,0)
	parts.fbos[2]=framebuffers.create(parts.size*2,parts.size*2,0)


	parts.vb=gl.GenBuffer()
	local data={} local p=function(d) data[#data+1]=d end
	for x=0,parts.size-1 do
		for y=0,parts.size-1 do
			p(x)
			p(y)
		end
	end
	local datalen=#data
	local datasize=datalen*4 -- we need this much vdat memory
	cake.canvas.vdat_check(datasize) -- make sure we have space in the buffer
	pack.save_array(data,"f32",0,datalen,cake.canvas.vdat)
	
	gl.BindBuffer(gl.ARRAY_BUFFER,parts.vb)
	gl.BufferData(gl.ARRAY_BUFFER,datasize,cake.canvas.vdat,gl.STATIC_DRAW)
	parts.vb_len=datalen


	parts.fboidx=1
end

parts.clean=function()
end

-- draw from buffer b into buffer a with f() used to select a program
-- and its uniforms
parts.draw_feed=function(a,b,f)

--print(a,b)

	local fbos=parts.fbos

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
	cake.canvas.vdat_check(datasize) -- make sure we have space in the buffer
	
	pack.save_array(data,"f32",0,datalen,cake.canvas.vdat)

	local p
	p=f()
	gl.UseProgram( p[0] )

	gl.BindBuffer(gl.ARRAY_BUFFER,cake.canvas.get_vb())
	gl.BufferData(gl.ARRAY_BUFFER,datasize,cake.canvas.vdat,gl.DYNAMIC_DRAW)

	gl.ActiveTexture(gl.TEXTURE0)
	fbos[b]:bind_texture()
	gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_MIN_FILTER,gl.NEAREST)
	gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_MAG_FILTER,gl.NEAREST)

	gl.Uniform1f( p:uniform("parts_size"), parts.size )

	gl.VertexAttribPointer(p:attrib("a_vertex"),3,gl.FLOAT,gl.FALSE,20,0)
	gl.EnableVertexAttribArray(p:attrib("a_vertex"))
	
	gl.VertexAttribPointer(p:attrib("a_texcoord"),2,gl.FLOAT,gl.FALSE,20,12)
	gl.EnableVertexAttribArray(p:attrib("a_texcoord"))

	gl.Disable(gl.BLEND)
	gl.DrawArrays(gl.TRIANGLE_STRIP,0,4)
	gl.Enable(gl.BLEND)
	
	fbos[a].bind_frame() -- restore old frame
	cake.canvas.layout.restore()

end


parts.msg=function(m)
end

parts.update=function()

	parts.draw_feed(parts.fboidx,1+(parts.fboidx%2),function()
		
		local p=gl.program("nudgel_parts_test")
		gl.UseProgram( p[0] )
--		gl.Uniform4f( p:uniform("distort"), 1,0.25,1.0,0.03 )
		return p

	end)
	
	parts.fboidx=1+(parts.fboidx%2) -- next
	
end

parts.draw=function(sx,sy)


	local p
	p=gl.program("nudgel_parts_draw")
	gl.UseProgram( p[0] )

	gl.Uniform1f( p:uniform("parts_size"), parts.size )
	gl.Uniform1f( p:uniform("point_size"), oven.win.height/parts.size )

	gl.BindBuffer(gl.ARRAY_BUFFER,parts.vb)

	gl.VertexAttribPointer(p:attrib("a_vertex"),2,gl.FLOAT,gl.FALSE,8,0)
	gl.EnableVertexAttribArray(p:attrib("a_vertex"))

	parts.fbos[1+(parts.fboidx%2)]:bind_texture()
	gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_MIN_FILTER,gl.NEAREST)
	gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_MAG_FILTER,gl.NEAREST)

	gl.DrawArrays(gl.POINTS,0,parts.vb_len)

--[[
	local a=1+(parts.fboidx%2)
	local fbos=parts.fbos

	gl.PushMatrix()
	gl.Translate(854/2,480/2,0)

	fbos[a]:bind_texture()
	gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_MIN_FILTER,gl.NEAREST)
	gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_MAG_FILTER,gl.NEAREST)

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

	gl.Color(1,1,1,1)
	cake.canvas.flat.tristrip("rawuv",t,"raw_tex")

	gl.PopMatrix()
]]

end

	return parts
end
