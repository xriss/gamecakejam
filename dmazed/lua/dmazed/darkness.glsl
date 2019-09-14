
#shader "dmazed_darkness"

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
    gl_Position = projection * modelview * vec4(a_vertex, 1.0);
	v_texcoord=a_texcoord;
	v_color=color;
}


#endif
#ifdef FRAGMENT_SHADER


uniform float time;

uniform vec4 center;

varying vec2  v_texcoord;
varying vec4  v_color;

/* 10bit precision noise? "kinda" 10bit shift feedback based */
float nose1( float n )
{
	n=fract(1.0/n);
	n=fract(n*2.0) + ( fract( ( 1.0 + step(0.5 , n ) + step(0.5, fract(n*8.0) ) ) * 0.5 ) * 1.0/512.0 ) ;
	return fract(1.0/n);
}

/* make more noise */
float nose( float n )
{
	n=nose1(n);
	return nose1(n);
}

void main(void)
{
	float w2=center.w*(1.0/512.0); w2*=w2;
/*
	float t=fract(center.z*(1.0/1024.0));
	float x=fract(v_texcoord.x*(1.0/512.0));
	float y=fract(v_texcoord.y*(1.0/512.0));
	float n=( nose( x * y * (1.0-t) ) - nose( y * t ) ) ;
*/
	vec2 dd=v_texcoord.xy-center.xy;
	float wx=(dd.x*(1.0/512.0)); wx*=wx;
	float wy=(dd.y*(1.0/512.0)); wy*=wy;
	float a=clamp(((wx+wy)/w2),0.0,1.0);
/*	gl_FragColor=v_color*n*a ;
*/	
	gl_FragColor=v_color*a ;
	gl_FragColor.a=a;
}

#endif
