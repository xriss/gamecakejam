-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math

local function dprint(a) print(wstr.dump(a)) end

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,chars)
	local chars=chars or {}
	chars.oven=oven
	
	chars.modname=M.modname

	local cake=oven.cake
	local opts=oven.opts
	local canvas=cake.canvas
	local font=canvas.font
	local flat=canvas.flat
	local gl=oven.gl
	local sheets=cake.sheets
	
	local sgui=oven.rebake("wetgenes.gamecake.spew.gui")

	local gui=oven.rebake(oven.modgame..".gui")
	local main=oven.rebake(oven.modgame..".main")

chars.loads=function()


	chars.tex_pal=assert(gl.GenTexture())
	chars.tex_map=assert(gl.GenTexture())
	
	gl.BindTexture( gl.TEXTURE_2D , chars.tex_pal )
	gl.TexImage2D(
		gl.TEXTURE_2D,
		0,
		gl.RGBA,
		256,
		1,
		0,
		gl.RGBA,
		gl.UNSIGNED_BYTE,
		string.rep(string.char(0), 256 * 1 * 4) ) --blank the texture

	gl.BindTexture( gl.TEXTURE_2D , chars.tex_map )
	gl.TexImage2D(
		gl.TEXTURE_2D,
		0,
		gl.RGBA,
		256,
		256,
		0,
		gl.RGBA,
		gl.UNSIGNED_BYTE,
		string.rep(string.char(0), 256 * 256 * 4) ) --blank the texture


	gl.BindTexture( gl.TEXTURE_2D , chars.tex_pal )	
	gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_MIN_FILTER,gl.NEAREST)
	gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_MAG_FILTER,gl.NEAREST)
	gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_WRAP_S,gl.CLAMP_TO_EDGE)
	gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_WRAP_T,gl.CLAMP_TO_EDGE)
	
	gl.BindTexture( gl.TEXTURE_2D , chars.tex_map )
	gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_MIN_FILTER,gl.NEAREST)
	gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_MAG_FILTER,gl.NEAREST)
	gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_WRAP_S,gl.CLAMP_TO_EDGE)
	gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_WRAP_T,gl.CLAMP_TO_EDGE)
	
	gl.CheckError()

	gl.progsrc("draw_chars",[[
	
{shaderprefix}
#line ]]..debug.getinfo(1).currentline..[[

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

]],[[

{shaderprefix}
#line ]]..debug.getinfo(1).currentline..[[

#if defined(GL_FRAGMENT_PRECISION_HIGH)
precision highp float; /* really need better numbers if possible */
#endif


uniform sampler2D tex_fnt;
uniform sampler2D tex_map;
uniform sampler2D tex_pal;

uniform vec4  fnt_siz; /* 0,1 font size eg 8x16 and 2,3 the font texture size*/
uniform vec4  map_pos; /* 0,1 just add this to texcoord and 2,3 the map texture size*/

varying vec2  v_texcoord;
varying vec4  v_color;


void main(void)
{
	float c;
	vec4 d;
	vec4 bg,fg;
	vec2 t1=v_texcoord.xy+map_pos.xy;				// input uv
	vec2 t2=floor(mod(t1.xy,fnt_siz.xy)) ;			// char uv
	vec2 t3=floor(t1.xy/fnt_siz.xy)/map_pos.zw;		// map uv

	d=texture2D(tex_map, t3).rgba;	
	bg=texture2D(tex_pal, vec2(d.z,0), -16.0).rgba;
	fg=texture2D(tex_pal, vec2(d.w,0), -16.0).rgba;
	c=texture2D(tex_fnt, (t2+(floor(d.xy*255.0)*fnt_siz.xy))/fnt_siz.zw , -16.0).r;
	gl_FragColor=mix(bg,fg,c);

}

]]	)



end
		
chars.setup=function()

	chars.loads()


	chars.set_font()
	chars.set_pal()
	chars.set_map()

end

chars.clean=function()

end

chars.set_font=function(font)

	chars.font_name="imgs/dos437_32x8_9x16"
	chars.font_w=9
	chars.font_h=16
--	chars.font_tw=512 -- 32*9
--	chars.font_th=128 -- 8*16

	sheets.loads_and_chops({
		{chars.font_name,1/32,1/8,0,0},
	})

end


chars.set_pal=function(pal)

-- colours
	local data={
		0,		0,		0,		255,
		170,	0,		0,		255,
		0,		170,	0,		255,
		170,	85,		0,		255,
		0,		0,		170,	255,
		170,	0,		170,	255,
		0,		170,	170,	255,
		170,	170,	170,	255,
		85,		85,		85,		255,
		255,	85,		85,		255,
		85,		255,	85,		255,
		255,	255,	85,		255,
		85,		85,		255,	255,
		255,	85,		255,	255,
		85,		255,	255,	255,
		255,	255,	255,	255,
	}
	canvas.vdat_check(#data) -- make sure we have space in the buffer
	pack.save_array(data,"u8",0,#data,canvas.vdat)
	gl.BindTexture( gl.TEXTURE_2D , chars.tex_pal )
	gl.TexImage2D(
		gl.TEXTURE_2D,
		0,
		gl.RGBA,
		256,
		1,
		0,
		gl.RGBA,
		gl.UNSIGNED_BYTE,
		canvas.vdat )

end


chars.set_map=function(map)

	chars.map=map

	chars.x=0
	chars.y=0
	chars.w=256
	chars.h=256
	
-- charmap
	local data={}
	for y=0,255 do
		for x=0,255 do
			data[1+y*256*4+x*4  ]=0
			data[1+y*256*4+x*4+1]=0
			data[1+y*256*4+x*4+2]=0
			data[1+y*256*4+x*4+3]=0
		end
	end
	
	if map then
		for y=0,255 do
			for x=0,255 do
				local a,b,c=map.getxy(x,y)
				if a then
					data[1+y*256*4+x*4  ]=a%32
					data[1+y*256*4+x*4+1]=math.floor(a/32)
					data[1+y*256*4+x*4+2]=b
					data[1+y*256*4+x*4+3]=c
				end
			end
		end
	end

	canvas.vdat_check(#data) -- make sure we have space in the buffer
	pack.save_array(data,"u8",0,#data,canvas.vdat)
	gl.BindTexture( gl.TEXTURE_2D , chars.tex_map )
	gl.TexImage2D(
		gl.TEXTURE_2D,
		0,
		gl.RGBA,
		256,
		256,
		0,
		gl.RGBA,
		gl.UNSIGNED_BYTE,
		canvas.vdat )

end


chars.draw=function(x,y,w,h)

	x=x or 0
	y=y or 0
	w=w or oven.opts.width
	h=h or oven.opts.height

	local data={
		x,		y,		0,		0,	0,
		x+w,	y,		0,		w,	0,
		x,		y+h,	0,		0,	h,
		x+w,	y+h,	0,		w,	h,
	}

	local datalen=#data
	local datasize=datalen*4 -- we need this much vdat memory
	canvas.vdat_check(datasize) -- make sure we have space in the buffer
	
	pack.save_array(data,"f32",0,datalen,canvas.vdat)

	local p=gl.program("draw_chars")
	gl.UseProgram( p[0] )

	gl.BindBuffer(gl.ARRAY_BUFFER,canvas.get_vb())
	gl.BufferData(gl.ARRAY_BUFFER,datasize,canvas.vdat,gl.DYNAMIC_DRAW)

-- bind textures (3)

	gl.ActiveTexture(gl.TEXTURE2) gl.Uniform1i( p:uniform("tex_pal"), 2 )
	gl.BindTexture( gl.TEXTURE_2D , chars.tex_pal )

	gl.ActiveTexture(gl.TEXTURE1) gl.Uniform1i( p:uniform("tex_map"), 1 )
	gl.BindTexture( gl.TEXTURE_2D , chars.tex_map )

	gl.ActiveTexture(gl.TEXTURE0) gl.Uniform1i( p:uniform("tex_fnt"), 0 )
	gl.BindTexture( gl.TEXTURE_2D , sheets.get(chars.font_name).img.gl or 0)
	gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_MIN_FILTER,gl.NEAREST)
	gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_MAG_FILTER,gl.NEAREST)
	gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_WRAP_S,gl.CLAMP_TO_EDGE)
	gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_WRAP_T,gl.CLAMP_TO_EDGE)


	gl.UniformMatrix4f(p:uniform("modelview"), gl.matrix(gl.MODELVIEW) )
	gl.UniformMatrix4f(p:uniform("projection"), gl.matrix(gl.PROJECTION) )

	gl.Uniform4f( p:uniform("color"), 1,1,1,1 )
	
	gl.Uniform4f( p:uniform("fnt_siz"), chars.font_w,chars.font_h,sheets.get(chars.font_name).img.gl_width or 0,sheets.get(chars.font_name).img.gl_height or 0 )
	gl.Uniform4f( p:uniform("map_pos"), chars.x,chars.y,chars.w,chars.h )

	gl.VertexAttribPointer(p:attrib("a_vertex"),3,gl.FLOAT,gl.FALSE,20,0)
	gl.EnableVertexAttribArray(p:attrib("a_vertex"))	
	
	gl.VertexAttribPointer(p:attrib("a_texcoord"),2,gl.FLOAT,gl.FALSE,20,12)
	gl.EnableVertexAttribArray(p:attrib("a_texcoord"))

	gl.DrawArrays(gl.TRIANGLE_STRIP,0,4)
	
end

	return chars
end
