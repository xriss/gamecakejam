-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local wstr=require("wetgenes.string")
local json=require("wetgenes.json")
local zips=require("wetgenes.zips")



-- Used to escape "'s by toCSV
local function escapeCSV (s)
  if string.find(s, '[,"]') then
    s = '"' .. string.gsub(s, '"', '""') .. '"'
  end
  return s
end

-- Convert from CSV string to table (converts a single line of a CSV file)
local function fromCSV (s,fieldstart)
	local t = {}        -- table to collect fields
	fieldstart = fieldstart or 1
	repeat
		-- next field is quoted? (start with `"'?)
		if string.find(s, '^"', fieldstart) then
			local a, c
			local i  = fieldstart
			repeat
				-- find closing quote
				a, i, c = string.find(s, '"("?)', i+1)
			until c ~= '"'    -- quote not followed by quote?
			if not i then return nil,'unmatched "' end
			local f = string.sub(s, fieldstart+1, i-1)
			table.insert(t, (string.gsub(f, '""', '"')))
			fieldstart = string.find(s, "[,\n]", i)
			if fieldstart then fieldstart=fieldstart+1 end
		else                -- unquoted; find next comma
			local nexti = string.find(s, "[,\n]", fieldstart)
			if nexti then
				table.insert(t, string.sub(s, fieldstart, nexti-1))
				fieldstart = nexti + 1
			else
				table.insert(t, string.sub(s, fieldstart))
				fieldstart=nil
			end
		end
	until (not fieldstart) or ( fieldstart > string.len(s) ) or ( s:sub(fieldstart-1,fieldstart-1) == "\n" )
	return t,fieldstart
end

-- Convert from table to CSV string
local function toCSV (tt)
  local s = ""
  for _,p in pairs(tt) do
    s = s .. "," .. escapeCSV(p)
  end
  return string.sub(s, 2)      -- remove first comma
end


-- grab the csv file from https://www.nomisweb.co.uk/census/2011/postcode_headcounts_and_household_estimates
-- save it in postcodes.csv
-- and this will group it by first 3-4 letters then spit it out as another csv
		local fname="postcodes.csv"
		print("Loading CSV "..fname)
		
		local codes={}
		local skiphead=true
		for l in io.lines(fname) do
			if skiphead then skiphead=false else
				local v=fromCSV(l)
				local code=v[1]
				local pop=tonumber(v[2])
				if code and pop then
					local cod=wstr.trim(string.sub(code,1,4))
					if not codes[cod] then io.write(cod.." ") end
					codes[cod]=(codes[cod] or 0) + pop
				end
			end
		end
		io.write("\n")
		
		local tab={}
		for n,v in pairs(codes) do
			tab[#tab+1]={n,v}
		end
		table.sort(tab,function(a,b) return a[1]<b[1] end)
		
		local fp=io.open("art/postcodes.csv","w")
		fp:write("postcode,population\n")
		for i,v in ipairs(tab) do
			fp:write(v[1]..","..v[2].."\n")
		end
		fp:close()







