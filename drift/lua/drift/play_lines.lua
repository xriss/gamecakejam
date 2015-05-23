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

M.bake=function(oven,lines)
	local lines=lines or {}
	lines.oven=oven
	
	lines.modname=M.modname

	local cake=oven.cake
	local gl=oven.gl
	
	local main=oven.rebake(oven.modgame..".main")
	local screen=oven.rebake(oven.modgame..".play_screen")
	local sound=oven.rebake(oven.modgame..".play_sound")
	

lines.loads=function()

	local filename="lua/"..(oven.modgame..".play_lines"):gsub("%.","/")..".glsl"
	gl.shader_sources( wzips.readfile(filename) , filename )

end
		
lines.setup=function()

	lines.loads()
	
	lines.size=64--64	

	lines.vb=gl.GenBuffer()
	local data={} local p=function(d) data[#data+1]=d end

-- vertgrid	
	for x=0,lines.size do
		for y=0,lines.size-1 do
			p(x) p(y)
			p(x) p(y+1)
		end
	end

--horizgrid

	for y=0,lines.size do
		for x=0,lines.size-1 do
			p(x)   p(y)
			p(x+1) p(y)
		end
	end


	local datalen=#data
	local datasize=datalen*4 -- we need this much vdat memory
	cake.canvas.vdat_check(datasize) -- make sure we have space in the buffer
	pack.save_array(data,"f32",0,datalen,cake.canvas.vdat)
	
	gl.BindBuffer(gl.ARRAY_BUFFER,lines.vb)
	gl.BufferData(gl.ARRAY_BUFFER,datasize,cake.canvas.vdat,gl.STATIC_DRAW)
	lines.vb_len=datalen

	lines.add=0


	lines.vb2=gl.GenBuffer()
	local data={} local p=function(d) data[#data+1]=d end

-- vertgrid	
	for x=0,lines.size-1 do
		for y=0,lines.size-1 do


			p(x)     p(y)
			p(x+0.5) p(y+0.5)
			p(x+0.5) p(y+0.5)
			p(x+1)   p(y+1)

			p(x+1)   p(y)
			p(x+0.5) p(y+0.5)
			p(x+0.5) p(y+0.5)
			p(x )    p(y+1)
				
		end
	end



	local datalen=#data
	local datasize=datalen*4 -- we need this much vdat memory
	cake.canvas.vdat_check(datasize) -- make sure we have space in the buffer
	pack.save_array(data,"f32",0,datalen,cake.canvas.vdat)
	
	gl.BindBuffer(gl.ARRAY_BUFFER,lines.vb2)
	gl.BufferData(gl.ARRAY_BUFFER,datasize,cake.canvas.vdat,gl.STATIC_DRAW)
	lines.vb2_len=datalen
	
	

end

lines.clean=function()
end

lines.msg=function(m)
end

lines.update=function(progname)
	
	lines.add=(lines.add+1)%16384
end

lines.draw=function(n)

	if not n then n="" else n=tostring(n) end

	local p
	p=gl.program("nudgel_lines_draw")
	gl.UseProgram( p[0] )

	gl.Uniform1f( p:uniform("lines_size"), lines.size )
	gl.Uniform1f( p:uniform("point_size"), 1 )

	gl.Uniform4f( p:uniform("offset"), -((lines.add%128)/128),((lines.add%128)/128),0,0 )

	local t=function(n) local t=(lines.add%n)/n if t<=0.5 then return t*2 else return (1-t)*2 end end
	gl.Uniform4f( p:uniform("wobble"), t(512),t(256),t(128),t(64) )


	gl.BindBuffer(gl.ARRAY_BUFFER,lines["vb"..n])
	
	gl.VertexAttribPointer(p:attrib("a_vertex"),2,gl.FLOAT,gl.FALSE,8,0)
	gl.EnableVertexAttribArray(p:attrib("a_vertex"))

	
	
	gl.Uniform1i( p:uniform("cam0"), 1 )
	gl.ActiveTexture(gl.TEXTURE1)
	gl.BindTexture(gl.TEXTURE_2D,screen.cams[screen.cam_idx])
	gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_MIN_FILTER,gl.NEAREST)
	gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_MAG_FILTER,gl.NEAREST)

	gl.Uniform1i( p:uniform("cam1"), 2 )
	gl.ActiveTexture(gl.TEXTURE2)
	gl.BindTexture(gl.TEXTURE_2D,screen.cams[1+(screen.cam_idx%2)])
	gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_MIN_FILTER,gl.NEAREST)
	gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_MAG_FILTER,gl.NEAREST)

	gl.Uniform1i( p:uniform("fft0"), 3 )
	gl.ActiveTexture(gl.TEXTURE3)
	gl.BindTexture(gl.TEXTURE_2D,sound.fft_tex)
	gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_MIN_FILTER,gl.NEAREST)
	gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_MAG_FILTER,gl.NEAREST)
	
	gl.Uniform1i( p:uniform("wav0"), 4 )
	gl.ActiveTexture(gl.TEXTURE4)
	gl.BindTexture(gl.TEXTURE_2D,sound.s16_tex)
	gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_MIN_FILTER,gl.NEAREST)
	gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_MAG_FILTER,gl.NEAREST)



	
	
	local v=sound.dir or {0,0,0,0}
	gl.Uniform4f(  p:uniform("sound_velocity") , v[1],v[2],v[3],v[4] )
	
	gl.DrawArrays(gl.LINES,0,lines["vb"..n.."_len"]/2)

	gl.ActiveTexture(gl.TEXTURE0)
end

	return lines
end
