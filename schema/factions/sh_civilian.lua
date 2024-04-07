FACTION.name = "Citizen"
FACTION.description = "A test subject, living in this city."
FACTION.color = Color(150, 125, 100, 255)
FACTION.isDefault = true
FACTION.pay = 100
FACTION.payTime = 300

function FACTION:OnCharacterCreated(client, character)
	local inventory = character:GetInventory()

	inventory:Add("suitcase", 1)
end

FACTION_CIVILIAN = FACTION.index
