-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local pack=require("wetgenes.pack")
local wwin=require("wetgenes.win")
local wstr=require("wetgenes.string")
local tardis=require("wetgenes.tardis")	-- matrix/vector math

module(...)

local ps3=true

bake=function(game)
	local js={}
	game.js=js

-- convert this message into something the game can understand
	js.msg=function(m)
	
		function pset(n,v)
			game.input.volatile[n]=v
		end

		if m.class=="key" then
		
			for i,v in ipairs{"up","down","left","right"} do
				if m.keyname==v then
					pset("p1_"..v,m.action==1)
				end
			end
			if m.keyname=="control_r" or m.keyname=="rcontrol" or m.keyname=="space" then
				pset("p1_".."fire",m.action==1)
			end
			
		elseif m.class=="posix_keyboard" then
		
--			print(m.type,m.code,m.value)

				if m.type==1 then
					for i,v in ipairs{
						{103,"p1_up"},		-- curser keys + right ctrl to shoots
						{108,"p1_down"},
						{105,"p1_left"},						
						{106,"p1_right"},
						{97,"p1_fire"},
						
						{72,"p2_up"},		-- number pad curser keys + enter to shoot
						{80,"p2_down"},
						{75,"p2_left"},						
						{77,"p2_right"},
						{96,"p2_fire"},
						
						{17,"p3_up"},		-- wasd + left alt to shoot
						{31,"p3_down"},
						{30,"p3_left"},						
						{32,"p3_right"},
						{56,"p3_fire"},
						
						} do
						if m.code==v[1] then
							if m.value==0 then
								pset(v[2],false)
							elseif m.value==1 then
								pset(v[2],true)
							end
						end
					end
				end


		elseif m.class=="posix_joystick" then
		
			local pfix="p"..(m.posix_device.fd_device+1).."_"
			
			if m.posix_device.name=="Sony PLAYSTATION(R)3 Controller" then
				if m.type==1 then
					for i,v in ipairs{
						{292,"up"},		-- pad
						{293,"right"},
						{294,"down"},
						{295,"left"},
						
						{296,"down"},	-- triggers
						{297,"up"},
						{298,"down"},
						{299,"up"},
						
						{300,"fire"},	-- buttons ^,O,X,[]
						{301,"fire"},
						{302,"fire"},
						{303,"fire"},

						{288,"fire"},	-- start
						{303,"fire"},	-- select
						} do
						if m.code==v[1] then
							if m.value==0 then
								pset(pfix..v[2],false)
							else
								pset(pfix..v[2],true)
							end
						end
					end
				end
			else
				if m.type==1 then
					for i,v in ipairs{
						{292,"down"},	-- triggers
						{293,"up"},
						{294,"down"},
						{295,"up"},
						
						{288,"fire"},	-- buttons ^,O,X,[]
						{289,"fire"},
						{290,"fire"},
						{291,"fire"},

						{296,"fire"},	-- start
						{297,"fire"},	-- select
						} do
						if m.code==v[1] then
							if m.value==0 then
								pset(pfix..v[2],false)
							else
								pset(pfix..v[2],true)
							end
						end
					end
				elseif m.type==3 then
					if m.code==0 then -- left right
						if m.value<64 then
							pset(pfix.."left",true)
							pset(pfix.."right",false)
						elseif m.value>192 then
							pset(pfix.."left",false)
							pset(pfix.."right",true)
						else
							pset(pfix.."left",false)
							pset(pfix.."right",false)
						end
					elseif m.code==1 then -- left right
						if m.value<64 then
							pset(pfix.."up",true)
							pset(pfix.."down",false)
						elseif m.value>192 then
							pset(pfix.."up",false)
							pset(pfix.."down",true)
						else
							pset(pfix.."up",false)
							pset(pfix.."down",false)
						end
					end
				end
--			print(m.type,m.code,m.value)
			end
		end
	end

	return js
end

