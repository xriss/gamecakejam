

#shader "bloom_screen_pick"

#if defined(GL_FRAGMENT_PRECISION_HIGH)
precision highp float; /* really need better numbers if possible */
#endif

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

uniform float distortion;
uniform sampler2D tex;

uniform vec4  img_siz; /* 0,1 image size and 2,3 size of texture */
uniform vec4  img_off; /* texture offset (for sub layers) */

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

#endif

#shader "bloom_screen_blur"

#if defined(GL_FRAGMENT_PRECISION_HIGH)
precision highp float; /* really need better numbers if possible */
#endif

varying vec2  v_texcoord;
 
#ifdef VERTEX_SHADER

uniform mat4 modelview;
uniform mat4 projection;
uniform vec4 color;

attribute vec3 a_vertex;
attribute vec2 a_texcoord;
 
void main()
{
    gl_Position = vec4(a_vertex, 1.0);
	v_texcoord=a_texcoord;
}

#endif
#ifdef FRAGMENT_SHADER

uniform sampler2D tex;

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

#endif

#shader "bloom_screen_draw" "draw_screen"

// this is the header to all the above chunks with their unique source
// defined in another shader chunk bellow us

#if defined(GL_FRAGMENT_PRECISION_HIGH)
precision highp float; /* really need better numbers if possible */
#endif

uniform float distortion;

float squish(float n)
{
	return 1.0-pow(1.0-n,distortion);
}

//
// this will give a CRT style curved effect to a uv lookup
//
// input n is a uv square screen ranging from 0 to 1
//
// return 0-delta to 1+delta
//
vec2 curve_crt(vec2 uv,float curve,float delta)
{
	vec2 cc=abs(uv-vec2(0.5,0.5))*vec2(2.0,2.0);
	vec2 dd=vec2( 1.0+pow(cc.y,curve)*delta , 1.0+pow(cc.x,curve)*delta );
	cc=cc*dd;

	if(uv.x<0.5){uv.x=-cc.x;}else{uv.x=cc.x;}
	if(uv.y<0.5){uv.y=-cc.y;}else{uv.y=cc.y;}
	return 	(uv/vec2(2.0,2.0))+vec2(0.5,0.5);
}

// perform square magnification of a uv using focus
float square_squish1(float u,float a,float m)
{
	if(u<a)
	{
		return u/4.0;
	}
	else
	{
		return ((m-(a/4.0))*((u-a)/(m-a)))+(a/4.0);
	}
	
}
vec2 square_squish(vec2 uv,vec2 focus)
{
	vec2 a=vec2(0.125,0.25);
//	float a4=a/4.0;
	
/*

	if( focus.x<a     ) { focus.x=0;     } else
	if( focus.x>1.0-a ) { focus.x=1.0; }
	if( focus.y<a     ) { focus.y=0;     } else
	if( focus.y>1.0-a ) { focus.y=1.0; }
*/

	
	if(uv.x<focus.x)	{	uv.x=focus.x-square_squish1(focus.x-uv.x,a.x,focus.x);     }
	else				{	uv.x=focus.x+square_squish1(uv.x-focus.x,a.x,1.0-focus.x); }
	
	if(uv.y<focus.y)	{	uv.y=focus.y-square_squish1(focus.y-uv.y,a.y,focus.y);     }
	else				{	uv.y=focus.y+square_squish1(uv.y-focus.y,a.y,1.0-focus.y); }
	
	return uv;
}


#shader "bloom_screen_draw"

varying vec2  v_texcoord;
varying vec4  v_color;
 
#ifdef VERTEX_SHADER

uniform mat4 modelview;
uniform mat4 projection;
uniform vec4 color;

attribute vec3 a_vertex;
attribute vec2 a_texcoord;
 
void main()
{
    gl_Position = projection * modelview * vec4(a_vertex, 1.0);
	v_texcoord=a_texcoord;
	v_color=color;
}

#endif
#ifdef FRAGMENT_SHADER

uniform vec2 focus;
uniform sampler2D tex0;


void main(void)
{
	vec2 mm=vec2((800.0+0.0)/1024.0,(600.0+0.0)/1024.0);
	vec2 ff=focus/vec2(1024.0,1024.0);
#ifdef crt
	vec2 uv=v_texcoord/mm;
	uv=curve_crt(uv,2.0,1.0/8.0)*mm;
#else
	vec2 uv=v_texcoord;
#endif

	if( uv.x<0.0 || uv.x>mm.x || uv.y<0.0 || uv.y>mm.y)
	{
		discard;
	}
	
	if( uv.x < ff.x )
	{
		uv.x = ff.x-(squish( (ff.x-uv.x)/(ff.x) )*(ff.x));
	}
	else
	if( uv.x > ff.x )
	{
		uv.x = ff.x+(squish( (uv.x-ff.x)/(mm.x-ff.x) )*(mm.x-ff.x));
	}
	
	if( uv.y < ff.y )
	{
		uv.y = ff.y-(squish( (ff.y-uv.y)/(ff.y) )*(ff.y));
	}
	else
	if( uv.y > ff.y )
	{
		uv.y = ff.y+(squish( (uv.y-ff.y)/(mm.y-ff.y) )*(mm.y-ff.y));
	}

	gl_FragColor=vec4( texture2D(tex0, uv).rgb, 0.0 )*v_color;
}

#endif



#shader "draw_screen"

varying vec2  v_texcoord;
varying vec4  v_color;


#ifdef VERTEX_SHADER

uniform mat4 modelview;
uniform mat4 projection;

attribute vec3  a_vertex;
attribute vec2  a_texcoord;

void main()
{
    gl_Position = projection * modelview * vec4(a_vertex, 1.0);
	v_texcoord=a_texcoord;
	v_color=vec4(1.0,1.0,1.0,1.0);
}

#endif
#ifdef FRAGMENT_SHADER

uniform sampler2D tex0;
uniform vec2 focus;

#if 0
float squish(float n)
{

/*
#define PIX (1.0/1024.0)
	if(n<(128.0)*PIX)
	{
		return n*0.25;
	}
	else
	if(n<(128.0+128.0)*PIX)
	{
		return (0.25*128.0*PIX)+(n-(128.0)*PIX)*0.5;
	}
	else
	if(n<(128.0+128.0+64.0)*PIX)
	{
		return ((0.25*128.0+0.5*128.0)*PIX)+(n-(128.0+128.0)*PIX)*1.0;
	}
	else
	if(n<(128.0+128.0+64.0+32.0)*PIX)
	{
		return ((0.25*128.0+0.5*128.0+1.0*64.0)*PIX)+(n-(128.0+128.0+64.0)*PIX)*2.0;
	}
	else
	{
		return ((0.25*128.0+0.5*128.0+1.0*64.0+2.0*32.0)*PIX)+(n-(128.0+128.0+64.0+32.0)*PIX)*4.0;
	}
*/
	
	return 1.0-pow(1.0-n,distortion);
//	return 1.0-pow(1.0-n,1.0/4.0);
//	return pow(n,1.5);
//	return 1.0-sqrt(sqrt(1.0-n));
//	return 1.0-sqrt(1.0-n);
}
#endif

#define FIX(a) (a-(0.0/1024.0))
#define FIY(a) (a-(0.0/1024.0))

const vec2 xo = vec2(1.0/1024.0,0.0);
const vec2 ss = vec2(1024.0,1024.0);
const vec2 oo = vec2(1.0/1024.0,1.0/1024.0);

void main2(void)
{
	gl_FragColor=texture2D(tex0,v_texcoord)*v_color;
}
void main(void)
{
	vec2 mm=vec2((800.0+0.0)/1024.0,(600.0+0.0)/1024.0);
	vec2 ff=focus/vec2(1024.0,1024.0);

#ifdef crt
	vec2 uv=v_texcoord/mm;
	uv=curve_crt(uv,2.0,1.0/8.0)*mm;
#else
	vec2 uv=v_texcoord;
#endif

	if( uv.x<0.0 || uv.x>mm.x || uv.y<0.0 || uv.y>mm.y)
	{
		discard;
	}

//	vec2 ss=vec2(0.5,1.0);
	float yf=1.0;

//	uv=square_squish(uv,ff);

	
	if( uv.x < ff.x )
	{
		uv.x = ff.x-(squish( (ff.x-uv.x)/FIX(ff.x) )*FIX(ff.x));
//		uv.x = ff.x-squish((ff.x-uv.x)/ss.x)*ss.x;
	}
	else
	if( uv.x > ff.x )
	{
		uv.x = ff.x+(squish( (uv.x-ff.x)/FIX(mm.x-ff.x) )*FIX(mm.x-ff.x));
//		uv.x = ff.x+squish((uv.x-ff.x)/ss.x)*ss.x;
	}
	
	if( uv.y < ff.y )
	{
		yf=(ff.y-uv.y)/FIY(ff.y);
		uv.y = ff.y-(squish( (ff.y-uv.y)/FIY(ff.y) )*FIY(ff.y));
//		uv.y = ff.y-squish((ff.y-uv.y)/ss.y)*ss.y;
	}
	else
	if( uv.y > ff.y )
	{
		yf=(uv.y-ff.y)/FIY(mm.y-ff.y);
		uv.y = ff.y+(squish( (uv.y-ff.y)/FIY(mm.y-ff.y) )*FIY(mm.y-ff.y));
//		uv.y = ff.y+squish((uv.y-ff.y)/ss.y)*ss.y;
	}


	vec2 tb;
	vec4  c,c2;
	float aa;

	tb=(floor(uv*ss)+vec2(0.5,0.5))*oo;

	c=texture2D(tex0, tb).rgba;

//	aa=2.0*(fract(uv.x*1024.0/3.0)-0.5);
//	if(aa<0.0)
//	{
//		c2=texture2D(tex0, tb-xo ).rgba;
//		aa=clamp(aa,-1.0,0.0);
//		aa=aa*aa;
//		c=mix(c,c2,aa*0.5);
//	}
//	else
//	{
//		c2=texture2D(tex0, tb+xo).rgba;
//		aa=clamp(aa,0.0,1.0);
//		aa=aa*aa;
//		c=mix(c,c2,aa*0.5);
//	}


// scanline	
//	if( abs(v_texcoord.y - uv.y)<(32.0/1024.0) )
//	{
//		aa=2.0*(fract(uv.y*800.0/3.0)-0.5);
//		aa*=aa*aa*aa*(1.0-0.5);
//		c.rgb=c.rgb*(1.0-aa);
//	}

	gl_FragColor=vec4(c.rgb,1.0)*v_color;



//	vec2 puv=vec2(1024.0,1024.0)*uv;
//	gl_FragColor=texture2D(tex0,uv)*v_color;

}

#endif
