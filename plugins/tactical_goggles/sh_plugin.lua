local PLUGIN = PLUGIN

PLUGIN.name = "Tactical Goggles"
PLUGIN.author = "Experiment Redux"
PLUGIN.description = "Adds Tactical Goggles that show additional information about companions on your frequency."

ix.util.Include("sv_meta.lua")
ix.util.Include("sv_hooks.lua")
ix.util.Include("cl_hooks.lua")
ix.util.Include("cl_plugin.lua")

function PLUGIN:InitializedPlugins()
	local dependency = ix.plugin.Get("radioing")

	if (not dependency) then
		ix.util.SchemaErrorNoHalt("The Tactical Goggles plugin requires the Radioing plugin to function.\n")
		return
	end
end

local playerMeta = FindMetaTable("Player")

function playerMeta:HasTacticalGogglesActivated()
	return self:GetCharacterNetVar("tacticalGoggles", false)
end
