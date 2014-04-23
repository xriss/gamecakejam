
local lfs=require("lfs")
local wbake=require("wetgenes.bake")
local wstr=require("wetgenes.string")
local wsbox=require("wetgenes.sandbox")


local files=wbake.findfiles{basedir=".",dir="gateau",filter="gateau.lua"}.ret

--print(wstr.dump(files))

local gateau={}
for i,name in ipairs(files) do

	local s=wbake.readfile(name)
	local d=wsbox.ini(s)
	
	if d and d.id then
		gateau[d.id]=d
		
		print("adding "..d.id.." to the gateau")
	end

end

--print(wstr.dump(gateau))

wbake.writefile("gateau/all.lua",wstr.dump(gateau))
