-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local wstr=require("wetgenes.string")
local pack=require("wetgenes.pack")
local wzips=require("wetgenes.zips")

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,darkness)
	darkness=darkness or {}
	
	local cake=oven.cake
	local opts=oven.opts
	local canvas=cake.canvas
	
	local buffers=cake.buffers
	
	local font=canvas.font
	local flat=canvas.flat
	local sheets=cake.sheets
	
	local gl=oven.gl

	darkness.modname=M.modname
	

	local cells=oven.rebake("dmazed.cells")
	local main=oven.rebake("dmazed.main")
	local menu=oven.rebake("dmazed.main_menu")
	local game=oven.rebake("dmazed.main_game")

	local hero=oven.rebake("dmazed.hero")
		
	local beep=oven.rebake("dmazed.beep")
	local wscores=oven.rebake("wetgenes.gamecake.spew.scores")



darkness.loads=function()

	local filename="lua/"..(M.modname):gsub("%.","/")..".glsl"
	gl.shader_sources( assert(wzips.readfile(filename),"file not found: "..filename) , filename )

end

darkness.setup=function()

	darkness.loads()

-- some basic vertexformats
	local pstride=20
	local ptex=12
	
	local data={
		0,		0,		0,		0,		0,
		480,	0,		0,		480,	0,
		0,		480,	0,		0,		480,
		480,	480,	0,		480,	480,
	}
	
	local datalen=#data
	local vdatsize=datalen*4 -- we need this much vdat memory
	
	local vdat=pack.alloc(vdatsize)
	pack.save_array(data,"f32",0,datalen,vdat)	
	darkness.buff=buffers.create({start=darkness.start,stop=darkness.stop,vdat=vdat,vdatsize=vdatsize})


end

darkness.start=function(v)
	v:bind()
	gl.BufferData(gl.ARRAY_BUFFER,v.vdatsize,v.vdat,gl.STATIC_DRAW)
end

darkness.stop=function(v)
end

darkness.clean=function()
end

	
darkness.update=function()
end

darkness.draw=function()

	local p=gl.program("dmazed_darkness")
	gl.UseProgram( p[0] )

	local vertexarray
	if gl.GenVertexArray then
		vertexarray=gl.GenVertexArray()
		gl.BindVertexArray(vertexarray)
	end

	darkness.buff:bind()

	gl.UniformMatrix4f(p:uniform("modelview"), gl.matrix(gl.MODELVIEW) )
	gl.UniformMatrix4f(p:uniform("projection"), gl.matrix(gl.PROJECTION) )
--	gl.Uniform4f( p:uniform("color"), 0.3,0.2,0.4,1 )
	gl.Uniform4f( p:uniform("color"), 0,0,0,1 )
--	gl.Uniform4f( p:uniform("color"), 1,1,1,1 )

	gl.Uniform4f( p:uniform("center"), hero.px,hero.py,(game.time%1024),hero.view )

	gl.VertexAttribPointer(p:attrib("a_vertex"),3,gl.FLOAT,gl.FALSE,20,0)
	gl.EnableVertexAttribArray(p:attrib("a_vertex"))
	
	gl.VertexAttribPointer(p:attrib("a_texcoord"),2,gl.FLOAT,gl.FALSE,20,12)
	gl.EnableVertexAttribArray(p:attrib("a_texcoord"))

	gl.DrawArrays(gl.TRIANGLE_STRIP,0,4)

	if gl.GenVertexArray then
		gl.BindVertexArray(0)
		gl.DeleteVertexArray(vertexarray)
	end

end

	return darkness
end

