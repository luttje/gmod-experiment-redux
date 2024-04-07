local ITEM = ITEM

ITEM.name = "Milk Jugs"
ITEM.price = 30
ITEM.model = "models/props_junk/garbage_milkcarton001a.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Consumables"
ITEM.description = "A jug filled with delicious milk."

ITEM.functions.Drink = {
	OnRun = function(item)
		local client = item.player

		client:SetHealth(math.Clamp(client:Health() + 10, 0, 100))

		client:GetCharacter():AddBoost(item.uniqueID, "end", 2)
		client:GetCharacter():AddBoost(item.uniqueID, "str", 2)
		-- duration: 600
		error("TODO: Implement removing the boost after the duration is over.")
	end
}
