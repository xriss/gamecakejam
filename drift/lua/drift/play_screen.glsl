
#SHADER "nudgel_test"


#ifdef VERTEX_SHADER

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

#endif
#ifdef FRAGMENT_SHADER


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

#endif


#SHADER "nudgel_fade"


#ifdef VERTEX_SHADER

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

#endif
#ifdef FRAGMENT_SHADER

#if defined(GL_FRAGMENT_PRECISION_HIGH)
precision highp float; /* really need better numbers if possible */
#endif

uniform sampler2D tex0;

varying vec2  v_texcoord;
varying vec4  v_color;

void main(void)
{
	vec2  uv=v_texcoord;
	gl_FragColor=vec4( texture2D(tex0, uv).rgb*(120.0/128.0), 1.0 );
}

#endif


#SHADER "nudgel_cam"


#ifdef VERTEX_SHADER

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

#endif
#ifdef FRAGMENT_SHADER


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

#endif


#SHADER "nudgel_rawcam"


#ifdef VERTEX_SHADER

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

#endif
#ifdef FRAGMENT_SHADER


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

#endif


#SHADER "nudgel_dep"


varying vec2  v_texcoord;
varying vec4  v_color;

uniform vec4 color;


vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}


#ifdef VERTEX_SHADER

uniform mat4 modelview;
uniform mat4 projection;

attribute vec3 a_vertex;
attribute vec2 a_texcoord;

void main()
{
    gl_Position = vec4(a_vertex, 1.0);
	v_texcoord=a_texcoord;
}

#endif
#ifdef FRAGMENT_SHADER

#if defined(GL_FRAGMENT_PRECISION_HIGH)
precision highp float; /* really need better numbers if possible */
#endif

uniform sampler2D tex0;
uniform sampler2D cam0;

float band(float fl, float fh, float fn)
{
	if(fn>fh) return 0.0;
	if(fn<fl) return 0.0;
	return 1.0;
}

void main(void)
{
	vec2 vx=vec2(640.0/1024.0,480.0/512.0);
	vec2  uv=v_texcoord;
	vec3 c1=texture2D(cam0, vx-(uv*vx)).rgb;
	vec3 c2=texture2D(tex0, uv).rgb;
	float m=c1.g+(c1.r*255.0/65536.0);
	if(m>=1.0) // no data
	{
		gl_FragColor=vec4( 0.0,0.0,0.0, 1.0 );
	}
	else
	{
		gl_FragColor=vec4( hsv2rgb(vec3(1.0-(m*m),1.0,1.0)) , 1.0 );
	}
}

#endif


#SHADER "nudgel_wave"


#ifdef VERTEX_SHADER

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

#endif
#ifdef FRAGMENT_SHADER

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

#endif


#SHADER "nudgel_fft"


#ifdef VERTEX_SHADER

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

#endif
#ifdef FRAGMENT_SHADER

uniform sampler2D tex0; 
uniform sampler2D tex1; 

uniform vec4  color;
varying vec2  v_texcoord;

void main(void)
{

	float x=v_texcoord[0]*2.0;
	if(x<1.0) { x=1.0-x; } else {x=x-1.0;}
	float p=texture2D(tex1, vec2(x/8.0,0.0) )[0];
//	if(x<1.0/128.0){p=0.0;}

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

#endif


#SHADER "nudgel_depfft"


#ifdef VERTEX_SHADER

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

#endif
#ifdef FRAGMENT_SHADER

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


//	float x=length(c1);
	float x=c1.g+(c1.r/256.0);

	vec3 c2=texture2D(tex0,v_texcoord).rgb;

#define DEPTH_MIN (0.125)
#define DEPTH_MAX (1.0-0.03125)

	if( (x>=DEPTH_MIN) && (x<=DEPTH_MAX) )
	{
		x=(x-DEPTH_MIN)/(DEPTH_MAX-DEPTH_MIN);
		float p=texture2D(tex1, vec2((x)/16.0,0.0) )[0];
		gl_FragColor=vec4(mix(c2,vec3(1.0,1.0,1.0),p*32.0),1.0);
	}
	else
	{
		gl_FragColor=vec4(c2,1.0);
	}




//	gl_FragColor=vec4(mix(c2,vec3(1.0,1.0,1.0),x),1.0);
}

#endif


#SHADER "nudgel_depmov"

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}


#ifdef VERTEX_SHADER

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

#endif
#ifdef FRAGMENT_SHADER

uniform sampler2D tex0; 
uniform sampler2D tex1; 
uniform sampler2D cam0;
uniform sampler2D cam1;

uniform vec4  color;
varying vec2  v_texcoord;

void main(void)
{
	vec2 vx=vec2(640.0/1024.0,480.0/512.0);
	vec2  uv=v_texcoord;
	vec3 c1a=texture2D(cam0, vx-(uv*vx)).rgb;
	vec3 c1b=texture2D(cam1, vx-(uv*vx)).rgb;

	float x1=c1a.g+(c1a.r*255.0/65536.0);
	float x2=c1b.g+(c1b.r*255.0/65536.0);

	vec3 c2=texture2D(tex0,v_texcoord).rgb;
//c2=vec3(0.0,0.0,0.0);

	if( (x1>=1.0) || (x2>=1.0) ) // bad data
	{
		gl_FragColor=vec4(0.0,0.0,0.0,1.0);
	}
	else
	{
		float a=abs(x1-x2);		
		if(a>(1.0/255.0))
		{
			float m=x1<x2?x1:x2; // pick the lowest of the two
			gl_FragColor=vec4(hsv2rgb(vec3(1.0-(m*m),1.0,1.0)),1.0);
		}
		else
		{
			gl_FragColor=vec4(c2,1.0);
		}
	}
}

#endif


#SHADER "nudgel_deprange"


#ifdef VERTEX_SHADER

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

#endif
#ifdef FRAGMENT_SHADER

uniform sampler2D tex0; 
uniform sampler2D tex1; 
uniform sampler2D cam0;
uniform sampler2D cam1;

uniform vec4  color;
varying vec2  v_texcoord;

void main(void)
{

	vec2 vx=vec2(640.0/1024.0,480.0/512.0);
	vec2  uv=v_texcoord;
	vec3 c1a=texture2D(cam0, vx-(uv*vx)).rgb;
	float x1=c1a.g+(c1a.r/256.0);

	vec3 c2=texture2D(tex0,v_texcoord).rgb;

#define DEPTH_MIN (0.25)
#define DEPTH_MAX (1.0-0.25)

	if( (x1>=DEPTH_MIN)  && (x1<=DEPTH_MAX))
	{
		gl_FragColor=vec4(1.0,1.0,1.0,1.0);
	}
	else
	{
		gl_FragColor=vec4(c2,1.0);
	}
}

#endif



#SHADER "nudgel_life"


#ifdef VERTEX_SHADER

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

#endif
#ifdef FRAGMENT_SHADER

uniform sampler2D tex0; 
uniform sampler2D tex1; 

uniform vec4  color;
varying vec2  v_texcoord;

void main(void)
{

	vec3 c1=texture2D(tex0,v_texcoord).rgb;

	float a=0;

#define ONE (1.0/512.0)

	a+=texture2D(tex0,v_texcoord + vec2(-ONE,-ONE) ).g;
	a+=texture2D(tex0,v_texcoord + vec2(   0,-ONE) ).g;
	a+=texture2D(tex0,v_texcoord + vec2( ONE,-ONE) ).g;
	a+=texture2D(tex0,v_texcoord + vec2(-ONE,   0) ).g;
//	a+=texture2D(tex0,v_texcoord + vec2(   0,-ONE) ).g;
	a+=texture2D(tex0,v_texcoord + vec2( ONE,   0) ).g;
	a+=texture2D(tex0,v_texcoord + vec2(-ONE, ONE) ).g;
	a+=texture2D(tex0,v_texcoord + vec2(   0, ONE) ).g;
	a+=texture2D(tex0,v_texcoord + vec2( ONE, ONE) ).g;
	
	if( (a>=2.5) && (a<=3.5) ) // born
	{
		if(c1.r >= 0.5) // live
		{
			gl_FragColor=vec4(c1,1.0);
		}
		else
		{
			gl_FragColor=vec4(1.0,1.0,1.0,1.0);
//			gl_FragColor=vec4(1.0,1.0,1.0,1.0);
		}
	}
	else
	if( (a>=2.5) && (a<=4.5) ) // live
	{
		gl_FragColor=vec4(c1,1.0);
	}
	else // die
	{
		gl_FragColor=vec4(c1/8.0,1.0);
//		gl_FragColor=vec4(0.0,0.0,0.0,1.0);
	}



}

#endif


#SHADER "nudgel_blur"


#ifdef VERTEX_SHADER

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

#endif
#ifdef FRAGMENT_SHADER

#if defined(GL_FRAGMENT_PRECISION_HIGH)
precision highp float; /* really need better numbers if possible */
#endif

uniform sampler2D tex0;

varying vec2  v_texcoord;
varying vec4  v_color;


uniform vec4  blur_step;  /* 0,1 pixel size */
uniform float blur_fade; /* 1.0 or less to darken */


void main(void)
{
	vec3  c;

	c=texture2D(tex0,v_texcoord).rgb*(4.0/16.0);
	c+=texture2D(tex0,v_texcoord+blur_step.xy* 1.0).rgb*(3.0/16.0);
	c+=texture2D(tex0,v_texcoord+blur_step.xy*-1.0).rgb*(3.0/16.0);
	c+=texture2D(tex0,v_texcoord+blur_step.xy* 2.0).rgb*(2.0/16.0);
	c+=texture2D(tex0,v_texcoord+blur_step.xy*-2.0).rgb*(2.0/16.0);
	c+=texture2D(tex0,v_texcoord+blur_step.xy* 3.0).rgb*(1.0/16.0);
	c+=texture2D(tex0,v_texcoord+blur_step.xy*-3.0).rgb*(1.0/16.0);

	gl_FragColor=vec4(c.rgb*blur_fade-vec3(1.0/255.0,1.0/255.0,1.0/255.0),1.0);
}

#endif


