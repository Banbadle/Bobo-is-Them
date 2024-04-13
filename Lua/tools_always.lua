condlist["always"] = function(params,checkedconds,checkedconds_,cdata)
    return true,checkedconds
end

--table.insert(mod_hook_functions["rule_baserules"], loadpermanentrules)

-- Function to serialize a Lua table to a string
local function serialize(tbl)
	local str = "{"
	for k, v in pairs(tbl) do
		if type(v) == "table" then
			str = str .. serialize(v) .. ","
		elseif type(v) == "string" then
			str = str .. '"' .. v .. '",'
		elseif v == nil then
		else
			str = str .. tostring(v) .. ","
		end
	end
	str = str .. "}"
	return str
end

-- Function to deserialize a string to a Lua table
local function deserialize(str)
	return load("return " .. str)()
end

local function equiv_rule(options1, options2)
	if options1 == nil then options1 = {} end
	if options2 == nil then options2 = {} end

	if (#options1 ~= #options2) then
		return false
	end
    for key, value1 in pairs(options1) do
        local value2 = options2[key]

		if (value1 == "always" and value2 == "not always") then return true end
		if (value1 == "not always" and value2 == "always") then return true end
        
        if type(value1) ~= type(value2) then
            return false
        end

		if type(value1) == "table" then
			if not equiv_rule(value1, value2) then
				return false
			end
		elseif(value1 ~= value2) then
			return false
		end
		
	end
	return true
end

function searchpermanentrule(short_rule)
	local nextnum = get_rule_number()

	for i = 0, nextnum-1 do
		local check_rule = deserialize(MF_read("world", "permanent_rules", "rule"..tostring(i)))
		if (check_rule ~= nil) then 
			if equiv_rule(short_rule, check_rule) then
				return i
			end
		end
	end
	return -1
end

function get_rule_number()
	local nextnum = tonumber(MF_read("world", "permanent_rules", "numrules"))
	if (nextnum == nil) then
		MF_store("world", "permanent_rules", "numrules", "0")
		nextnum = 0
	end
	return nextnum
end

function worldpermanentrule(short_rule)
	local nextnum = get_rule_number()
	
	if (searchpermanentrule(short_rule) == -1) then
		MF_store("world", "permanent_rules", "rule"..tostring(nextnum), serialize(short_rule))
		MF_store("world", "permanent_rules", "numrules", tostring(nextnum+1))
		return true
	end
	return false
end

function deletepermanentrule(short_rule)
	local numrules = get_rule_number()
	local rulenum = searchpermanentrule(short_rule)
	if (rulenum ~= -1) then
		for i=rulenum, numrules-1 do
			local nextval = MF_read("world", "permanent_rules", "rule"..tostring(rulenum+1))
			MF_store("world", "permanent_rules", "rule"..tostring(rulenum), tostring(nextval))
		end
		MF_store("world", "permanent_rules", "rule"..tostring(numrules-1), "nil")
		MF_store("world", "permanent_rules", "numrules", tostring(numrules-1))
		return true
	end
	return false
end

function loadpermanentrules()
	-- Loop from startNumber to endNumber
	local numrules = tonumber(MF_read("world", "permanent_rules", "numrules"))
	numrules = numrules or 0

	for nextnum = 0, numrules do
		local short_rule = deserialize(MF_read("world", "permanent_rules", "rule"..tostring(nextnum)))
		if(short_rule ~= nil) then
			local new_options = short_rule[1]
			local new_conds = short_rule[2]
			--addbaserule(new_options[1], new_options[2], new_options[3], new_conds)
			addoption(new_options, new_conds, {}, true, nil, {"permanent"})
		end
	end
end

function soft_copyconds(target,conds)
	if (conds ~= nil) and (#conds > 0) then
		for a,cond in ipairs(conds) do
			local condtype = cond[1]
			local params = cond[2] or {}
			
			if (condtype ~= "always" and condtype ~= "not always") then
				table.insert(target, {condtype, {}})
				
				for c,param in ipairs(params) do
					table.insert(target[#target][2], param)
				end
			end
		end
	end
	
	return target
end
