#!../../bin/exe/lua

local wbake=require("wetgenes.bake")
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

for _,dir in ipairs{"fonts"} do

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

-- write data bake log
do local fn="lua/init_bake.lua" wbake.create_dir_for_file(fn) local fp=io.open(fn,"w") fp:write(wstr.serialize(
{
	version=tonumber(wbake.version_from_time()),
	stamp=os.time(),
}
)) fp:close() end

os.execute("rm -rf out")
wbake.create_dir_for_file("out/lua/wetgenes/t.zip")
os.execute("zip -r out/batwsbat.zip data lua opts.lua")

-- include snapshot of base modules for version safeness, probably.
os.execute("cp -r ../../bin/lua/wetgenes out/lua/")
os.execute("cd out ; zip -r batwsbat.zip lua")
