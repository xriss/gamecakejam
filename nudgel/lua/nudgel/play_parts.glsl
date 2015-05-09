
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
//    v_vertex = vec2(-1.0,-1.0) + base*2.0;

	vec4 t00=texture2D(tex0,base);
	vec4 t10=texture2D(tex0,base+vec2(0.5/parts_size,0.0));
	vec4 t01=texture2D(tex0,base+vec2(0.0,0.5/parts_size));
	vec4 t11=texture2D(tex0,base+vec2(0.5/parts_size,0.5/parts_size));
    
//    gl_Position=  vec4( vec2(-1.0,-1.0) + 
//				( vec2( t00.x+(t00.z*255.0/65536.0) , t00.y+(t00.w*255.0/65536.0) )*2.0 ) , 0.0 , 1.0);
    gl_Position=  vec4( vec2(-1.0,-1.0) + 
				( vec2( t00.x , t00.y )*2.0 ) , 0.0 , 1.0);
//    gl_Position=  vec4( vec2(-1.0,-1.0) + 
//				( vec2( base.x , base.y )*2.0 ) , 0.0 , 1.0);

	gl_PointSize = point_size;
	
	color=t11; //vec4(v_vertex,0.0,1.0);
}

#endif
#ifdef FRAGMENT_SHADER

void main(void)
{
	gl_FragColor=color;
}

#endif


#SHADER "nudgel_parts_test"

#if defined(GL_FRAGMENT_PRECISION_HIGH)
precision highp float; /* really need better numbers if possible */
#endif

uniform sampler2D tex0;

uniform float parts_size;

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

void main(void)
{
	vec2 tt=(fract(v_texcoord*parts_size)-0.25)*2.0;
	vec2 vv=floor(v_texcoord*parts_size);
	vec2 base=(vv+0.25)/parts_size;	
	vec4 t00=texture2D(tex0,base);
	vec4 t10=texture2D(tex0,base+vec2(0.5/parts_size,0.0));
	vec4 t01=texture2D(tex0,base+vec2(0.0,0.5/parts_size));
	vec4 t11=texture2D(tex0,base+vec2(0.5/parts_size,0.5/parts_size));

	vec2 v00=t00.xy+(t00.zw*(255.0/65536.0));
	vec2 v01=t01.xy+(t01.zw*(255.0/65536.0));
	
	v01=v01-vec2(0.5,0.5);

	if(t11.a==0.0)
	{
		v00=vec2(v_texcoord.x,v_texcoord.y);
		v01=vec2(v_texcoord.x,v_texcoord.y)/256.0;
		t10=vec4(0.0,0.0,0.0,0.0);
		t11=vec4(v_texcoord.x,v_texcoord.y,0,1);
	}
	else
	{
		v00.xy+=v01.xy;
	
		if( (v00.x>=1.0) && (v01.x>0.0) ) { v01.x=-v01.x; }
		if( (v00.x<=0.0) && (v01.x<0.0) ) { v01.x=-v01.x; }
		if( (v00.y>=1.0) && (v01.y>0.0) ) { v01.y=-v01.y; }
		if( (v00.y<=0.0) && (v01.y<0.0) ) { v01.y=-v01.y; }

	}

	t00.xy=floor(v00.xy*255.0)/255.0;
	t00.zw=(v00.xy-t00.xy)*65536.0/255.0;

	v01=v01+vec2(0.5,0.5);
	
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
