
#shader "drift_sound"


#if defined(GL_FRAGMENT_PRECISION_HIGH)
precision highp float; /* really need better numbers if possible */
#endif


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
	gl_PointSize=3.0;
    gl_Position = projection * vec4(a_vertex.xyz , 1.0);
	v_texcoord=a_texcoord;
	v_color=vec4(1.0,1.0,1.0,1.0);
}

#endif
#ifdef FRAGMENT_SHADER

uniform sampler2D tex;

varying vec2  v_texcoord;
varying vec4  v_color;

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main(void)
{
//	vec4 c=texture2D(tex, vec2(v_texcoord.x,0.5)).rgba;
	vec4 c=texture2D(tex,v_texcoord).rgba;
//	float d=c.a;//(c.a*255.0/256.0) + (c.g*255.0/65536.0);
//	if(d>=(128.0/255.0) ) {d=d-1.0;}
	float d=(c.a*255.0/256.0) + (c.g*255.0/65536.0);
	if(d>=(0.5) ) {d=d-1.0;}
	d=d+0.5;
	
//	float c2=step(d,v_texcoord.y);
//	gl_FragColor=vec4( hsv2rgb( vec3(d,0.5,1.0) ) , 1.0)*c2;
	gl_FragColor=vec4( 1.0,1.0,1.0 , 1.0)*abs(d-0.5)*2.0;
	
//	gl_FragColor=vec4(texture2D(tex, v_texcoord).rgb,1.0);//* v_color;
//	gl_FragColor=vec4(v_texcoord,0.0,1.0);//* v_color;
//	gl_FragColor=vec4(1.0,1.0,1.0,1.0);
}

#endif


#shader "drift_fft"


#if defined(GL_FRAGMENT_PRECISION_HIGH)
precision highp float; /* really need better numbers if possible */
#endif


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
	gl_PointSize=3.0;
    gl_Position = projection * vec4(a_vertex.xyz , 1.0);
	v_texcoord=a_texcoord;
	v_color=vec4(1.0,1.0,1.0,1.0);
}

#endif
#ifdef FRAGMENT_SHADER

uniform sampler2D tex;

varying vec2  v_texcoord;
varying vec4  v_color;

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main(void)
{
//	vec4 c=texture2D(tex, vec2(v_texcoord.x,0.5)).rgba;
	vec4 c=texture2D(tex,v_texcoord).rgba;
//	float d=c.a;//(c.a*255.0/256.0) + (c.g*255.0/65536.0);
//	if(d>=(128.0/255.0) ) {d=d-1.0;}
	float d=(c.a*255.0/256.0) + (c.g*255.0/65536.0);
//	if(d>=(0.5) ) {d=d-1.0;}
//	d=d+0.5;
	
//	float c2=step(d,v_texcoord.y);
//	gl_FragColor=vec4( hsv2rgb( vec3(d,0.5,1.0) ) , 1.0)*c2;
	gl_FragColor=vec4( 1.0,1.0,1.0 , 1.0)*d;
	
//	gl_FragColor=vec4(texture2D(tex, v_texcoord).rgb,1.0);//* v_color;
//	gl_FragColor=vec4(v_texcoord,0.0,1.0);//* v_color;
//	gl_FragColor=vec4(1.0,1.0,1.0,1.0);
}

#endif


