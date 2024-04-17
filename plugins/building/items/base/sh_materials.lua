local ITEM = ITEM

ITEM.base = "base_stackable"
ITEM.name = "Raw Material"
ITEM.model = "models/gibs/metal_gib4.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.description = "Material that can be used to erect structures."
ITEM.noBusiness = true

function ITEM:GetFilters()
	return {
		["Is material"] = "checkbox"
	}
end
