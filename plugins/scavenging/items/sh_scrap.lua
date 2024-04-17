local ITEM = ITEM

ITEM.base = "base_stackable"
ITEM.name = "Scrap"
ITEM.model = "models/gibs/metal_gib4.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.noBusiness = true
ITEM.description = "This is scrap, it can power Bolt Control Units."
ITEM.maxStacks = 8

function ITEM:GetFilters()
	return {
		["Is scrap"] = "checkbox"
	}
end
