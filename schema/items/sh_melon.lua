local ITEM = ITEM

ITEM.name = "Melon"
ITEM.price = 30
ITEM.model = "models/props_junk/watermelon01.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Consumables"
ITEM.description = "A green fruit, it has a hard outer shell."

ITEM.functions.Eat = {
	OnRun = function(item)
		local client = item.player

		client:SetHealth(math.Clamp(client:Health() + 10, 0, 100))

		client:GetCharacter():AddBoost(item.uniqueID, "acr", 2)
		client:GetCharacter():AddBoost(item.uniqueID, "agl", 2)
		-- duration: 600
		error("TODO: Implement removing the boost after the duration is over.")
	end
}
