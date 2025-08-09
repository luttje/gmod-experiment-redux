local PLUGIN = PLUGIN

PLUGIN.name = "Tactical Goggles"
PLUGIN.author = "Experiment Redux"
PLUGIN.description = "Adds Tactical Goggles that show additional information about companions on your frequency."

PLUGIN.inventoryExpireSeconds = 15
PLUGIN.searchStareSeconds = 3

PLUGIN.boltScales = {
	{ min = 0,     max = 100,       text = "a few bolts" },
	{ min = 101,   max = 500,       text = "some bolts" },
	{ min = 501,   max = 1000,      text = "many bolts" },
	{ min = 1001,  max = 2500,      text = "a lot of bolts" },
	{ min = 2501,  max = 5000,      text = "tons of bolts" },
	{ min = 5001,  max = 9999,      text = "a small fortune in bolts" },
	{ min = 10000, max = math.huge, text = "a fortune in bolts" }
}

ix.util.Include("sv_meta.lua")
ix.util.Include("sv_hooks.lua")
ix.util.Include("sv_plugin.lua")
ix.util.Include("cl_plugin.lua")
ix.util.Include("cl_hooks.lua")

ix.lang.AddTable("english", {
	searchInventory = "Search Inventory",
	searchingInventory = "Searching inventory...",
})

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

do
	local COMMAND = {}
	COMMAND.description = "Search the inventory of the player you are looking at while wearing tactical goggles."
	COMMAND.arguments = {}

	function COMMAND:OnRun(client)
		local trace = client:GetEyeTraceNoCursor()
		local target = trace.Entity

		PLUGIN:TrySearchTargetInventory(client, target)
	end

	ix.command.Add("TacticalSearch", COMMAND)
end
