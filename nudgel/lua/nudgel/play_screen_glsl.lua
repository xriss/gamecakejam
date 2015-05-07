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


--create some named shaders
M.create_shaders=function(oven)

	local gl=oven.gl

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

uniform vec4 center; 	// 0.5,0.5,0.5,0.5
uniform vec4 distort;	// 0.25,0.25,1.0,0.03

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
	float p=length(uv*distort.xy);
	uv=(uv)*pow(p*distort.z,distort.w);
	uv+=center.zw;

// color shift
	vec3 rgb=texture2D(tex0, uv).rgb;
	vec3 hsv=rgb2hsv(rgb);
	hsv.x=fract(hsv.x+p);
	hsv.y=1.0;
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


	gl.progsrc("nudgel_cam",[[
	
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
uniform sampler2D cam0;

varying vec2  v_texcoord;
varying vec4  v_color;

void main(void)
{
	vec2 vx=vec2(640.0/1024.0,480.0/512.0);
	vec2  uv=v_texcoord;
	vec3 c1=texture2D(cam0, vx-(uv*vx)).rgb;
	vec3 c2=texture2D(tex0, uv).rgb;
	float m=length(c1);

	gl_FragColor=vec4( mix(c2,c1,0.5*m) , 1.0 );
}

]]	)

	gl.progsrc("nudgel_rawcam",[[
	
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
uniform sampler2D cam0;

varying vec2  v_texcoord;
varying vec4  v_color;

void main(void)
{
	vec2 vx=vec2(640.0/1024.0,480.0/512.0);
	vec2  uv=v_texcoord;
	vec3 c1=texture2D(cam0, vx-(uv*vx)).rgb;
	vec3 c2=texture2D(tex0, uv).rgb;
//	float m=length(c1);
	gl_FragColor=vec4( c1, 1.0 );
}

]]	)

	gl.progsrc("nudgel_depthcam",[[
	
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
uniform sampler2D cam0;

varying vec2  v_texcoord;
varying vec4  v_color;

float band(float fl, float fh, float fn)
{
	if(fn>fh) return 0.0f;
	if(fn<fl) return 0.0f;
	return 1.0f;
}

void main(void)
{
	vec2 vx=vec2(640.0/1024.0,480.0/512.0);
	vec2  uv=v_texcoord;
	vec3 c1=texture2D(cam0, vx-(uv*vx)).rgb;
	vec3 c2=texture2D(tex0, uv).rgb;
	float m=c1.g+(c1.r/256.0);
	gl_FragColor=vec4( 0.0 , band(0.6,0.8,m) , 0.0 , 1.0 );
}

]]	)



	gl.progsrc("nudgel_wave",[[
{shaderprefix}
#line ]]..1+debug.getinfo(1).currentline..[[

uniform mat4 modelview;
uniform mat4 projection;

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

uniform sampler2D tex0;
uniform sampler2D tex1;

uniform vec4  color;
varying vec2  v_texcoord;

void main(void)
{
	float p=texture2D(tex1, vec2(v_texcoord[0],0.0) ).a;
	if(p>=(128.0/255.0)) { p=p-(128.0/255.0); } else { p=p+(128.0/255.0); }
	
	p+=(texture2D(tex1, vec2(v_texcoord[0],0.0) ).r/256.0); // more rez?
	
//	gl_FragColor=vec4(0.0,0.0,0.0,1.0);
	gl_FragColor=texture2D(tex0,v_texcoord);

	if( (p>0.5) && (v_texcoord[1]>0.5)  )
	{
		if( p >= v_texcoord[1] )
		{
			gl_FragColor=color;
		}
	}
	else
	if( (p<=0.5) && (v_texcoord[1]<=0.5)  )
	{
		if( p <= v_texcoord[1] )
		{
			gl_FragColor=color;
		}
	}
}

	]])

	gl.progsrc("nudgel_fft",[[
{shaderprefix}
#line ]]..1+debug.getinfo(1).currentline..[[

uniform mat4 modelview;
uniform mat4 projection;

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

uniform sampler2D tex0; 
uniform sampler2D tex1; 

uniform vec4  color;
varying vec2  v_texcoord;

void main(void)
{

	float x=v_texcoord[0];
	if(x<0.5) { x=0.5-x; } else {x=x-0.5;}
	float p=texture2D(tex1, vec2(x,0.0) )[0];
	if(x<1.0/128.0){p=0.0;}

//	gl_FragColor=vec4(0.0,0.0,0.0,1.0);
	gl_FragColor=texture2D(tex0,v_texcoord);
	if( (v_texcoord[1]>=0.5)  )
	{
		if( p > (v_texcoord[1]-0.5)*2.0 )
		{
			gl_FragColor=color;
		}
	}
	else
	if( (v_texcoord[1]<=0.5)  )
	{
		if( p > (0.5-v_texcoord[1])*2.0 )
		{
			gl_FragColor=color;
		}
	}
}

	]])


	gl.progsrc("nudgel_camfft",[[
{shaderprefix}
#line ]]..1+debug.getinfo(1).currentline..[[

uniform mat4 modelview;
uniform mat4 projection;

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

uniform sampler2D tex0; 
uniform sampler2D tex1; 
uniform sampler2D cam0; 

uniform vec4  color;
varying vec2  v_texcoord;

void main(void)
{

	vec2 vx=vec2(640.0/1024.0,480.0/512.0);
	vec2  uv=v_texcoord;
	vec3 c1=texture2D(cam0, vx-(uv*vx)).rgb;


	float x=length(c1)/64.0;
//	if(x<0.5) { x=0.5-x; } else {x=x-0.5;}
	float p=texture2D(tex1, vec2(x,0.0) )[0];
//	if(x<1.0/64.0){p=0.0;}


	vec3 c2=texture2D(tex0,v_texcoord).rgb;

	gl_FragColor=vec4(mix(c2,vec3(1.0,1.0,1.0),p*32.0),1.0);
}

	]])


end
