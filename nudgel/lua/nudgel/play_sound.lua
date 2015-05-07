-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local wstr=require("wetgenes.string")
local pack=require("wetgenes.pack")

local al=require("al")
local alc=require("alc")
local kissfft=require("kissfft.core")


local function dprint(a) print(wstr.dump(a)) end

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,sound)
	local sound=sound or {}
	sound.oven=oven
	
	sound.modname=M.modname

	local cake=oven.cake
	local gl=oven.gl

	local main=oven.rebake(oven.modgame..".main")


-- configurable defaults

sound.fftsiz=1024
sound.samplerate=44100


sound.loads=function()

--	require(oven.modgame..".play_sound_glsl").create_shaders(oven)

end

sound.setup=function()

	sound.dev=alc.CaptureOpenDevice(nil,sound.samplerate,al.FORMAT_MONO16,44100)
	alc.CaptureStart(sound.dev)
	
	sound.fft=kissfft.start(sound.fftsiz)
	sound.dsamples=pack.alloc(sound.fftsiz*2)

	sound.fft_tex=gl.GenTexture()
	sound.s16_tex=gl.GenTexture()

	sound.u8_dat=pack.alloc(sound.fftsiz/2)

end


sound.clean=function()

	alc.CaptureStop(sound.dev)
	alc.CaptureCloseDevice(sound.dev)

end

sound.readdata=function()
	
	local c=alc.Get(sound.dev,alc.CAPTURE_SAMPLES) -- available samples
	if c>sound.fftsiz then
		alc.CaptureSamples(sound.dev,sound.dsamples)
		kissfft.push(sound.fft,sound.dsamples,sound.fftsiz)
		return sound.dsamples
	end

end


sound.writetextures16=function()

	gl.BindTexture(gl.TEXTURE_2D, sound.s16_tex)
    gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_MIN_FILTER,gl.NEAREST)
    gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_MAG_FILTER,gl.NEAREST)
    gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_WRAP_S,gl.CLAMP_TO_EDGE)
    gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_WRAP_T,gl.CLAMP_TO_EDGE)

    gl.TexImage2D(gl.TEXTURE_2D, 0, gl.LUMINANCE_ALPHA, sound.fftsiz, 1, 0, gl.LUMINANCE_ALPHA, gl.UNSIGNED_BYTE, sound.dsamples )

end


sound.writetexturefft=function()

	local fdat=pack.load_array(sound.fdat ,"f32",0,4*(sound.fftsiz/2)) -- read as floats
	local sampu8={}
	local byte=function(a) return (math.sqrt(a*16)) end
	local clamp=function(a) if a>255 then return 255 elseif a<0 then return 0 else return math.floor(a) end end

	for i=1,#fdat do
		sampu8[i]=clamp( byte(fdat[i] or 0 ) )	-- convert to bytes
	end

	gl.BindTexture(gl.TEXTURE_2D, sound.fft_tex)
    gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_MIN_FILTER,gl.NEAREST)
    gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_MAG_FILTER,gl.NEAREST)
    gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_WRAP_S,gl.CLAMP_TO_EDGE)
    gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_WRAP_T,gl.CLAMP_TO_EDGE)



	pack.save_array(sampu8,"u8",0,#sampu8,sound.u8_dat)
    gl.TexImage2D(gl.TEXTURE_2D, 0, gl.LUMINANCE, #sampu8, 1, 0, gl.LUMINANCE, gl.UNSIGNED_BYTE, sound.u8_dat )
end



sound.update=function()

	if sound.readdata() then
		while sound.readdata() do end -- catch up sound
	
		sound.fdat=kissfft.pull(sound.fft)

		sound.writetextures16() -- new texture
		sound.writetexturefft() -- new texture

		kissfft.reset(sound.fft)

		return true
	end

end

sound.draw=function()
end


	return sound
end



