local ITEM = ITEM

ITEM.name = "Beer"
ITEM.price = 25
ITEM.model = "models/props_junk/garbage_glassbottle003a.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.attributes = {str = 2}
ITEM.description = "A glass bottle filled with liquid, it has a funny smell."

ITEM.functions.Drink = {
	OnRun = function(itemTable)
        local client = itemTable.player

        Schema.achievement.Progress(client, ACH_LIQUID_COURAGE)
		client:GetCharacter():AddBoost(itemTable.uniqueID, "str", 2)

		return true
	end,
}
