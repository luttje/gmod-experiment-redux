local PLUGIN = PLUGIN

PLUGIN.name = "TODO"
PLUGIN.author = "Experiment Redux"
PLUGIN.description = "Move these entities to their own plugins."

PLUGIN.doorProtectorRange = 256

ix.util.Include("sv_hooks.lua")
ix.util.Include("sv_plugin.lua")

function PLUGIN:IsDoorHitPointVulnerable(entity, damagePosition)
	return entity:WorldToLocal(damagePosition):Distance(Vector(-1.0313, 41.8047, -8.1611)) <= 8
end
