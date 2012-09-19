#!../../bin/dbg/lua

gfx_size=640
gfx_scale=gfx_size/640



local wbake=require("wetgenes.bake")

local wstr=require("wetgenes.string")

wbake.create_dir_for_file("out/quip.zip")
os.execute("rm out/quip.zip")
os.execute("zip -r out/quip.zip data lua opts.lua")


