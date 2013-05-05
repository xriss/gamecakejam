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

	local cake=oven.cake
	local opts=oven.opts
	local canvas=cake.canvas
	local font=canvas.font
	local flat=canvas.flat
	local gl=oven.gl
	local sheets=cake.sheets
	local fbs=cake.framebuffers
	
	local gui=oven.rebake(oven.modgame..".gui")
	local main=oven.rebake(oven.modgame..".main")


	local wetiso=oven.rebake("wetgenes.gamecake.spew.geom_wetiso")


test.loads=function()

end
		
test.setup=function()

	test.loads()
	
	wetiso.setup()

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

	test.rot=((test.rot or 0) + 1)%360
	
end

test.draw_fbo=function(f)

	if not test.fbo then test.fbo=fbs.create() end

	gl.MatrixMode(gl.PROJECTION)
	gl.PushMatrix()
	gl.MatrixMode(gl.MODELVIEW)
	gl.PushMatrix()
	
	local fs=512
	local ds=1024

	test.fbo:resize(fs,fs,0)
	fbs.bind_frame(test.fbo)
	local old_layout=cake.layouts.create{parent={w=fs,h=fs,x=0,y=0}}.apply(ds,ds,1/4,ds*4)
	
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

	gl.Rotate(test.rot,0,-1,0)

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
vec2      scaleUV			=vec2(640.0/512.0,800.0/512.0);
vec4      warp				=vec4(0.75, 0.75, 0.75, 0.75);

    vec2  theta   = ( v_texcoord.xy - center ) * scaleUV ;

    float rsq     = theta.x * theta.x +
					theta.y * theta.y ;

    gl_FragColor = texture2D(tex,  center + scale * theta *
							(	warp.x +
								warp.y * rsq +
								warp.z * rsq * rsq +
								warp.w * rsq * rsq * rsq ) );

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
	end)
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
	end)
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
