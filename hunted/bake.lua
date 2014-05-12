#!/usr/bin/env gamecake

require("apps").default_paths() -- default search paths so things can easily be found

-- handle bake args (smell and bumps etc)
local wbake=require("wetgenes.bake")
local args=wbake.args{...}
wbake.update_lson("lua/init_bake.lua",args)

local wstr=require("wetgenes.string")
local wgrd=require("wetgenes.grd")
local wgrdmap=require("wetgenes.grdmap")

local lfs=require("lfs")
local zip=require("zip")


for _,dir in ipairs{"imgs"} do

	local files=wbake.findfiles{basedir="art",dir=dir,filter="."}.ret

	for i,v in ipairs(files) do
		wbake.create_dir_for_file("data/"..v)
		wbake.copyfile("art/"..v,"data/"..v)
		print(v)
	end

end

for _,dir in ipairs{"sfx"} do

	local files=wbake.findfiles{basedir="art",dir=dir,filter="."}.ret

	for i,v in ipairs(files) do
		wbake.create_dir_for_file("data/"..v)
		wbake.copyfile("art/"..v,"data/"..v)
		print(v)
	end

end

for _,dir in ipairs{"oggs"} do

	local files=wbake.findfiles{basedir="art",dir=dir,filter="."}.ret

	for i,v in ipairs(files) do
		wbake.create_dir_for_file("data/"..v)
		wbake.copyfile("art/"..v,"data/"..v)
		print(v)
	end

end

for i,v in ipairs{
	"fonts/Vera.ttf",
	"wskins/soapbar.png",
} do
	wbake.create_dir_for_file("data/"..v)
	wbake.copyfile("../../mods/data/"..v,"data/"..v)
end

wbake.create_dir_for_file("data/imgs/preloader/.png")

if args.smell=="pimoroni" then
	wbake.copyfile( "../../mods/data/imgs/preloader/pimoroni.jpg","data/imgs/preloader/pimoroni.jpg")
else
	wbake.copyfile( "../../mods/data/imgs/preloader/kittychair.jpg","data/imgs/preloader/kittychair.jpg")
end

os.execute("rm -rf out")
wbake.create_dir_for_file("out/lua/wetgenes/t.zip")
os.execute("zip -r out/hunted.zip data lua opts.lua")

-- include snapshot of base modules for version safeness, probably.
os.execute("cp -r ../../bin/lua/wetgenes out/lua/")
os.execute("cd out ; zip -r hunted.zip lua")
