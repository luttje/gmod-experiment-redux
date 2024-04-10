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

	-- Balance recoil, damage and other features
	["tacrp_mult_recoil_kick"] = { isServer = true, value = 0.75 },
	["tacrp_mult_recoil_vis"] = { isServer = true, value = 0.5 },
	["sway"] = { isServer = true, value = false }, -- false disables: Weapon point of aim will move around gently. While aiming, hold sprint key to hold breath and steady aim
	["tacrp_freeaim"] = { isServer = true, value = false }, -- false disables: While not aiming, moving around will cause the crosshair to move off center
	-- ["tacrp_physbullet"] = false, -- false disables: Bullets will be hitscan up to a certain range depending on muzzle velocity
	-- ["tacrp_recoilpattern"] = false,
	-- ["tacrp_altrecoil"] = false, -- false disables: If enabled, gaining bloom intensifies recoil but does not modify spread.\nIf disabled, gaining bloom increases spread but does not modify recoil kick (old behavior).\nBloom is gained when firing consecutive shots.
	-- ["tacrp_mult_damage"] = 0.5,
	-- ["tacrp_mult_damage_magnum"] = 0.8,
	-- ["tacrp_mult_damage_sniper"] = 0.8,
	-- ["tacrp_mult_damage_shotgun"] = 0.8,
	-- ["tacrp_mult_damage_explosive"] = 0.5,
	-- ["tacrp_penalty_reload"] = false,
	-- ["tacrp_penalty_melee"] = false,
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
