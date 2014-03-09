-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local wstr=require("wetgenes.string")
local json=require("wetgenes.json")
local zips=require("wetgenes.zips")

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M


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


M.bake=function(oven,csv)


	csv.loads=function()
	
		csv.postcodes={}
	
	
		local fname="data/phfunerals.csv"
		print("Loading CSV "..fname)

		local d=assert(zips.readfile(fname))
		
		local lines=wstr.split(d,"\n")
		for i=1,#lines do
			local it={}
			local v=fromCSV(lines[i])
			lines[i]=it
			if i>1 then -- cleanup data
				local s=v[3]
				if s then
					s=string.gsub(s,"[^0-9%.]","")
					it.cost=tonumber(s)
					if it.cost then it.cost=math.floor(it.cost) end
				end

				local s=v[2]
				if s then
					local aa=wstr.split(s,"/")
					it.year=tonumber(aa[1])
					it.month=tonumber(aa[2])
					it.day=tonumber(aa[3])
					
					
					if it.year and it.year < 2000 then -- hack bad data
						it.day,it.year = it.year,it.day
					end
				end

				local s=v[1]
				if s then
					it.postcode=s:upper()
				end

			end
		end
		table.remove(lines,1) -- header

		for i=#lines,1,-1 do
			if lines[i].year then
				if lines[i].postcode=="N/A" then
					table.remove(lines,i)
				end
			else
				table.remove(lines,i)
			end
		end
		
		local total=0
		local count=0
		
		for i,v in ipairs(lines) do
			if v.cost then
				total=total+v.cost
				count=count+1
			end
		end

		local average=math.floor(total/count)
		for i,v in ipairs(lines) do
			if not v.cost then
				v.cost=average
			end
		end


		for i,v in ipairs(lines) do
			local t=csv.postcodes[v.postcode]
			if not t then
				t={}
				csv.postcodes[v.postcode]=t
			end
			t[#t+1]=v
		end
		
		for i,v in pairs(csv.postcodes) do
		
			table.sort(v,function(a,b)
				if a.year<b.year then return true end
				if a.year>b.year then return false end
				if a.month<b.month then return true end
				if a.month>b.month then return false end
				if a.day<b.day then return true end
				if a.day>b.day then return false end
				return true
			end)
		
		end

--		print(wstr.dump(csv.postcodes))

		for n,v in pairs(csv.postcodes) do
			print(n,#v)
		end

	end
			
	csv.setup=function()

		csv.loads()

	end

	csv.clean=function()

	end


	return csv
end


