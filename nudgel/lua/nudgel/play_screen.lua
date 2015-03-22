-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math

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

	gl.progsrc("bigtrouble_bloom_pick",[[
	
{shaderprefix}
#line ]]..1+debug.getinfo(1).currentline..[[

attribute vec3 a_vertex;
attribute vec2 a_texcoord;

varying vec2  v_texcoord;
 
void main()
{
    gl_Position = vec4(a_vertex, 1.0);
	v_texcoord=a_texcoord;
}

]],[[

{shaderprefix}
#line ]]..1+debug.getinfo(1).currentline..[[

#if defined(GL_FRAGMENT_PRECISION_HIGH)
precision highp float; /* really need better numbers if possible */
#endif

uniform sampler2D tex;

uniform vec4  img_siz; /* 0,1 image size and 2,3 size of texture */
uniform vec4  img_off; /* texture offset (for sub layers) */

varying vec2  v_texcoord;

void main(void)
{
	vec4  c;
	c=texture2D(tex, v_texcoord).rgba;

// spread the bloom around rgb space a little
	c.r=0.25*(c.r*2.0+c.g    +c.b    );
	c.g=0.25*(c.r    +c.g*2.0+c.b    );
	c.b=0.25*(c.r    +c.g    +c.b*2.0);

	gl_FragColor=vec4( c.rgb*c.rgb , 1.0 );
}

]]	)


	gl.progsrc("bigtrouble_bloom_blur",[[
{shaderprefix}
#line ]]..1+debug.getinfo(1).currentline..[[

uniform mat4 modelview;
uniform mat4 projection;
uniform vec4 color;

attribute vec3 a_vertex;
attribute vec2 a_texcoord;

varying vec2  v_texcoord;
 
void main()
{
    gl_Position = vec4(a_vertex, 1.0);
	v_texcoord=a_texcoord;
}

]],[[
{shaderprefix}
#line ]]..1+debug.getinfo(1).currentline..[[

#if defined(GL_FRAGMENT_PRECISION_HIGH)
precision highp float; /* really need better numbers if possible */
#endif

uniform sampler2D tex;

varying vec2  v_texcoord;

uniform vec4  pix_siz; /* 0,1 pixel size */


void main(void)
{
	vec2 td;
	vec2  tc=v_texcoord;
	vec4  c;

	c =texture2D(tex,tc).rgba*(4.0/16.0);
	c+=texture2D(tex,tc+pix_siz.xy* 1.0).rgba*(3.0/16.0);
	c+=texture2D(tex,tc+pix_siz.xy*-1.0).rgba*(3.0/16.0);
	c+=texture2D(tex,tc+pix_siz.xy* 2.0).rgba*(2.0/16.0);
	c+=texture2D(tex,tc+pix_siz.xy*-2.0).rgba*(2.0/16.0);
	c+=texture2D(tex,tc+pix_siz.xy* 3.0).rgba*(1.0/16.0);
	c+=texture2D(tex,tc+pix_siz.xy*-3.0).rgba*(1.0/16.0);

	gl_FragColor=c.rgba;
}

]]	)


	gl.progsrc("bigtrouble_bloom",[[
	
{shaderprefix}
#line ]]..1+debug.getinfo(1).currentline..[[

uniform mat4 modelview;
uniform mat4 projection;
uniform vec4 color;

attribute vec3 a_vertex;
attribute vec2 a_texcoord;

varying vec2  v_texcoord;
varying vec4  v_color;
 
void main()
{
    gl_Position = projection * modelview * vec4(a_vertex.xy, 0.0 , 1.0);
    gl_Position.z+=a_vertex.z;
	v_texcoord=a_texcoord;
	v_color=color;
}

]],[[

{shaderprefix}
#line ]]..1+debug.getinfo(1).currentline..[[

#if defined(GL_FRAGMENT_PRECISION_HIGH)
precision highp float; /* really need better numbers if possible */
#endif

uniform sampler2D tex0;

varying vec2  v_texcoord;
varying vec4  v_color;

void main(void)
{
	gl_FragColor=vec4( texture2D(tex0, v_texcoord).rgb, 0.0 )*v_color;
}

]]	)


	gl.progsrc("bigtrouble_scanline",[[
	
{shaderprefix}
#line ]]..1+debug.getinfo(1).currentline..[[

uniform mat4 modelview;
uniform mat4 projection;
uniform vec4 color;

attribute vec3 a_vertex;
attribute vec2 a_texcoord;

varying vec2  v_texcoord;
varying vec4  v_color;
 
void main()
{
    gl_Position = projection * modelview * vec4(a_vertex.xy, 0.0 , 1.0);
    gl_Position.z+=a_vertex.z;
	v_texcoord=a_texcoord;
	v_color=color;
}

]],[[

{shaderprefix}
#line ]]..1+debug.getinfo(1).currentline..[[

#if defined(GL_FRAGMENT_PRECISION_HIGH)
precision highp float; /* really need better numbers if possible */
#endif

uniform sampler2D tex;

varying vec2  v_texcoord;
varying vec4  v_color;


const vec2 xo = vec2(1.0/256.0,0.0);
const vec2 ss = vec2(256.0,256.0);
const vec2 oo = vec2(1.0/256.0,1.0/256.0);

void main(void)
{
	vec2 tb;

	vec4  c,c2;
	
	float aa;

	tb=(floor(v_texcoord*ss)+vec2(0.5,0.5))*oo;

	c=texture2D(tex, tb).rgba;


	aa=2.0*(fract(v_texcoord.x*256.0)-0.5);
	if(aa<0.0)
	{
		c2=texture2D(tex, tb-xo ).rgba;
		aa=clamp(aa,-1.0,0.0);
		aa=aa*aa;
		c=mix(c,c2,aa*0.5);
	}
	else
	{
		c2=texture2D(tex, tb+xo).rgba;
		aa=clamp(aa,0.0,1.0);
		aa=aa*aa;
		c=mix(c,c2,aa*0.5);
	}


// scanline	
	aa=2.0*(fract(v_texcoord.y*256.0)-0.5);
	aa*=aa*aa*aa;
	c.rgb=c.rgb*(1.0-aa);
	
	gl_FragColor=vec4(c.rgb,1.0)*v_color;

}

]]	)

	gl.progsrc("bigtrouble_bleed",[[
	
{shaderprefix}
#line ]]..1+debug.getinfo(1).currentline..[[

uniform mat4 modelview;
uniform mat4 projection;
uniform vec4 color;

attribute vec3 a_vertex;
attribute vec2 a_texcoord;

varying vec2  v_texcoord;
varying vec4  v_color;
 
void main()
{
    gl_Position = projection * modelview * vec4(a_vertex.xy, 0.0 , 1.0);
    gl_Position.z+=a_vertex.z;
	v_texcoord=a_texcoord;
	v_color=color;
}

]],[[

{shaderprefix}
#line ]]..1+debug.getinfo(1).currentline..[[

#if defined(GL_FRAGMENT_PRECISION_HIGH)
precision highp float; /* really need better numbers if possible */
#endif

uniform sampler2D tex;

varying vec2  v_texcoord;
varying vec4  v_color;


const vec2 xo = vec2(1.0/256.0,0.0);
const vec2 ss = vec2(256.0,256.0);
const vec2 oo = vec2(1.0/256.0,1.0/256.0);

void main(void)
{
/*
	vec2 tb;

	vec4  c,c2;
	
	float aa;

	tb=(floor(v_texcoord*ss)+vec2(0.5,0.5))*oo;

	c=texture2D(tex, tb).rgba;


	aa=2.0*(fract(v_texcoord.x*256.0)-0.5);
	if(aa<0.0)
	{
		c2=texture2D(tex, tb-xo ).rgba;
		aa=clamp(aa,-1.0,0.0);
		aa=aa*aa;
		c=mix(c,c2,aa*0.5);
	}
	else
	{
		c2=texture2D(tex, tb+xo).rgba;
		aa=clamp(aa,0.0,1.0);
		aa=aa*aa;
		c=mix(c,c2,aa*0.5);
	}


// scanline	
	aa=2.0*(fract(v_texcoord.y*256.0)-0.5);
	aa*=aa*aa*aa;
	c.rgb=c.rgb*(1.0-aa);
	
	gl_FragColor=vec4(c.rgb,1.0)*v_color;
*/

	vec4  c,c2;
	int cx,cy;
	float dd,d;
	vec2  vd,vc;
	vec2 td;	
	float aa;
	
// fetch the 9 colors that we plan to blend

	vc.x=1.0+fract(v_texcoord.x*256.0);
	vc.y=1.0+fract(v_texcoord.y*256.0);
	
	c=vec4(0.0,0.0,0.0,0.0);

	for(cy=0;cy<=2;cy++)
	{
		for(cx=0;cx<=2;cx++)
		{
			td.x=v_texcoord.x+((cx-1.0)/256.0);
			td.y=v_texcoord.y+((cy-1.0)/256.0);
			c2=texture2D(tex, td).rgba;
			
			vd.x=cx+0.5-vc.x;
			vd.y=cy+0.5-vc.y;
			dd=vd.x*vd.x+vd.y*vd.y;
			d=sqrt(dd)/min( (c2.r+c2.g+c2.b) , 1.25 );
			d=sqrt( clamp(1.0-d,0.0,1.0) );
			c=max(c,c2*d);

/* chroma split ? needs too many pixels to work well
			vd.x=cx+0.5     -vc.x;
			vd.y=cy+0.5-0.1-vc.y;
			d=sqrt(vd.x*vd.x+vd.y*vd.y)/(c2.r*1.25);
			d=sqrt( clamp(1.0-d,0.0,1.0) );
			c.r=max(c.r,c2.r*d);

			vd.x=cx+0.5+0.1-vc.x;
			vd.y=cy+0.5+0.1-vc.y;
			d=sqrt(vd.x*vd.x+vd.y*vd.y)/(c2.g*1.25);
			d=sqrt( clamp(1.0-d,0.0,1.0) );
			c.g=max(c.g,c2.g*d);

			vd.x=cx+0.5-0.1-vc.x;
			vd.y=cy+0.5+0.1-vc.y;
			d=sqrt(vd.x*vd.x+vd.y*vd.y)/(c2.b*1.25);
			d=sqrt( clamp(1.0-d,0.0,1.0) );
			c.b=max(c.b,c2.b*d);

			c.a=1.0;
*/

		}
	}
	gl_FragColor=vec4(c.rgb*c.a*c.a,1.0); // no alpha in this mode, but use a*a to increase the strength of the dark edges


}

]]	)




	gl.progsrc("nudgel_test",[[
	
{shaderprefix}
#line ]]..1+debug.getinfo(1).currentline..[[

uniform mat4 modelview;
uniform mat4 projection;
uniform vec4 color;

attribute vec3 a_vertex;
attribute vec2 a_texcoord;

varying vec2  v_texcoord;
 
void main()
{
    gl_Position = vec4(a_vertex, 1.0);
	v_texcoord=a_texcoord;
}

]],[[

{shaderprefix}
#line ]]..1+debug.getinfo(1).currentline..[[

#if defined(GL_FRAGMENT_PRECISION_HIGH)
precision highp float; /* really need better numbers if possible */
#endif

uniform sampler2D tex0;

varying vec2  v_texcoord;

uniform vec4 center;


vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main(void)
{
	vec2  uv=v_texcoord;
	uv-=center.xy;
	float p=length(uv);
	uv=uv*pow(p,0.03);
	uv+=center.zw;

// color shift
	vec3 rgb=texture2D(tex0, uv).rgb;
	vec3 hsv=rgb2hsv(rgb);
	hsv.x=fract(hsv.x+(p/8.0));
	rgb=hsv2rgb(hsv);
	
	gl_FragColor=vec4( rgb, 1.0 );
}

]]	)


	gl.progsrc("nudgel_dark",[[
	
{shaderprefix}
#line ]]..1+debug.getinfo(1).currentline..[[

uniform mat4 modelview;
uniform mat4 projection;
uniform vec4 color;

attribute vec3 a_vertex;
attribute vec2 a_texcoord;

varying vec2  v_texcoord;
varying vec4  v_color;
 
void main()
{
    gl_Position = vec4(a_vertex, 1.0);
	v_texcoord=a_texcoord;
}

]],[[

{shaderprefix}
#line ]]..1+debug.getinfo(1).currentline..[[

#if defined(GL_FRAGMENT_PRECISION_HIGH)
precision highp float; /* really need better numbers if possible */
#endif

uniform sampler2D tex0;

varying vec2  v_texcoord;
varying vec4  v_color;

void main(void)
{
	vec2  uv=v_texcoord;
	gl_FragColor=vec4( texture2D(tex0, uv).rgb*(127.0/128.0), 1.0 );
}

]]	)




end

screen.setup=function()

	screen.loads()

	screen.fbo=framebuffers.create(256,256,1)
	screen.lay=layouts.create{parent={x=0,y=0,w=256,h=256}}

	screen.fbos={}
	screen.fbos[1]=framebuffers.create(256,256,0)
	screen.fbos[2]=framebuffers.create(256,256,0)

end


screen.clean=function()

	if screen.fbo then screen.fbo:clean() end screen.fbo=nil
	
	for i,v in ipairs(screen.fbos) do
		v:clean()
	end


end


screen.update=function()

end


screen.draw_bloom_setup=function()
--do return end

	local fbo=screen.fbos[1]
	fbo:bind_frame()
	gl.Viewport( 0 , 0 , 256 , 256 )

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
screen.draw=function(a,s)

	local fbos=screen.fbos

	
	
	gl.PushMatrix()
	gl.Translate(320,240,0)

	fbos[a]:bind_texture()
	gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_MIN_FILTER,gl.NEAREST)
--	gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_MAG_FILTER,gl.NEAREST)

--	local r,g,b,a=gl.color_get_rgba()
	local v3=gl.apply_modelview( {fbos[a].w*-s,	fbos[a].h* s,	0,1} )
	local v1=gl.apply_modelview( {fbos[a].w*-s,	fbos[a].h*-s,	0,1} ) -- draw at 256*256 scale
	local v4=gl.apply_modelview( {fbos[a].w* s,	fbos[a].h* s,	0,1} )
	local v2=gl.apply_modelview( {fbos[a].w* s,	fbos[a].h*-s,	0,1} )

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
