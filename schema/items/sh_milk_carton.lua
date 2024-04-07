local ITEM = ITEM

ITEM.name = "Milk Carton"
ITEM.price = 20
ITEM.model = "models/props_junk/garbage_milkcarton002a.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Consumables"
ITEM.description = "A carton filled with delicious milk."

ITEM.functions.Drink = {
	OnRun = function(item)
		local client = item.player

		client:SetHealth(math.Clamp(client:Health() + 5, 0, 100))

		client:GetCharacter():AddBoost(item.uniqueID, "end", 1)
		client:GetCharacter():AddBoost(item.uniqueID, "str", 1)
		-- duration: 600
		error("TODO: Implement removing the boost after the duration is over.")
	end
}
