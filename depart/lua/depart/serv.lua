-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local socket=require("socket")

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math

local dprint=function(...) return print(wstr.dump(...)) end

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(oven,serv)
	serv=serv or {}
	serv.modname=M.modname
	
-----------------------------------------------------------------------------
--
-- simple set implementation
-- the select function doesn't care about what is passed to it as long as
-- it behaves like a table
-- creates a new set data structure
--
-----------------------------------------------------------------------------
local function newset()
    local reverse = {}
    local set = {}
    return setmetatable(set, {__index = {
        insert = function(set, value)
            if not reverse[value] then
                table.insert(set, value)
                reverse[value] = table.getn(set)
            end
        end,
        remove = function(set, value)
            local index = reverse[value]
            if index then
                reverse[value] = nil
                local top = table.remove(set)
                if top ~= value then
                    reverse[top] = index
                    set[index] = top
                end
            end
        end
    }})
end

local function doreceive()

	local sa,sb,sc
	local ret,_ret
	
	local readable, _, error = socket.select(serv.connections, nil, 0.00001) -- please do not wait
	for _, input in ipairs(readable) do
			
		if input == serv.server then
		
			local client = input:accept()
			if client then
								
				serv.connections:insert(client)
				serv.client_connected(client)
				client:settimeout(0.00001) -- this is a hack fix?
				
			end
		
		else -- it is a client
			local client=input
		
			input:settimeout(0.00001) -- this is a hack fix?
			local part, error , part2= input:receive("*a")
			
			part=part or part2 -- we can get an error AND data, possibly even in part2...
			
			if part and (part~="") then -- got some data (but it might be partial...
			
				serv.client_data(client,part)

			end

			if error or part=="" then -- this is aproblem

				if error=="timeout" then -- ignore timeouts

				else -- remove client on all other errors
					serv.client_disconnect(client)
				end
			
			end		
		end
	end
end

	serv.setup=function(opts)
	
		serv.connections = newset()

		serv.server=assert(socket.bind("*",1111)) -- needs to be a high port
		
		serv.connections:insert(serv.server)
		
	end	
	
	serv.update=function()
		doreceive()
	end

	serv.clients_data={}
	serv.client_connected=function(client)
		local it={}
		it.client=client
		serv.clients_data[client]=it
	end
	serv.client_disconnected=function(client)
		local it=serv.clients_data[client]
		serv.clients_data[client]=nil
	end
	serv.client_disconnect=function(client)
		client:close()
		serv.connections:remove(input)
		serv.client_disconnected(client)
	end
	serv.client_data=function(client,data)
		local it=serv.clients_data[client]
		it.data=data
		
		dprint(it)
		
		client:send("200\r\n\r\n"..wstr.dump(it)) -- test 
		
		serv.client_disconnect(client) -- and disconnect afterwards
	end

	
	return serv
end

