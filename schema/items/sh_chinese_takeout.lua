local ITEM = ITEM

ITEM.name = "Chinese Takeout"
ITEM.price = 20
ITEM.model = "models/props_junk/garbage_takeoutcarton001a.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Consumables"
ITEM.description = "A takeout carton, it's filled with cold noodles."

ITEM.functions.Eat = {
	OnRun = function(item)
		local client = item.player

		client:SetHealth(math.Clamp(client:Health() + 10, 0, client:GetMaxHealth()))

		client:GetCharacter():AddBoost(item.uniqueID, "end", 2)
		-- duration: 600
		error("TODO: Implement removing the boost after the duration is over.")
	end
}
