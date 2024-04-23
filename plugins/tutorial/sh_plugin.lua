local PLUGIN = PLUGIN

PLUGIN.name = "Tutorial"
PLUGIN.author = "Experiment Redux"
PLUGIN.description = "Introduce new players to the server."

ix.lang.AddTable("english", {
	optShowTutorial = "Show Tutorial",
	optdShowTutorial = "Show the tutorial hints, intended for new players.",
})

ix.util.Include("cl_plugin.lua")

if (not SERVER) then
	return
end

function PLUGIN:OnCharacterCreated(client, character)
	local inventory = character:GetInventory()
	inventory:Add("tutorial", 1)
end
