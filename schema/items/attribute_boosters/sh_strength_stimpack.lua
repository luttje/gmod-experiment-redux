local ITEM = ITEM

ITEM.name = "Strength Stimpack"
ITEM.price = 500
ITEM.model = "models/props_c17/trappropeller_lever.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Stimpacks"
ITEM.description = "A Stimpack branded stimulator promising to enhance the body. This stimpack temporarily enhances your strength by 15 points."
ITEM.attributeBoosts = {
	["strength"] = {
		amount = 15,
		duration = 3600
	}
}
