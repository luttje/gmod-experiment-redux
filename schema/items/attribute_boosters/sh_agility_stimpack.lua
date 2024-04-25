local ITEM = ITEM

ITEM.name = "Agility Stimpack"
ITEM.price = 500
ITEM.model = "models/props_c17/trappropeller_lever.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Stimpacks"
ITEM.description = "A Stimpack branded stimulator promising to enhance the body. This stimpack temporarily enhances your agility by 15 points."
ITEM.attributeBoosts = {
	["agility"] = {
		amount = 15,
		duration = 3600
	}
}

function ITEM:OnRegistered()
	self.functions.Consume.name = "Inject"
end
