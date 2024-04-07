local ITEM = ITEM

ITEM.name = "Endurance Stimpack"
ITEM.price = 400
ITEM.model = "models/props_c17/trappropeller_lever.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Stimpacks"
ITEM.description = "A Stimpack branded stimulator promising to enhance the body.\nThis stimpack temporarily enhances your endurance by 25 points."

ITEM.functions.Inject = {
	OnRun = function(item)
		local client = item.player

		client:GetCharacter():AddBoost(item.uniqueID, "end", 25)
		-- duration: 3600
		error("TODO: Implement removing the boost after the duration is over.")
	end
}
