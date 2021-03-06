-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(basket,fight)
	fight=fight or {}
	fight.modname=M.modname


--[[

air  evade water smother fire  burn   earth absorb  meta control

fire burn  air   evade   earth absorb water smother meta control

     air
     / \
fire     earth
    |   |
meta  -  water



wheel values, 0 to 1 where 0 and 1 are the same value

these are compared and produce a relative wheel value that goes

	0.5
	
0		1
	
	0.5



earth=0.0	-- absorbs
fire =0.2	-- burns
water=0.4	-- smothers
air  =0.6   -- evades
magic=0.8   -- controls

stone   =0.000
paper   =0.333
scissors=0.666

so

	
0.5 + (((a-b)*2)%1)

kinda ish

]]



--
-- get the amount of damage, done by this char with their currently welded weapon
--
-- weapon will have a min-max damage amount we randoml pick an integer between these two numbers
--
	function fight.get_damage_char(c)

		local mn,mx=get_dam(c)
		local num=0
		
		if mx<=mn then
			num=mn
		else
			num=math.random(mn,mx)
		end
		
		return math.floor(num)
	end

	function fight.get_dam(c)

		local mn=c.is.dam_min
		local mx=c.is.dam_max
		
		if c.items then -- equipment
			for v,b in pairs(c.items) do
				if v.equiped and v.is.dam_min and v.is.dam_max then
					mn=mn+v.is.dam_min
					mx=mx+v.is.dam_max
				end
			end
		end
		
		return mn,mx
	end

	function fight.get_def(c)

		local ma=c.is.def_add
		local mm=c.is.def_mul
		
		if c.items then -- equipment
			for v,b in pairs(c.items) do
				if v.equiped and v.is.def_add and v.is.def_mul then
					ma=ma+v.is.def_add
					mm=mm*v.is.def_mul
				end
			end
		end
		return ma,mm
		
	end

--
-- adjust the damage by this chars defense abilities, return the new damage number
--
	function fight.adjust_defense_char(c,damage)

		local ma,mm=get_def(c)

		damage=(damage+ma)*mm
		
		return math.floor(damage)
		
	end


--
-- c1 hits c2 with the weapon in hand
--
-- adjust hitpoints trigger events etc etc
--
	function fight.hit(c1,c2)

		local damage=get_damage_char(c1)
		
		damage=adjust_defense_char(c2,damage)
		
		local hp=c2.hp

	dbg(c2.name.." hp : "..c2.hp)
		
		hp=hp-damage
		
		if hp<=0 then -- dead
			
		
			if c1.is.player then
			
				c1.level.add_msg("You hit for "..damage.." damage!")
				c1.level.add_msg("You killed "..(c2.is.desc)..".")--" and won "..c2.is.score.." points!")
	--			c1.is.score=c1.is.score+c2.is.score
				
			elseif c2.is.player then

				c1.level.add_msg("You took "..damage.." damage from "..(c1.is.desc).." and died!")
				
			end
			
			c2.hp=0
			c2.die()
		
		else -- just hit
		
			c2.hp=hp
			
			if c1.is.player then
			
				c1.level.add_msg("You hit for "..damage.." damage!")
				
			elseif c2.is.player then

				c1.level.add_msg("You took "..damage.." damage from "..(c1.is.desc).." and now have "..c2.hp.." health!")
				
			end
			
		end

	end

--
-- restore some hitpoints for c1
--
-- adjust hitpoints trigger events etc etc
--
	function fight.heal(c1,n)

		c1.hp=c1.hp+n
		
		if c1.hp>c1.is.hp then c1.hp=c1.is.hp end
		
	end

	return fight
end
