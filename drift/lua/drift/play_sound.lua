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

sound.fftsiz=1024*4
sound.samplerate=44100

sound.fftclip=0/1024 -- ignore the low end buckets (relative to fftsize)



sound.note_names={ "C","C#","D","D#","E","F","F#","G","G#","A","A#","B"}
sound.note_freq={
{ [4]=261.63 },
{ [4]=277.18 },
{ [4]=293.66 },
{ [4]=311.13 },
{ [4]=329.63 },
{ [4]=349.23 },
{ [4]=369.99 },
{ [4]=392.00 },
{ [4]=415.30 },
{ [4]=440.00 },
{ [4]=466.16 },
{ [4]=493.88 },
}
for i,v in ipairs(sound.note_freq) do -- build other octaves
	v[1]=v[4]/8	v[2]=v[4]/4	v[3]=v[4]/2	v[5]=v[4]*2	v[6]=v[4]*4	v[7]=v[4]*8	v[8]=v[4]*16
end
sound.note_freq_add={}
for i=1,11 do
	sound.note_freq_add[i]={}
	for j=1,8 do
		sound.note_freq_add[i][j]=sound.note_freq[i+1][j] - sound.note_freq[i][j]
	end
end
sound.note_freq_add[12]={}
for j=1,7 do
	sound.note_freq_add[12][j]=sound.note_freq[1][j+1] - sound.note_freq[12][j]
end
sound.note_freq_add[12][8]=0

sound.freq2note=function(freq)
	for i=1,8 do
		if freq<=sound.note_freq[12][i] + (sound.note_freq_add[12][i]/2) then
			for j=12,2,-1 do
				if freq>sound.note_freq[j-1][i] + (sound.note_freq_add[j-1][i]/2) then
					return sound.note_names[j]..i
				end
			end
			return sound.note_names[1]..i
		end
	end
end



sound.loads=function()

--	require(oven.modgame..".play_sound_glsl").create_shaders(oven)

end

sound.setup=function()

	sound.fft_tex=gl.GenTexture()
	sound.s16_tex=gl.GenTexture()

pcall(function()
	sound.dev=alc.CaptureOpenDevice(nil,sound.samplerate,al.FORMAT_MONO16,44100)
	alc.CaptureStart(sound.dev)
	
	sound.fft=kissfft.start(sound.fftsiz)
	sound.dsamples=pack.alloc(sound.fftsiz*2)

	sound.u8_dat=pack.alloc(sound.fftsiz/2)

	sound.count=0
	sound.div=1
	
	sound.active=true
end)

end


sound.clean=function()
	if not sound.active then return end
	
	alc.CaptureStop(sound.dev)
	alc.CaptureCloseDevice(sound.dev)

end

sound.count=0
sound.readdata=function()
	
	local c=alc.Get(sound.dev,alc.CAPTURE_SAMPLES) -- available samples
	if c>sound.fftsiz then
		alc.CaptureSamples(sound.dev,sound.dsamples)
		kissfft.push(sound.fft,sound.dsamples,sound.fftsiz)
		sound.count=sound.count+1
		if sound.count>0 then
			sound.div=1.0/sound.count
			sound.count=0
			return sound.dsamples
		end
	end

end


sound.writetextures16=function()

	gl.BindTexture(gl.TEXTURE_2D, sound.s16_tex)
    gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_MIN_FILTER,gl.NEAREST)
    gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_MAG_FILTER,gl.NEAREST)
    gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_WRAP_S,gl.CLAMP_TO_EDGE)
    gl.TexParameter(gl.TEXTURE_2D,gl.TEXTURE_WRAP_T,gl.CLAMP_TO_EDGE)

    gl.TexImage2D(gl.TEXTURE_2D, 0, gl.LUMINANCE_ALPHA, sound.fftsiz/2, 1, 0, gl.LUMINANCE_ALPHA, gl.UNSIGNED_BYTE, sound.dsamples )

end


sound.writetexturefft=function()

	local fdat=pack.load_array(sound.fdat ,"f32",0,4*(sound.fftsiz/2)) -- read as floats
	local sampu8={}
	local clamp=function(a) if a>255 then return 255 elseif a<0 then return 0 else return math.floor(a) end end

	local mindat=sound.fftsiz*sound.fftclip
	for i=1,#fdat do
		fdat[i]=256*(fdat[i]*sound.div)/sound.fftsiz -- the size effects the volume
		if i<=mindat then sampu8[i]=0 else
			sampu8[i]=clamp( (fdat[i] or 0 ) )	-- convert to bytes
		end
-- fake
--		sampu8[i]=clamp( (256-i or 0 ) )
	end
	
	local dir,mag=0,0
	local dirs=#fdat-1
	for i=1,#fdat do
		if i<=mindat then else
			local d=((i-1)/dirs)
			local m=fdat[i]
--			if m>4 then
				dir=dir+d*m
				mag=mag+m
--			end
		end
	end
	
	if mag>0 then
		dir=dir/mag
	end
	
	local f=math.floor(dir*sound.samplerate/2)
	
	local x=(f/2000)
	if x<0 then x=0 end
	if x>1 then x=1 end
	local y=(f/2000)*mag/256
	if y<0 then y=0 end
	if y>1 then y=1 end
	sound.dir={x-0.5,y,0,0}
	
--	sound.dir={1,0,0,0}

--[[
	sound.dir[1]=(t-0.5)*2
	sound.dir[2]=(t<0.5) and (t) or (1-t)
	local d=math.sqrt(sound.dir[1]^2 + sound.dir[2]^2)
	if d>0 then
		sound.dir[1]=sound.dir[1]/d
		sound.dir[2]=sound.dir[2]/d
	end
	sound.dir[3]=sound.dir[1]*mag
	sound.dir[4]=sound.dir[2]*mag
]]
	
	if mag>16 then
		local s=sound.freq2note(f) or ""
		print(s,math.floor(mag),f)
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
	if not sound.active then return end

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



