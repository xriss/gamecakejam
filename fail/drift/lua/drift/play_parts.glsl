
#shader "nudgel_parts_draw"

#if defined(GL_FRAGMENT_PRECISION_HIGH)
precision highp float; /* really need better numbers if possible */
#endif

uniform sampler2D tex0;
uniform float parts_size;
uniform float point_size;

varying vec2  v_vertex;

varying vec4  color;

#ifdef VERTEX_SHADER

attribute vec2 a_vertex;
 
void main()
{
	vec2 base=(a_vertex+0.25)/parts_size;	

	vec4 t00=texture2D(tex0,base);
	vec4 t10=texture2D(tex0,base+vec2(0.5/parts_size,0.0));
	vec4 t01=texture2D(tex0,base+vec2(0.0,0.5/parts_size));
	vec4 t11=texture2D(tex0,base+vec2(0.5/parts_size,0.5/parts_size));

	vec2 v00=t00.xy+(t00.zw*(255.0/65536.0));
	
	    
    gl_Position=  vec4( vec2(-1.0,-1.0) + 
				( vec2( v00.x , v00.y )*2.0 ) , 0.0 , 1.0);

	gl_PointSize = point_size;
	
	color=t11;
}

#endif
#ifdef FRAGMENT_SHADER

void main(void)
{
	if( color.a==0.0 ) { discard; }
	gl_FragColor=color*color.a;
}

#endif


#SHADER "nudgel_parts_step"

#if defined(GL_FRAGMENT_PRECISION_HIGH)
precision highp float; /* really need better numbers if possible */
#endif

uniform sampler2D tex0;
uniform sampler2D cam0;
uniform sampler2D cam1;
uniform sampler2D fft0;

uniform float parts_size;
uniform vec4 sound_velocity;

varying vec2  v_texcoord;

#ifdef VERTEX_SHADER

attribute vec3 a_vertex;
attribute vec2 a_texcoord;

void main()
{
    gl_Position = vec4(a_vertex, 1.0);
	v_texcoord=a_texcoord;
}

#endif
#ifdef FRAGMENT_SHADER

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}


void main(void)
{
	vec2 tt=(fract(v_texcoord*parts_size)-0.25)*2.0;
	vec2 vv=floor(v_texcoord*parts_size);
	vec2 base=(vv+0.25)/parts_size;	
	vec4 t00=texture2D(tex0,base,-16.0);
	vec4 t10=texture2D(tex0,base+vec2(0.5/parts_size,0.0),-16.0);
	vec4 t01=texture2D(tex0,base+vec2(0.0,0.5/parts_size),-16.0);
	vec4 t11=texture2D(tex0,base+vec2(0.5/parts_size,0.5/parts_size),-16.0);

	vec2 v00=t00.xy+(t00.zw*(255.0/65536.0));
	vec2 v01=t01.xy+(t01.zw*(255.0/65536.0));
	
	v01=v01-vec2(0.5,0.5);

	vec2 vx=vec2(640.0/1024.0,480.0/512.0);

	vec3 c0=texture2D(cam0, vx-(v_texcoord*vx)).rgb;
	float d0=c0.g+(c0.r*255.0/65536.0);
	float p=texture2D(fft0, vec2((d0*d0)/8.0,0.0) )[0];

	if( (t11.a<=p*8.0) && (d0<(254.0/255.0)) && (d0>(1.0/255.0)) )
	{
			v00=vec2(v_texcoord.x,v_texcoord.y);
			v01.x=sound_velocity.y*(v_texcoord.x-0.5)/8.0;
			v01.y=((1.0-v_texcoord.x)+sound_velocity.y)/16.0;
			t10=vec4(0.0,0.0,0.0,0.0);
			t11=vec4( hsv2rgb( vec3(1.0-(d0*d0),0.5,1.0) ) , p*8.0);

			v01*=p*2.0;

			v00.xy+=v01.xy; // wiggle the first draw point a little
	}
	else
	{
//		v01+=(v00-v_texcoord)*vec2(1.0/64.0,1.0/64.0);
		v01.y=v01.y-(128.0/65536.0);
		
		v00.xy+=v01.xy;
	
		if( (v00.x>=1.0) && (v01.x>0.0) ) { v01.x=-v01.x*0.5; }
		if( (v00.x<=0.0) && (v01.x<0.0) ) { v01.x=-v01.x*0.5; }
		if( (v00.y>=1.0) && (v01.y>0.0) ) { v01.y=-v01.y*0.5; }
		if( (v00.y<=0.0) && (v01.y<0.0) ) { v01.y=-v01.y*0.5; }
		
		t11.a-=4.0/255.0;
	}

	v00=clamp( v00 , vec2(0.0,0.0) , vec2(1.0,1.0));

	t00.xy=floor(v00.xy*255.0)/255.0;
	t00.zw=(v00.xy-t00.xy)*65536.0/255.0;

	v01=clamp( v01+vec2(0.5,0.5) , vec2(0.0,0.0) , vec2(1.0,1.0));
	
	t01.xy=floor(v01.xy*255.0)/255.0;
	t01.zw=(v01.xy-t01.xy)*65536.0/255.0;

	if(tt.x<0.5)
	{
		if(tt.y<0.5) 	{ gl_FragColor=t00; }
		else			{ gl_FragColor=t01; }
	}
	else
	{
		if(tt.y<0.5)	{ gl_FragColor=t10; }
		else			{ gl_FragColor=t11; }
	}
}

#endif



#SHADER "nudgel_parts_step_dif"

#if defined(GL_FRAGMENT_PRECISION_HIGH)
precision highp float; /* really need better numbers if possible */
#endif

uniform sampler2D tex0;
uniform sampler2D cam0;
uniform sampler2D cam1;
uniform sampler2D fft0;

uniform float parts_size;
uniform vec4 sound_velocity;

varying vec2  v_texcoord;

#ifdef VERTEX_SHADER

attribute vec3 a_vertex;
attribute vec2 a_texcoord;

void main()
{
    gl_Position = vec4(a_vertex, 1.0);
	v_texcoord=a_texcoord;
}

#endif
#ifdef FRAGMENT_SHADER

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}


void main(void)
{
	vec2 tt=(fract(v_texcoord*parts_size)-0.25)*2.0;
	vec2 vv=floor(v_texcoord*parts_size);
	vec2 base=(vv+0.25)/parts_size;	
	vec4 t00=texture2D(tex0,base,-16.0);
	vec4 t10=texture2D(tex0,base+vec2(0.5/parts_size,0.0),-16.0);
	vec4 t01=texture2D(tex0,base+vec2(0.0,0.5/parts_size),-16.0);
	vec4 t11=texture2D(tex0,base+vec2(0.5/parts_size,0.5/parts_size),-16.0);

	vec2 v00=t00.xy+(t00.zw*(255.0/65536.0));
	vec2 v01=t01.xy+(t01.zw*(255.0/65536.0));
	
	v01=v01-vec2(0.5,0.5);

	vec2 vx=vec2(640.0/1024.0,480.0/512.0);

	vec3 c0=texture2D(cam0, vx-(v_texcoord*vx)).rgb;
	float d0=c0.g+(c0.r*255.0/65536.0);

	vec3 c1=texture2D(cam1, vx-(v_texcoord*vx)).rgb;
	float d1=c1.g+(c1.r*255.0/65536.0);
	
	float p=abs(d0-d1);

	if( (t11.a<=p*8.0) && (d0<(254.0/255.0)) && (d0>(1.0/255.0)) && (d1<(254.0/255.0)) && (d1>(1.0/255.0))  )
	{
			float d=d0<d1?d0:d1;
			
			v00=vec2(v_texcoord.x,v_texcoord.y);
			v01.x=sound_velocity.y*(v_texcoord.x-0.5)/8.0;
			v01.y=((1.0-v_texcoord.x)+sound_velocity.y)/16.0;
			t10=vec4(0.0,0.0,0.0,0.0);
			t11=vec4( hsv2rgb( vec3(1.0-(d*d),0.5,1.0) ) , p*8.0);

			v01*=p*2.0;

			v00.xy+=v01.xy; // wiggle the first draw point a little
	}
	else
	{
//		v01+=(v00-v_texcoord)*vec2(1.0/64.0,1.0/64.0);
		v01.y=v01.y-(128.0/65536.0);
		
		v00.xy+=v01.xy;
	
		if( (v00.x>=1.0) && (v01.x>0.0) ) { v01.x=-v01.x*0.5; }
		if( (v00.x<=0.0) && (v01.x<0.0) ) { v01.x=-v01.x*0.5; }
		if( (v00.y>=1.0) && (v01.y>0.0) ) { v01.y=-v01.y*0.5; }
		if( (v00.y<=0.0) && (v01.y<0.0) ) { v01.y=-v01.y*0.5; }
		
		t11.a-=4.0/255.0;
	}

	v00=clamp( v00 , vec2(0.0,0.0) , vec2(1.0,1.0));

	t00.xy=floor(v00.xy*255.0)/255.0;
	t00.zw=(v00.xy-t00.xy)*65536.0/255.0;

	v01=clamp( v01+vec2(0.5,0.5) , vec2(0.0,0.0) , vec2(1.0,1.0));
	
	t01.xy=floor(v01.xy*255.0)/255.0;
	t01.zw=(v01.xy-t01.xy)*65536.0/255.0;

	if(tt.x<0.5)
	{
		if(tt.y<0.5) 	{ gl_FragColor=t00; }
		else			{ gl_FragColor=t01; }
	}
	else
	{
		if(tt.y<0.5)	{ gl_FragColor=t10; }
		else			{ gl_FragColor=t11; }
	}
}

#endif

