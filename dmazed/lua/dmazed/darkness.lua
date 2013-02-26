-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local wstr=require("wetgenes.string")
local pack=require("wetgenes.pack")

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

--	oven.cake.fonts.loads({1}) -- load 1st builtin font, a basic 8x8 font	

	if not gl.programs.darkness then
	
		gl.shaders.dmazed_v_darkness={
		source=gl.defines.shaderprefix..[[

uniform mat4 modelview;
uniform mat4 projection;
uniform vec4 color;

attribute vec3 a_vertex;
attribute vec2 a_texcoord;

varying vec2  v_texcoord;
varying vec4  v_color;
 
void main()
{
    gl_Position = projection * modelview * vec4(a_vertex, 1.0);
	v_texcoord=a_texcoord;
	v_color=color;
}

	]]
}

		gl.shaders.dmazed_f_darkness={
		source=gl.defines.shaderprefix..[[

uniform vec4 center;

varying vec2  v_texcoord;
varying vec4  v_color;

void main(void)
{
	vec2  dd;
	float w;
	float w2=center.w*center.w*(1.0/256.0);
	
	dd=v_texcoord.xy-center.xy;
	
	w=dd.x*dd.x*(1.0/256.0) + dd.y*dd.y*(1.0/256.0) ;
	
	gl_FragColor=v_color ;
	
	gl_FragColor.a=(w/w2); // adjust alpha
}

	]]
}

		gl.programs.dmazed_darkness={
			vshaders={"dmazed_v_darkness"},
			fshaders={"dmazed_f_darkness"},
		}

	end
	
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

	darkness.buff:bind()

	gl.UniformMatrix4f(p:uniform("modelview"), gl.matrix(gl.MODELVIEW) )
	gl.UniformMatrix4f(p:uniform("projection"), gl.matrix(gl.PROJECTION) )
	gl.Uniform4f( p:uniform("color"), 0,0,0,1 )

	gl.Uniform4f( p:uniform("center"), hero.px,hero.py,0,hero.view )

	gl.VertexAttribPointer(p:attrib("a_vertex"),3,gl.FLOAT,gl.FALSE,20,0)
	gl.EnableVertexAttribArray(p:attrib("a_vertex"))
	
	gl.VertexAttribPointer(p:attrib("a_texcoord"),2,gl.FLOAT,gl.FALSE,20,12)
	gl.EnableVertexAttribArray(p:attrib("a_texcoord"))

	gl.DrawArrays(gl.TRIANGLE_STRIP,0,4)

end

	return darkness
end

