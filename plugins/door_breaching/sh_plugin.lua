local PLUGIN = PLUGIN

PLUGIN.name = "Door Breaching"
PLUGIN.author = "Experiment Redux"
PLUGIN.description = "Door breaching and protection systems."

ix.util.Include("sv_hooks.lua")
ix.util.Include("sv_plugin.lua")

function PLUGIN:IsDoorHitPointVulnerable(entity, damagePosition)
	return entity:WorldToLocal(damagePosition):Distance(Vector(-1.0313, 41.8047, -8.1611)) <= 8
end
