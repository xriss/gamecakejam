#!../bin/exe/lua

local wbake=require("wetgenes.bake")

local wstr=require("wetgenes.string")

local lfs=require("lfs")
local grd=require("wetgenes.grd")
local grdmap=require("wetgenes.grdmap")

local zip=require("zip")


local arg={...}

local basedir=wbake.get_cd()

local basename=arg[1]

if not basename then
	print("Please give an app name to install to. IE\n\nbase/install.lua testapp\nWill install testapp into a testapp dir\n")
	os.exit(0)
end

local opts={
	mainname=basename,
	maintitle=basename,
}

local copyfile=function(from,too)
	wbake.create_dir_for_file(too)
	wbake.replacefile(from,too,opts)
end

function copybase(a)
	copyfile("base/"..a,basename.."/"..a)
end
function copylua(a)
	copyfile("base/lua/basename/"..a,basename.."/lua/"..basename.."/"..a)
end


print("Installing base codes into "..basename)

copybase("opts.lua")
copybase("lua/init.lua")
copylua("main.lua")
copylua("main_menu.lua")
copylua("gui.lua")


