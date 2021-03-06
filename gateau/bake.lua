#!/usr/local/bin/gamecake

require("apps").default_paths() -- default search paths so things can easily be found

-- handle bake args (smell and bumps etc)
local wbake=require("wetgenes.bake")
local args=wbake.args{...}
wbake.update_lson("lua/init_bake.lua",args)

local wstr=require("wetgenes.string")
local wgrd=require("wetgenes.grd")
local wgrdmap=require("wetgenes.grdmap")

local wbgrd=require("wetgenes.bake.grd")
local copyfile=wbgrd.auto_copyfile
local copysave=wbgrd.auto_copysave

local wsbox=require("wetgenes.sandbox")


local lfs=require("lfs")

--[[
for _,dir in ipairs{"gateau"} do

	local files=wbake.findfiles{basedir="art",dir=dir,filter="."}.ret

	for i,v in ipairs(files) do
		wbake.create_dir_for_file("data/"..v)
		copyfile("art/"..v,"data/"..v)
		print(v)
	end

end
]]


for _,dir in ipairs{"imgs"} do

	local files=wbake.findfiles{basedir="art",dir=dir,filter="."}.ret

	for i,v in ipairs(files) do
		wbake.create_dir_for_file("data/"..v)
		copyfile("art/"..v,"data/"..v)
		print(v)
	end

end

for _,dir in ipairs{"sfx"} do

	local files=wbake.findfiles{basedir="art",dir=dir,filter="."}.ret

	for i,v in ipairs(files) do
		wbake.create_dir_for_file("data/"..v)
		copyfile("art/"..v,"data/"..v)
		print(v)
	end

end

for _,dir in ipairs{"oggs"} do

	local files=wbake.findfiles{basedir="art",dir=dir,filter="."}.ret

	for i,v in ipairs(files) do
		wbake.create_dir_for_file("data/"..v)
		copyfile("art/"..v,"data/"..v)
		print(v)
	end

end

for _,dir in ipairs{"fonts"} do

	local files=wbake.findfiles{basedir="art",dir=dir,filter="."}.ret

	for i,v in ipairs(files) do
		wbake.create_dir_for_file("data/"..v)
		wbake.copyfile("art/"..v,"data/"..v)
		print(v)
	end

end





local files={
	"aroids",
	"batwsbat",
	"cloids",
	"dmazed",
	"gagano",
	"gthang",
	"hunted",
	"lemonhunter",
	"lonelybird",
	"macrl",
	"quip",
	"umon",
}
local gateau={}
for i,name in ipairs(files) do

	local fname="../"..name.."/art/icons/gateau/gateau.lua"
	if wbake.isfile(fname) then

		local s=wbake.readfile(fname)

		local d=wsbox.ini(s)
		if d and d.id then
			gateau[d.id]=d		
			print("adding "..d.id.." to the gateau")
		end

		local files=wbake.findfiles{basedir="../"..name.."/art/icons/gateau",dir=".",filter="."}.ret

		for i,v in ipairs(files) do
			wbake.create_dir_for_file("data/gateau/"..name.."/"..v)
			wbake.copyfile("../"..name.."/art/icons/gateau/"..v,"data/gateau/"..name.."/"..v)
			print(v)
		end

	end
end

--print(wstr.dump(gateau))

wbake.writefile("data/gateau/all.lua",wstr.dump(gateau))


os.execute("rm -rf out")
wbake.create_dir_for_file("out/lua/wetgenes/t.zip")
os.execute("zip -r out/gateau.zip data lua opts.lua")

-- include snapshot of base modules for version safeness, probably.
--os.execute("cp -r ../../gamecake/lua/wetgenes out/lua/")
--os.execute("cd out ; zip -r gateau.zip lua")
