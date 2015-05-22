
#shader "nudgel_lines_draw"

#if defined(GL_FRAGMENT_PRECISION_HIGH)
precision highp float; /* really need better numbers if possible */
#endif

uniform float lines_size;
uniform float point_size;
uniform vec4 sound_velocity;
uniform vec4  offset;


uniform sampler2D tex0;
uniform sampler2D cam0;
uniform sampler2D cam1;
uniform sampler2D fft0;
uniform sampler2D wav0;


varying vec4  color;

varying float bad;

#ifdef VERTEX_SHADER

attribute vec2 a_vertex;
 

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
	float d0=c0.g+(c0.r*255.0/65536.0);

	vec3 c1=texture2D(cam1, vx-(((pos)/lines_size)*vx)).rgb;
	float d1=c1.g+(c1.r*255.0/65536.0);
		
	float p=abs(d0-d1);
	

	if( (d0<(254.0/255.0)) && (d0>(1.0/255.0)) && (d1<(254.0/255.0)) && (d1>(1.0/255.0)) )
	{
		bad=0.0;

		float dz=(d0+d1)/2.0;
		
		float ff=texture2D(fft0, vec2((dz*dz)/8.0,0.0) )[0];
//		float ff=texture2D(fft0, vec2(pos/lines_size) )[0]/128.0;
		
		dz=max(0.0,dz-(ff*8.0));

		gl_Position=  vec4( (vec2(-1.0,-1.0)+((pos)*2.0/lines_size)) / ((1.0/16.0)+dz) , dz , 1.0);
		gl_PointSize = 16.0;


		float d=d0<d1?d0:d1;
		color=vec4( hsv2rgb( vec3(1.0-(d*d),0.5,1.0) ) , 0.5+p);
		
	}
	else
	{
		bad=0.0;

		gl_Position=  vec4( (vec2(-1.0,-1.0)+((pos)*2.0/lines_size)) / ((1.0/16.0)+1.0) , 1.0 , 1.0);
		gl_PointSize = 0.0;
		color=vec4( hsv2rgb( vec3(1.0,0.5,1.0) ) , 0.0);

	}
		
}

#endif
#ifdef FRAGMENT_SHADER

void main(void)
{
	if( bad!=0.0 ) { discard; }
	if( color.a==0.0 ) { discard; }
	gl_FragColor=color*color.a;
}

#endif
