local ITEM = ITEM

ITEM.name = "Running Shoes"
ITEM.price = 150
ITEM.model = "models/props_junk/shoe001a.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.useText = "Wear"
ITEM.description = "They look tattered and dirty."

ITEM.functions.Wear = {
	OnRun = function(item)
		local client = item.player
		client:GetCharacter():SetData("shoes", true)
	end
}
