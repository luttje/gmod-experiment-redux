local ITEM = ITEM

ITEM.name = "Acrobatics Stimpack"
ITEM.price = 400
ITEM.model = "models/props_c17/trappropeller_lever.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Stimpacks"
ITEM.description = "A Stimpack branded stimulator promising to enhance the body. This stimpack temporarily enhances your acrobatics by 25 points."
ITEM.attributeBoosts = {
	["acrobatics"] = {
		amount = 25,
		duration = 3600
	}
}

function ITEM:OnRegistered()
	self.functions.Consume.name = "Inject"
end
