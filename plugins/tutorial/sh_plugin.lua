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

resource.AddFile("materials/experiment-redux/illustrations/apartment.png")
resource.AddFile("materials/experiment-redux/illustrations/death.png")
resource.AddFile("materials/experiment-redux/illustrations/generator.png")
resource.AddFile("materials/experiment-redux/illustrations/gradient.png")
resource.AddFile("materials/experiment-redux/illustrations/lockers.png")
resource.AddFile("materials/experiment-redux/illustrations/raiding.png")
resource.AddFile("materials/experiment-redux/illustrations/scavenging.png")
resource.AddFile("materials/experiment-redux/illustrations/the-business.png")
resource.AddFile("materials/experiment-redux/illustrations/vignette.png")

function PLUGIN:OnCharacterCreated(client, character)
	local inventory = character:GetInventory()
	inventory:Add("tutorial", 1)
end
