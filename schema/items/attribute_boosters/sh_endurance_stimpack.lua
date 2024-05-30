local ITEM = ITEM

ITEM.name = "Endurance Stimpack"
ITEM.price = 125
ITEM.model = "models/props_c17/trappropeller_lever.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Stimpacks"
ITEM.description = "A stimulator promising to enhance the body. This stimpack temporarily enhances your endurance by 15 points."
ITEM.attributeBoosts = {
	["endurance"] = {
		amount = 15,
		duration = 3600
	}
}

function ITEM:OnRegistered()
	self.functions.Consume.name = "Inject"
end
