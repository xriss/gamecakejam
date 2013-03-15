-- copy all globals into locals, some locals are prefixed with a G to reduce name clashes
local coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,Gload,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require=coroutine,package,string,table,math,io,os,debug,assert,dofile,error,_G,getfenv,getmetatable,ipairs,load,loadfile,loadstring,next,pairs,pcall,print,rawequal,rawget,rawset,select,setfenv,setmetatable,tonumber,tostring,type,unpack,_VERSION,xpcall,module,require

local wstr=require("wetgenes.string")

--module
local M={ modname=(...) } ; package.loaded[M.modname]=M

M.bake=function(basket,menu)
	menu=menu or {}
	menu.modname=M.modname
	
local yarn_canvas=basket.rebake("yarn.canvas")
local yarn_fight=basket.rebake("yarn.fight")


	menu.stack={}

	menu.dirty=0
	menu.cursor=0
	
	-- set a menu to display
	function menu.show(top)
	
		if #menu.stack>0 then
			menu.stack[#menu.stack].cursor=menu.cursor -- remember cursor position
		end

		menu.stack[#menu.stack+1]=top --push
		
		if top.call then top.call(top) end -- refresh
		
		menu.display=top.display
		menu.cursor=top.cursor or 1
		
		menu.dirty=1
	end
	
	-- go back to the previous menu
	function menu.back()

		menu.stack[#menu.stack]=nil -- this was us
		
		if #menu.stack==0 then return menu.hide() end -- clear all menus
		
		local top=menu.stack[#menu.stack] -- pop up a menu
		
		if top.call then top.call(top) end -- refresh
		
		menu.display=top.display
		menu.cursor=top.cursor or 1
		
		menu.dirty=1
	end
	
	-- stop showing all menus and clear the stack

	function menu.hide()
		menu.stack={}
		menu.display=nil
		menu.dirty=1
	end


	function menu.msg(m)

--print(wstr.dump(m))
	
		if not menu.display then return end

		menu.dirty=1

		local getmenuitem=function()
			local tab=menu.display[ menu.cursor ]		
			if tab and tab.tab then tab=tab.tab end -- use this data
			return tab
		end

		local tab=getmenuitem()

		if m.class=="key" then
			if m.action==1 --[[or m.action==0]] then -- down or repeat
			
				if m.keyname=="space" or m.keyname=="enter"  or m.keyname=="return" then
				
					if tab.call then -- do this
					
						tab.call( tab )
						
					else -- just back by default
					
						menu.back()
					
					end
				
				elseif m.keyname=="back" then
				
					menu.hide()
				
				elseif m.keyname=="up" then
				
					local cacheid=getmenuitem()
					repeat
						menu.cursor=menu.cursor-1
					until menu.cursor<1 or getmenuitem()~=cacheid
					
					if menu.cursor<1 then menu.cursor=#menu.display end --wrap

					local cacheid=getmenuitem() -- move to top of item
					while menu.cursor>0 and cacheid==getmenuitem() do
						menu.cursor=menu.cursor-1
					end
					menu.cursor=menu.cursor+1

				
				elseif m.keyname=="down" then
					
					local cacheid=getmenuitem()
					repeat
						menu.cursor=menu.cursor+1
					until menu.cursor>#menu.display or getmenuitem()~=menu.cacheid
					
					if menu.cursor>#menu.display then menu.cursor=1 end --wrap
				
				end
			
			end

			return true -- we ate it
		end

	end

	-- display a menu
	function menu.update()
	
		local t=menu.dirty
		menu.dirty=0
		
		return t
	end
	
	-- display a menu
	function menu.draw()
		if not menu.display then return end
		
		local top=menu.stack[#menu.stack]

		yarn_canvas.draw_box(0,0,40,#menu.display+4)
--		yarn_canvas.draw_fill(0,#display+4,40,1)
		
		if top.title then
			local title=" "..(top.title:upper()).." "
			local wo2=math.floor(#title/2)
			yarn_canvas.print(20-wo2,0,title)
		end
		
		for i,v in ipairs(menu.display) do
			yarn_canvas.print(2,i+1,v.s)
		end
		
		yarn_canvas.print(1,menu.cursor+1,">")
		
	end

	-- build a requester
	function menu.build_request(t)
	
-- t[1++].text is the main body of text, t[1++].use is a call back function if this is
-- selectable, if there is no callback then selecting that option just hides the menu

		local lines={}
		local pos=1
		for id=1,#t do
			local ls=wstr.smart_wrap(t[id].text,40-4)
			for i=1,#ls do lines[#lines+1]={s=ls[i],id=id,tab=t[id]} end
		end
		
		return lines
	end


	function menu.show_test()
		local top={}
		top.title="look around you"
		top.display=menu.build_request({
			{text="plops1"},
			{text="plops2"},
			})
		menu.show(top)
	end
	
	function menu.show_player_menu(player)
print("show player")

		local top={}
		
		top.title="look around you"

		top.call=function(tab)
		
			local tab={}
			
	-- add cancel option
			tab[#tab+1]={
				text=[[..]],
				call=function(t)
					menu.back()
				end
			}
			
	-- add equiped item option
			tab[#tab+1]={
				text=[[your tools]],
				call=function(t)
					menu.show_tool_menu(player)
				end
			}
	-- add backpack option
			tab[#tab+1]={
				text=[[your loots]],
				call=function(t)
					menu.show_loot_menu(player)
				end
			}
			
			local items={}
			if player.cell then
				for i,v in player.cell.neighboursplus() do
					for item,b in pairs(v.items) do
						items[#items+1]=item
					end				
				end
			end
--print("use",items,#items)	
			for i,v in ipairs(items) do
				if v.is.can.acts or v.form=="item"then				
					tab[#tab+1]={
						text=v.desc_text(),
						call=function(t)
							menu.show_item_menu(v)
						end
					}
				end
			end
			

			top.display=menu.build_request(tab)
		end
		
print("show player top")
		menu.show(top)
	end


	function menu.show_tool_menu(player)
		local top={}
		
		top.title="your tools"
		
		top.call=function(tab)
		
			local tab={}
			
-- add cancel option
			tab[#tab+1]={
				text=[[..]],
				call=function(t)
					menu.back()
				end
			}
			
-- add status option
			tab[#tab+1]={
				text="your status ( "..(player.hp or 0).."/"..(player.is.hp or 0).." hp )",
				call=function(t)
					menu.show_status_menu(player)
				end
			}
			
			local items={}
			for v,b in pairs(player.items or {}) do
				if v.is.equiped then
					items[#items+1]=v
				end
			end
			
			table.sort(items,function(a,b) return a.is.name<b.is.name end)
			
			for i,v in ipairs(items) do
				if v.is.can.acts or v.is.form=="item"then				
					tab[#tab+1]={
						text=v.desc_text(),
						call=function(t)
							menu.show_item_menu(v)
						end
					}
				end
			end
						
			top.display=menu.build_request(tab)
		end
		
		menu.show(top)
	end

	function menu.show_loot_menu(player)
		local top={}
		
		top.title="your loots"
		
		top.call=function(tab)
		
			local tab={}
			
-- add cancel option
			tab[#tab+1]={
				text=[[..]],
				call=function(t)
					menu.back()
				end
			}
			
			local items={}
			for v,b in pairs(player.items or {}) do
				if not v.is.equiped then
					items[#items+1]=v
				end
			end
			
			table.sort(items,function(a,b) return a.is.name<b.is.name end)
			
			for i,v in ipairs(items) do
				if v.is.can.acts or v.form=="item"then				
					tab[#tab+1]={
						text=v.desc_text(),
						call=function(t)
							menu.show_item_menu(v)
						end
					}
				end
			end

			top.display=menu.build_request(tab)
		end
		
		menu.show(top)
	end

	function menu.show_status_menu(item)
		local top={}

		top.title=item.desc_text()
		


		top.call=function(tab)
		
			local tab={}
			local player=basket.player
			
			local dam_min,dam_max=yarn_fight.get_dam(player)
			local def_add,def_mul=yarn_fight.get_def(player)

			local ss={}
			ss[#ss+1]=(player.hp or 0).."/"..(player.is.hp or 0).." hp"		
			if (dam_min and dam_min~=0) or (dam_max and dam_max~=0) then
				ss[#ss+1]="\n"
				ss[#ss+1]="damage "..math.floor(dam_min).." to "..math.floor(dam_max).."\n"
			end
			if (def_add and def_add~=0) or (def_mul and def_mul~=1) then
				ss[#ss+1]="\n"
				ss[#ss+1]="protection "..math.floor(-def_add).." and "..math.floor(100*(1-def_mul)).."% damage\n"
			end
			local s=table.concat(ss)

	-- add cancel option
			tab[#tab+1]={
				text=[[..]],
				call=function(t)
					menu.back()
				end
			}
-- add status option
			tab[#tab+1]={
				text=s,
				call=function(t)
					menu.back()
				end
			}
			
			top.display=menu.build_request(tab)
		end
		
		menu.show(top)
	end
	
	function menu.show_item_menu(item)
		local top={}

		if type(item.is.can.acts)=="function" then
			local acts=item.is.can.acts(item,basket.player)
			if #acts==1 then
				item.is.can[ acts[1] ](item,basket.player)
				return
			end
		end
		
		top.title=item.desc_text()
		
		top.call=function(tab)
		
			local tab={}
			local player=basket.player
	-- add cancel option
			tab[#tab+1]={
				text=[[..]],
				call=function(t)
					menu.back()
				end
			}
			

			if type(item.is.can.acts)=="function" then
				local acts=item.is.can.acts(item,player)
				
--				if #acts==1 and type( item.is.can[ acts[1] ] )=="function" then -- just do it as it is the only possible act?
--					item.is.can[ acts[1] ](item,player)
--					return
--				else
					for i,v in ipairs(acts) do
						tab[#tab+1]={
							text=v,
							call=function(t)
								if type(item.is.can[v])=="function" then
									item.is.can[v](item,player)
								end
							end
						}
					end
--				end
			end

			top.display=menu.build_request(tab)
		end
		
		menu.show(top)
	end

	function menu.show_stairs_menu(item,by)
		local main=basket
		local top={}

		local goto_level=function(name,pow)
		
			main.soul.last_stairs=item.name
dbg("saving stairs name : "..item.name)

			main.save()
			main.level.player.un_cell()
			main.level=main.level.destroy()
			main.level=yarn_levels.create(yarn_attrs.get(name,pow,{xh=40,yh=28}),main)
			main.menu.hide()

-- mark this new area as visited
			main.soul.visited=main.soul.visited or {}
			main.soul.visited[name]=main.soul.visited[name] or {}
			main.soul.visited[name][pow]=true
			

		end
		
		top.title=item.desc_text()
		
		top.call=function(tab)
		
			local tab={}
			local player=basket.player
	-- add cancel option
			tab[#tab+1]={
				text=[[..]],
				call=function(t)
					menu.back()
				end
			}

			tab[#tab+1]={
				text="town (0)",
				call=function()
					menu.goto_level("level.town",0)
				end
			}
			
			for i=item.stairs_min,item.stairs_max do
			
				local show=false
				local lnam="level."..item.stairs
dbg(lnam)
dbg(basket.level.name)
dbg(basket.level.pow)
				if  ( main.soul.visited and
					main.soul.visited[lnam] ) then
					for i,v in pairs(main.soul.visited[lnam]) do
						dbg(tostring(i).." : "..tostring(v))
					end
				end
				if i<=1 then show=true end -- first level is always available
				
				if basket.level.name == lnam then
					if i<=basket.level.pow+1 and i>=basket.level.pow-1 then
						show=true -- one up/down 1 are always available
					end
				end

				local level_info=yarn_attrs.get("level."..item.stairs,i) -- get base info about the level

				if  ( main.soul.visited and
					main.soul.visited[lnam] and
					main.soul.visited[lnam][i] ) or level_info.best_score then
					show=true
				end

				
				if show then
					if level_info.best_score then
						basket.soul.best_score=basket.soul.best_score or {}
						level_info.best_score=basket.soul.best_score["level."..item.stairs.."."..i] or level_info.best_score
					end
					local name=strings.replace(level_info.desc,level_info)
					
					tab[#tab+1]={
						text=name,
						call=function()
							menu.goto_level("level."..item.stairs,i)
						end
					}
				end
			end
			
			top.display=menu.build_request(tab)
		end
		
		menu.show(top)
	end
	
	function menu.show_talk_menu(item,by,chatname)
		chatname=chatname or "welcome"
		local top={}
		local chat=item.is.chat and item.is.chat[chatname]
		if not chat then return menu.hide() end
		if type(chat)=="function" then chat=chat(item,by,chatname) end
		
		if chat.flag then
			basket.level.is[chat.flag]=true
		end
		
		top.title=wstr.replace(chat.title or item.desc_text(),menu)
		
		top.call=function(tab)
		
			local tab={}
			local player=basket.player
	-- add cancel option?

			tab[#tab+1]={
				text=wstr.trim(wstr.replace(chat.text,item)).."\n\n", -- keep one blank line at end
				call=function()
					menu.hide()
				end
			}

			local cursor=#tab+1
			
			for i,v in ipairs(chat.says) do
				local t=type(v)
				local text,cal
				local showsay=true
				if t=="function" then -- call a function to return the string or table
					t=t(item,by)
				end
				if t=="string" then
					text="\""..wstr.replace(v,item).."\""
					cal=function() menu.show_talk_menu(item,by,v) end
				elseif t=="table" then
					text="\""..wstr.replace(v.text,item).."\""
					cal=function() menu.show_talk_menu(item,by,v.say) end
					if v.test then
						if basket.level.is[v.test] then
							showsay=true
						else
							showsay=false
						end
					end
				end
				if showsay then
					tab[#tab+1]={
						text=text,
						call=cal
					}
				end
			end
			
			top.display=menu.build_request(tab)
			for i,v in ipairs(top.display) do
				if v.id==cursor then
					top.cursor=i
					break
				end
			end
		end
		
		menu.show(top)
	end
	
	function menu.show_text(title,display)
		local top={}

		local tab={}
-- add cancel option
		tab[#tab+1]={
			text=[[..]],
			call=function(t)
				menu.back()
			end
		}
			
		tab[#tab+1]={
			text=display,
			call=function(t)
				menu.hide()
			end
		}

		top.title=title
		top.display=menu.build_request(tab)
		top.cursor=2
		
		menu.show(top)
	end
	

	return menu
end
