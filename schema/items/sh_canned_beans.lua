local ITEM = ITEM

ITEM.name = "Canned Beans"
ITEM.price = 15
ITEM.model = "models/props_lab/jar01b.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Consumables"
ITEM.description = "A tinned can, it slushes when you shake it."

ITEM.functions.Eat = {
	OnRun = function(item)
		local client = item.player

		client:SetHealth(math.Clamp(client:Health() + 5, 0, client:GetMaxHealth()))

		client:GetCharacter():AddBoost(item.uniqueID, "end", 1)
		-- duration: 600
		error("TODO: Implement removing the boost after the duration is over.")
	end
}
