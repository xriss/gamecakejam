#!../../bin/dbg/lua

gfx_size=640
gfx_scale=gfx_size/640



local wbake=require("wetgenes.bake")

local wstr=require("wetgenes.string")

os.execute("rm -rf out")
wbake.create_dir_for_file("out/lua/wetgenes/t.zip")
os.execute("zip -r out/quip.zip data lua opts.lua")

-- include snapshot of base modules for version safeness, probably.
os.execute("cp -r ../../gamecake/lua/wetgenes out/lua/")
os.execute("cd out ; zip -r quip.zip lua")
