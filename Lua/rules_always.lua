function code(alreadyrun_)
	local playrulesound = false
	local alreadyrun = alreadyrun_ or false
	poweredstatus = {}
	
	if (updatecode == 1) then
		HACK_INFINITY = HACK_INFINITY + 1
		--MF_alert("code being updated!")
		
		if generaldata.flags[LOGGING] then
			logrulelist.new = {}
		end
		
		MF_removeblockeffect(0)
		wordrelatedunits = {}
		
		do_mod_hook("rule_update",{alreadyrun})
		
		if (HACK_INFINITY < 200) then
			local checkthese = {}
			local wordidentifier = ""
			wordunits,wordidentifier,wordrelatedunits = findwordunits()
			local wordunitresult = {}
			
			if (#wordunits > 0) then
				for i,v in ipairs(wordunits) do
					if testcond(v[2],v[1]) then
						wordunitresult[v[1]] = 1
						table.insert(checkthese, v[1])
					else
						wordunitresult[v[1]] = 0
					end
				end
			end
			
			features = {}
			featureindex = {}
			condfeatureindex = {}
			visualfeatures = {}
			notfeatures = {}
			groupfeatures = {}
			
			local firstwords = {}
			local alreadyused = {}
			
			do_mod_hook("rule_baserules")
			
			for i,v in ipairs(baserulelist) do
				addbaserule(v[1],v[2],v[3],v[4])
			end
			
			formlettermap()
			
			if (#codeunits > 0) then
				for i,v in ipairs(codeunits) do
					table.insert(checkthese, v)
				end
			end
		
			if (#checkthese > 0) or (#letterunits > 0) then
				for iid,unitid in ipairs(checkthese) do
					local unit = mmf.newObject(unitid)
					local x,y = unit.values[XPOS],unit.values[YPOS]
					local ox,oy,nox,noy = 0,0
					local tileid = x + y * roomsizex

					setcolour(unit.fixed)
					
					if (alreadyused[tileid] == nil) and (unit.values[TYPE] ~= 5) and (unit.flags[DEAD] == false) then
						for i=1,2 do
							local drs = dirs[i+2]
							local ndrs = dirs[i]
							ox = drs[1]
							oy = drs[2]
							nox = ndrs[1]
							noy = ndrs[2]
							
							--MF_alert("Doing firstwords check for " .. unit.strings[UNITNAME] .. ", dir " .. tostring(i))
							
							local hm = codecheck(unitid,ox,oy,i,nil,wordunitresult)
							local hm2 = codecheck(unitid,nox,noy,i,nil,wordunitresult)
							
							if (#hm == 0) and (#hm2 > 0) then
								--MF_alert("Added " .. unit.strings[UNITNAME] .. " to firstwords, dir " .. tostring(i))
								
								table.insert(firstwords, {{unitid}, i, 1, unit.strings[UNITNAME], unit.values[TYPE], {}})
								
								if (alreadyused[tileid] == nil) then
									alreadyused[tileid] = {}
								end
								
								alreadyused[tileid][i] = 1
							end
						end
					end
				end
				
				--table.insert(checkthese, {unit.strings[UNITNAME], unit.values[TYPE], unit.values[XPOS], unit.values[YPOS], 0, 1, {unitid})
				
				for a,b in pairs(letterunits_map) do
					for iid,data in ipairs(b) do
						local x,y,i = data[3],data[4],data[5]
						local unitids = data[7]
						local width = data[6]
						local word,wtype = data[1],data[2]
						
						local unitid = unitids[1]
						
						local tileid = x + y * roomsizex
						
						if (alreadyused[tileid] == nil) or ((alreadyused[tileid] ~= nil) and (alreadyused[tileid][i] == nil)) then
							local drs = dirs[i+2]
							local ndrs = dirs[i]
							ox = drs[1]
							oy = drs[2]
							nox = ndrs[1] * width
							noy = ndrs[2] * width
							
							local hm = codecheck(unitid,ox,oy,i)
							local hm2 = codecheck(unitid,nox,noy,i)
							
							if (#hm == 0) and (#hm2 > 0) then
								-- MF_alert(word .. ", " .. tostring(width))
								
								table.insert(firstwords, {unitids, i, width, word, wtype, {}})
								
								if (alreadyused[tileid] == nil) then
									alreadyused[tileid] = {}
								end
								
								alreadyused[tileid][i] = 1
							end
						end
					end
				end
				
				docode(firstwords,wordunits)
				---------------------------------------------------------
				loadpermanentrules()
				---------------------------------------------------------
				subrules()
				grouprules()
				playrulesound = postrules(alreadyrun)
				updatecode = 0
				
				local newwordunits,newwordidentifier,wordrelatedunits = findwordunits()
				
				--MF_alert("ID comparison: " .. newwordidentifier .. " - " .. wordidentifier)
				
				if (newwordidentifier ~= wordidentifier) then
					updatecode = 1
					code(true)
				else
					--domaprotation()
				end
			end
		else
			MF_alert("Level destroyed - code() run too many times")
			destroylevel("infinity")
			return
		end
		
		if (alreadyrun == false) then
			effects_decors()
			
			if (featureindex["broken"] ~= nil) then
				brokenblock(checkthese)
			end
			
			if (featureindex["3d"] ~= nil) then
				updatevisiontargets()
			end
			
			if generaldata.flags[LOGGING] then
				updatelogrules()
			end
		end
		
		do_mod_hook("rule_update_after",{alreadyrun})
	end
	
	if (alreadyrun == false) then
		local rulesoundshort = ""
		alreadyrun = true
		if playrulesound and (generaldata5.values[LEVEL_DISABLERULEEFFECT] == 0) then
			local pmult,sound = checkeffecthistory("rule")
			rulesoundshort = sound
			local rulename = "rule" .. tostring(math.random(1,5)) .. rulesoundshort
			MF_playsound(rulename)
		end
	end
end

function addoption(option,conds_,ids,visible,notrule,tags_)
	--MF_alert(option[1] .. ", " .. option[2] .. ", " .. option[3])
	
	local visual = true
	
	if (visible ~= nil) then
		visual = visible
	end
	
	local conds = {}
	
	if (conds_ ~= nil) then
		conds = conds_
	else
		MF_alert("nil conditions in rule: " .. option[1] .. ", " .. option[2] .. ", " .. option[3])
	end
	
	local tags = tags_ or {}
	
	if (#option == 3) then
		local rule = {option,conds,ids,tags}
		local hasalwayscond = false
		------------------------------------------------------------------------------
		local soft_rule = {option, {}, ids, tags}
		for i,cond in ipairs(conds) do
			if (cond[1] ~= "always" and cond[1] ~= "not always") then
				table.insert(soft_rule[2], cond)
			else
				hasalwayscond = true
			end
		end
		local short_rule = {soft_rule[1], soft_rule[2]}

		for i, tag in ipairs(tags) do
			if (tag == "mimic") then
				if (hasalwayscond) then
					return
				end
				rule = soft_rule
			end
		end
		------------------------------------------------------------------------------
		table.insert(features, rule)
		local target = option[1]
		local verb = option[2]
		local effect = option[3]
	
		if (featureindex[effect] == nil) then
			featureindex[effect] = {}
		end
		
		if (featureindex[target] == nil) then
			featureindex[target] = {}
		end
		
		if (featureindex[verb] == nil) then
			featureindex[verb] = {}
		end
		
		table.insert(featureindex[effect], rule)
		table.insert(featureindex[verb], rule)
		
		if (target ~= effect) then
			table.insert(featureindex[target], rule)
		end
		
		if visual then
			local visualrule = copyrule(rule)
			table.insert(visualfeatures, visualrule)
		end
		
		local groupcond = false
		
		if (string.sub(target, 1, 5) == "group") or (string.sub(effect, 1, 5) == "group") or (string.sub(target, 1, 9) == "not group") or (string.sub(effect, 1, 9) == "not group") then
			groupcond = true
		end
		
		if (notrule ~= nil) then
			local notrule_effect = notrule[1]
			local notrule_id = notrule[2]
			
			if (notfeatures[notrule_effect] == nil) then
				notfeatures[notrule_effect] = {}
			end
			
			local nr_e = notfeatures[notrule_effect]
			
			if (nr_e[notrule_id] == nil) then
				nr_e[notrule_id] = {}
			end
			
			local nr_i = nr_e[notrule_id]
			
			table.insert(nr_i, rule)
		end
		
		if (#conds > 0) then
			local addedto = {}
			
			for i,cond in ipairs(conds) do

				local condname = cond[1]
				local perm_change = false
				------------------------------------
				if (condname == "always") then
					perm_change = worldpermanentrule(short_rule)
				
				elseif (condname == "not always") then
					perm_change = deletepermanentrule(short_rule)
				end
				-------------------------------------------------------------
				if (perm_change) then
					MF_playsound("bonus")

					for a,d in ipairs(ids) do
						for c,b in ipairs(d) do
							local bunit = mmf.newObject(b)
							local x,y = bunit.values[XPOS],bunit.values[YPOS]
							local c1,c2 = getcolour(b,"active")
							MF_particles_for_unit("bonus",x,y,5,c1,c2,1,1,b)
						end
					end
				end
				-------------------------------------------------------------
				-------------------------------------

				if (string.sub(condname, 1, 4) == "not ") then
					condname = string.sub(condname, 5)
				end
				
				if (condfeatureindex[condname] == nil) then
					condfeatureindex[condname] = {}
				end
				
				if (addedto[condname] == nil) then
					table.insert(condfeatureindex[condname], rule)
					addedto[condname] = 1
				end
				
				if (cond[2] ~= nil) then
					if (#cond[2] > 0) then
						local newconds = {}
						
						--alreadyused[target] = 1
						
						for a,b in ipairs(cond[2]) do
							local alreadyused = {}
							
							if (b ~= "all") and (b ~= "not all") then
								alreadyused[b] = 1
								table.insert(newconds, b)
							elseif (b == "all") then
								for a,mat in pairs(objectlist) do
									if (alreadyused[a] == nil) and (findnoun(a,nlist.short) == false) then
										table.insert(newconds, a)
										alreadyused[a] = 1
									end
								end
							elseif (b == "not all") then
								table.insert(newconds, "empty")
								table.insert(newconds, "text")
							end
							
							if (string.sub(b, 1, 5) == "group") or (string.sub(b, 1, 9) == "not group") then
								groupcond = true
							end
						end
						
						cond[2] = newconds
					end
				end
			end
		end
		
		if groupcond then
			---------------------------------------
			table.insert(groupfeatures, soft_rule)
			---------------------------------------
		end

		local targetnot = string.sub(target, 1, 4)
		local targetnot_ = string.sub(target, 5)
		
		if (targetnot == "not ") and (objectlist[targetnot_] ~= nil) and (string.sub(targetnot_, 1, 5) ~= "group") and (string.sub(effect, 1, 5) ~= "group") and (string.sub(effect, 1, 9) ~= "not group") or (((string.sub(effect, 1, 5) == "group") or (string.sub(effect, 1, 9) == "not group")) and (targetnot_ == "all")) then
			if (targetnot_ ~= "all") then
				for i,mat in pairs(objectlist) do
					if (i ~= targetnot_) and (findnoun(i) == false) then
						local rule = {i,verb,effect}
						local newconds = {}
						for a,b in ipairs(conds) do
							table.insert(newconds, b)
						end
						addoption(rule,newconds,ids,false,{effect,#featureindex[effect]},tags)
					end
				end
			else
				local mats = {"empty","text"}
				
				for m,i in pairs(mats) do
					local rule = {i,verb,effect}
					local newconds = {}
					for a,b in ipairs(conds) do
						table.insert(newconds, b)
					end
					addoption(rule,newconds,ids,false,{effect,#featureindex[effect]},tags)
				end
			end
		end
	end
end
