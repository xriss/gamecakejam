
#shader "nudgel_lines_draw"

#if defined(GL_FRAGMENT_PRECISION_HIGH)
precision highp float; /* really need better numbers if possible */
#endif

uniform float lines_size;
uniform float point_size;
uniform vec4 sound_velocity;
uniform vec4  offset;
uniform vec4  wobble;


uniform sampler2D tex0;
uniform sampler2D cam0;
uniform sampler2D cam1;
uniform sampler2D fft0;
uniform sampler2D wav0;


varying vec4  color;

//varying float bad;




#ifdef VERTEX_SHADER

attribute vec2 a_vertex;
 

mat4 rotmaty(float angle)
{
	float s = sin(angle);
	float c = cos(angle);

	return mat4(c  ,0.0,-s ,0.0,
				0.0,1.0,0.0,0.0,
				s  ,0.0,c  ,0.0,
				0.0,0.0,0.0,1.0);
}

vec4 getpos(vec4 p)
{
	mat4 m=rotmaty(smoothstep(0.0,1.0,wobble[0])*0.5-0.25);
	p=m*p;

	float dz=((1.0/16.0)+max(0.0,p.z)*32.0);
	p.x=40.0*p.x/dz;
	p.y=40.0*p.y/dz;
	p.z=(p.z/2.0)+0.25;
	
	return p;
}

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main()
{
	vec2 vx=vec2(640.0/1024.0,480.0/512.0);
	vec2 pos=offset.xy+a_vertex;
	
//	float w=texture2D(wav0,vec2((pos.x)/lines_size,0.5)).r;
//	pos.y+=(w-0.5)*2.0;

	vec3 c0=texture2D(cam0, vx-(((pos)/lines_size)*vx)).rgb;
	float d0=c0.g*(255.0/256.0)+(c0.r*255.0/65536.0);

	vec3 c1=texture2D(cam1, vx-(((pos)/lines_size)*vx)).rgb;
	float d1=c1.g*(255.0/256.0)+(c1.r*255.0/65536.0);
		
	float p=abs(d0-d1);

	if( (d0<(255.0/256.0)) && (d0>(4.0/256.0)) && (d1<(255.0/256.0)) && (d1>(4.0/256.0)) )
	{
//		bad=0.0;

		float d=d0<d1?d0:d1;
		d=d*d;
		float ff=texture2D(fft0, vec2((d),0.0) )[0];
		
		float dz=max(0.0,(d)-(ff*0.25));
		gl_Position=getpos( vec4( (vec2(-1.0,-1.0)+((pos)*2.0/lines_size)) , dz , 1.0 ) );

		gl_PointSize = 1.0;


		color=vec4( hsv2rgb( vec3(1.0-(d),0.5,1.0) ) , 0.5+p);
	}
	else
	{
//		bad=0.0;

		gl_Position=getpos( vec4( (vec2(-1.0,-1.0)+((pos)*2.0/lines_size)) , 1.0 , 1.0 ) );
		gl_PointSize = 1.0;
		color=vec4( hsv2rgb( vec3(1.0,0.5,1.0) ) , 0.25);
	}
		
}

#endif
#ifdef FRAGMENT_SHADER

void main(void)
{
//	if( bad!=0.0 ) { discard; }
	if( color.a==0.0 ) { discard; }
	gl_FragColor=color*color.a;
}

#endif
