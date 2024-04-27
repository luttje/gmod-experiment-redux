local PLUGIN = PLUGIN

PLUGIN.name = "Selectable Spawn Points"
PLUGIN.author = "Experiment Redux"
PLUGIN.description = "Allows players to select their spawn point from a list of available spawn points."
PLUGIN.registeredMaps = PLUGIN.registeredMaps or {}

PLUGIN.spawnStatus = {
	SAFE = 0,
	DANGER = 1,
	LOCKED = 2,
	CHAOS = 3,
}

PLUGIN.spawnResult = {
	OK = 0,
	FAIL = 1,
}

ix.util.Include("sv_plugin.lua")
ix.util.Include("cl_plugin.lua")
ix.util.Include("sh_commands.lua")

function PLUGIN:GetMapDetails()
	local maps = Schema.map.FindByProperty("mapName", game.GetMap())

	if (#maps == 0) then
		return nil
	end

	if (#maps > 1) then
		ix.util.SchemaError("Duplicate map details found for '" .. game.GetMap() .. "'!\n")
	end

	return maps[1]
end
