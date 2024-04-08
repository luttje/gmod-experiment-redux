local PLUGIN = PLUGIN

PLUGIN.name = "Customizable Weaponry"
PLUGIN.author = "Experiment Redux"
PLUGIN.description = "Adds the Customizable Weaponry to the schema."

ix.util.Include("sv_plugin.lua")
ix.util.Include("cl_plugin.lua")

local conVarsToSet = {
	["tacrp_funny_loudnoises"] = { isServer = true, value = 0 },
	["tacrp_checknews"] = { isServer = true, value = 0 },
	["tacrp_hud"] = { isServer = true, value = 0 },
	["tacrp_drawhud"] = { isServer = false, value = 0 },
	["tacrp_shutup"] = { isServer = false, value = 1 },
	["tacrp_hints"] = { isServer = false, value = 0 },

	-- Note that without setting this to false the server errors in TacRP.LoadAtt.
	-- This is because Material("*.png") fails to load on the server
	-- See https://wiki.facepunch.com/gmod/Global.Material#description
	["tacrp_generateattentities"] = { isServer = true, value = false },
}

for conVarName, value in pairs(conVarsToSet) do
	if (value.isServer and not SERVER) then
		continue
	elseif (!value.isServer and not CLIENT) then
		continue
	end

    local conVar = GetConVar(conVarName)
	value = value.value

	if (!conVar) then
		ErrorNoHalt("ConVar " .. conVarName .. " does not exist in conVarsToSet.")
		continue
	end

	if (isbool(value)) then
		conVar:SetBool(value)
	elseif (isnumber(value)) then
        conVar:SetInt(value)
	elseif (isstring(value)) then
        conVar:SetString(value)
    else
		ErrorNoHalt("Invalid value type for conVar " .. conVarName .. " in conVarsToSet.")
	end
end
