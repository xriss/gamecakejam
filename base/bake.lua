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

for i,v in ipairs{
	"fonts/Vera.ttf",
	"wskins/soapbar/border.png",
	"wskins/soapbar/buttin.png",
	"wskins/soapbar/buttof.png",
	"wskins/soapbar/button.png",
} do
	wbake.create_dir_for_file("data/"..v)
	wbake.copyfile("../../mods/data/"..v,"data/"..v)
end


wbake.create_dir_for_file("out/{mainname}.zip")
os.execute("rm out/{mainname}.zip")
os.execute("zip -r out/{mainname}.zip data lua opts.lua")

