-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math

local function dprint(a) print(wstr.dump(a)) end

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,menu)
	local menu=menu or {}
	menu.oven=oven
	
	menu.modname=M.modname

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
--	local beep=oven.rebake(oven.modgame..".beep")

	local sscores=oven.rebake("wetgenes.gamecake.spew.scores")
	local srecaps=oven.rebake("wetgenes.gamecake.spew.recaps")

	local layout=cake.layouts.create{}



menu.loads=function()

	menu.tex_pal=assert(gl.GenTexture())
	menu.tex_map=assert(gl.GenTexture())
	
	gl.BindTexture( gl.TEXTURE_2D , menu.tex_pal )
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

	gl.BindTexture( gl.TEXTURE_2D , menu.tex_map )
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


	gl.BindTexture( gl.TEXTURE_2D , menu.tex_pal )	
	gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_MIN_FILTER,gl.NEAREST)
	gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_MAG_FILTER,gl.NEAREST)
	gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_WRAP_S,gl.CLAMP_TO_EDGE)
	gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_WRAP_T,gl.CLAMP_TO_EDGE)
	
	gl.BindTexture( gl.TEXTURE_2D , menu.tex_map )
	gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_MIN_FILTER,gl.NEAREST)
	gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_MAG_FILTER,gl.NEAREST)
	gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_WRAP_S,gl.CLAMP_TO_EDGE)
	gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_WRAP_T,gl.CLAMP_TO_EDGE)
	
	gl.CheckError()

	gl.progsrc("test_font",[[
	
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
		
menu.setup=function()

	menu.loads()

	local ansi=require("ansigl.ansi")
	local a=io.open("test/zO-geekColly.ans","rb"):read("*all")
	menu.cmap=ansi.cmap({xh=80,yh=32})
	menu.looper=menu.cmap.print_looper(a)

	local data={}
	for y=0,255 do
		for x=0,255 do
			data[1+y*256*4+x*4  ]=0
			data[1+y*256*4+x*4+1]=0
			data[1+y*256*4+x*4+2]=0
			data[1+y*256*4+x*4+3]=0
		end
	end
	menu.mmap=data


end

menu.clean=function()

end

menu.msg=function(m)

--	print(wstr.dump(m))

	
end

menu.wait=0
menu.update=function()
	menu.wait=menu.wait+1
--	if menu.wait>10 then
--		menu.wait=0
	for i=1,16 do
		menu.looper()
	end
--	end
end

menu.draw=function()
	
-- test the texture
	for i=0,15 do
		sheets.get("imgs/dos437_32x8_9x16"):draw(49+i,32+i*8,360,nil,8,16)
	end

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
	gl.BindTexture( gl.TEXTURE_2D , menu.tex_pal )
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
		
-- charmap
	local data=menu.mmap
	for y=0,31 do
		for x=0,79 do
			local a,b,c=menu.cmap.get(x+y*80)
			data[1+y*256*4+x*4  ]=a%32
			data[1+y*256*4+x*4+1]=math.floor(a/32)
			data[1+y*256*4+x*4+2]=b
			data[1+y*256*4+x*4+3]=c
		end
	end

	canvas.vdat_check(#data) -- make sure we have space in the buffer
	pack.save_array(data,"u8",0,#data,canvas.vdat)
	gl.BindTexture( gl.TEXTURE_2D , menu.tex_map )
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


	local data={
		0,		0,		0,		0,		0,
		0+80*9,	0,		0,		80*9,	0,
		0,		0+512,	0,		0,		512,
		0+80*9,	0+512,	0,		80*9,	512,
	}

	local datalen=#data
	local datasize=datalen*4 -- we need this much vdat memory
	canvas.vdat_check(datasize) -- make sure we have space in the buffer
	
	pack.save_array(data,"f32",0,datalen,canvas.vdat)

	local p=gl.program("test_font")
	gl.UseProgram( p[0] )

	gl.BindBuffer(gl.ARRAY_BUFFER,canvas.get_vb())
	gl.BufferData(gl.ARRAY_BUFFER,datasize,canvas.vdat,gl.DYNAMIC_DRAW)

-- bind textures (3)

	gl.ActiveTexture(gl.TEXTURE2) gl.Uniform1i( p:uniform("tex_pal"), 2 )
	gl.BindTexture( gl.TEXTURE_2D , menu.tex_pal )

	gl.ActiveTexture(gl.TEXTURE1) gl.Uniform1i( p:uniform("tex_map"), 1 )
	gl.BindTexture( gl.TEXTURE_2D , menu.tex_map )

	gl.ActiveTexture(gl.TEXTURE0) gl.Uniform1i( p:uniform("tex_fnt"), 0 )
	gl.BindTexture( gl.TEXTURE_2D , sheets.get("imgs/dos437_32x8_9x16").img.gl )
	gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_MIN_FILTER,gl.NEAREST)
	gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_MAG_FILTER,gl.NEAREST)
	gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_WRAP_S,gl.CLAMP_TO_EDGE)
	gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_WRAP_T,gl.CLAMP_TO_EDGE)


	gl.UniformMatrix4f(p:uniform("modelview"), gl.matrix(gl.MODELVIEW) )
	gl.UniformMatrix4f(p:uniform("projection"), gl.matrix(gl.PROJECTION) )

	gl.Uniform4f( p:uniform("color"), 1,1,1,1 )
	
	gl.Uniform4f( p:uniform("fnt_siz"), 9,16,512,128 )
	gl.Uniform4f( p:uniform("map_pos"), 0,0,256,256 )

	gl.VertexAttribPointer(p:attrib("a_vertex"),3,gl.FLOAT,gl.FALSE,20,0)
	gl.EnableVertexAttribArray(p:attrib("a_vertex"))	
	
	gl.VertexAttribPointer(p:attrib("a_texcoord"),2,gl.FLOAT,gl.FALSE,20,12)
	gl.EnableVertexAttribArray(p:attrib("a_texcoord"))

	gl.DrawArrays(gl.TRIANGLE_STRIP,0,4)
	
end

	return menu
end
