#!/usr/local/bin/gamecake


local wbake=require("wetgenes.bake")
local wstr=require("wetgenes.string")
local wgrd=require("wetgenes.grd")
local wgrdmap=require("wetgenes.grdmap")

local lfs=require("lfs")
local zip=require("zip")

for _,dir in ipairs{"cards"} do

	local files=wbake.findfiles{basedir="art",dir=dir,filter="."}.ret

	for i,v in ipairs(files) do
		wbake.create_dir_for_file("data/"..v)
		wbake.copyfile("art/"..v,"data/"..v)
		print(v)
	end

end



wbake.create_dir_for_file("out/dike.zip")
os.execute("rm out/dike.zip")
os.execute("zip -r out/dike.zip data lua")

