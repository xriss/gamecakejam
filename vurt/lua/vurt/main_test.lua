-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math

local function dprint(a) print(wstr.dump(a)) end

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,test)
	local test=test or {}
	test.oven=oven
	
	test.modname=M.modname

	local gl=oven.gl
	local cake=oven.cake
	local opts=oven.opts
	local canvas=cake.canvas
	local font=canvas.font
	local flat=canvas.flat
	local sheets=cake.sheets
	local fbs=cake.framebuffers
	
	local gui=oven.rebake(oven.modgame..".gui")
	local main=oven.rebake(oven.modgame..".main")


	local wetiso=oven.rebake("wetgenes.gamecake.spew.geom_wetiso")
	local geom=oven.rebake("wetgenes.gamecake.spew.geom")


test.loads=function()

	gl.progsrc("worldbox",[[
{shaderprefix}

uniform mat4 modelview;
uniform mat4 projection;
uniform vec4 color;

attribute vec3 a_vertex;
attribute vec3 a_normal;
attribute vec2 a_texcoord;

varying vec2  v_texcoord;
varying vec4  v_color;
varying vec3  v_normal;
 
void main()
{
    gl_Position = projection * modelview * vec4(a_vertex, 1.0);
    v_normal = normalize( mat3( modelview ) * a_normal );
	v_texcoord=a_texcoord;
	v_color=color;
}
]],[[
{shaderprefix}

uniform sampler2D tex;

varying vec2  v_texcoord;
varying vec4  v_color;
varying vec3  v_normal;

void main(void)
{
	float i= mod( floor( v_texcoord.x*16.0) + floor(v_texcoord.y*16.0) , 2.0 );

	vec4 c=vec4(1.0*i,1.0*i,1.0*i,1.0)*v_color;

	vec3 n=normalize(v_normal);

	gl_FragColor= c*max( -n.z, 0.25 ) ;
	gl_FragColor.a=c.a;
	
	gl_FragColor=c;
	

}

]])

end
		
test.setup=function()

	test.loads()
	
	wetiso.setup()
	
	test.box=geom.hexahedron()
	geom.apply_bevel(test.box,1)
	geom.face_square_uvs(test.box)
	geom.flip(test.box)

	geom.predraw(test.box,"worldbox")

end

test.clean=function()
	if test.fbo then
		test.fbo:clean()
		test.fbo=nil
	end

	wetiso.clean()
end

test.msg=function(m)

--	print(wstr.dump(m))
	
end

test.update=function()

	test.rot=((test.rot or 0) + 0.01)%360

	test.bounce=((test.bounce or 0) + 0.001)%1
	
end

test.draw_fbo=function(f,eye)

	if not test.fbo then test.fbo=fbs.create() end

	gl.MatrixMode(gl.PROJECTION)
	gl.PushMatrix()
	gl.MatrixMode(gl.MODELVIEW)
	gl.PushMatrix()
	
	local fs=512
	local ds=1024

	test.fbo:resize(fs,fs,1)
	fbs.bind_frame(test.fbo)
	local old_layout=cake.layouts.create{parent={w=fs,h=fs,x=0,y=0}}.apply(ds,ds,1/4,ds*8)
	
	gl.ClearColor(gl.C4(0xf000))
	gl.Clear(gl.COLOR_BUFFER_BIT+gl.DEPTH_BUFFER_BIT)

	
	-- draw stuff
	if f then f() end
	
	fbs.bind_frame(nil) -- remove fbs binding, should pop a stack?
	
	gl.MatrixMode(gl.PROJECTION)
	gl.PopMatrix()
	gl.MatrixMode(gl.MODELVIEW)
	gl.PopMatrix()
	
	old_layout.restore()
	
end

test.draw_eye=function(eye)

	if eye<0 then
		gl.ClearColor(1/4,0,0,1)
	else
		gl.ClearColor(0,1/4,0,1)
	end
	gl.Clear(gl.COLOR_BUFFER_BIT+gl.DEPTH_BUFFER_BIT)

	gl.Enable(gl.DEPTH_TEST)
	gl.Enable(gl.CULL_FACE)

	gl.Color(4/16,4/16,16/16,1)
	gl.Translate(512 -eye*128 ,512,512)
	gl.Scale(256,256,256)

	gl.Rotate(-test.rot,0,-1,0)

	gl.PushMatrix()
	gl.Scale(16,16,16)
	gl.DepthMask(gl.FALSE)
	geom.draw(test.box)
	gl.DepthMask(gl.TRUE)
	gl.PopMatrix()

	local t=(test.bounce-0.5)*2
	t=t*t
	t=(t-0.5)*2
	gl.Translate(0,0,-1024-512 + 1024*t)

	gl.Rotate(test.rot*10,0,-1,0)
	gl.Translate(0 ,-128,0)
--	geom.draw(test.box)
	wetiso.draw()
	gl.Translate(0 ,256,0)
	gl.Rotate(test.rot*20,0,-1,0)
	wetiso.draw()


	gl.Disable(gl.DEPTH_TEST)
	gl.Disable(gl.CULL_FACE)

end


test.predraw=function()

	if not gl.programs.oc_barrel then -- setup our special shaders
	
		gl.shaders.v_oc_barrel={
		source=gl.defines.shaderprefix..[[

uniform mat4 modelview;
uniform mat4 projection;
uniform vec4 color;

attribute vec3 a_vertex;
attribute vec2 a_texcoord;

varying vec2  v_texcoord;
 
void main()
{

    gl_Position = projection * modelview * vec4(a_vertex, 1.0);
	
	v_texcoord=a_texcoord;

}

	]]
}

		gl.shaders.f_oc_barrel={
		source=gl.defines.shaderprefix..[[

uniform sampler2D tex;
varying vec2  v_texcoord;

void main(void)
{
vec2      center			=vec2(0.5,0.5);
vec2      scale				=vec2(0.9,0.9);
vec2      scaleUV			=vec2(640.0/640.0,800.0/640.0);
vec4      warp				=vec4(1.0, 0.5, 0.25, 0.0);

    vec2  theta   = ( v_texcoord.xy - vec2(0.5,0.5) ) * scaleUV ;

    float rsq     = theta.x * theta.x +
					theta.y * theta.y ;

	vec2 uv=center + scale * theta *
							(	warp.x +
								warp.y * rsq +
								warp.z * rsq * rsq +
								warp.w * rsq * rsq * rsq );

	if( any( bvec2(clamp(uv,vec2(0.0,0.0),vec2(1.0,1.0))-uv)) )
	{
		gl_FragColor = vec4(0.0,0.0,0.0,1.0);
	}
	else
	{
		gl_FragColor = texture2D(tex, uv );
	}

}

	]]
}

		gl.programs.oc_barrel={
			vshaders={"v_oc_barrel"},
			fshaders={"f_oc_barrel"},
		}
	
	end

end

test.draw=function()

	test.predraw()

	test.draw_fbo(function()
		test.draw_eye(-1)
	end,-1)
	gl.BindTexture(gl.TEXTURE_2D, test.fbo.texture)
	gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_MIN_FILTER,gl.LINEAR)
	gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_MAG_FILTER,gl.LINEAR)
	gl.Color(gl.C4(0xffff))
	flat.tristrip("xyzuv",{
		0,		0,		0,		0,	1,
		640,	0,		0,		1,	1,
		0,		800,	0,		0,	0,
		640,	800,	0,		1,	0,
	},"oc_barrel")

	test.draw_fbo(function()
		test.draw_eye(1)
	end,1)
	gl.BindTexture(gl.TEXTURE_2D, test.fbo.texture)
	gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_MIN_FILTER,gl.LINEAR)
	gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_MAG_FILTER,gl.LINEAR)
	gl.Color(gl.C4(0xffff))
	flat.tristrip("xyzuv",{
		640,		0,		0,		0,	1,
		1280,		0,		0,		1,	1,
		640,		800,	0,		0,	0,
		1280,		800,	0,		1,	0,
	},"oc_barrel")
			
end

	return test
end
