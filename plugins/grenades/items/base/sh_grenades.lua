local ITEM = ITEM

ITEM.base = "base_weapons"
ITEM.name = "Grenade"
ITEM.model = "models/items/grenadeammo.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.class = "exp_flare_grenade"
ITEM.weaponCategory = "grenade"
ITEM.isGrenade = true
ITEM.description = "A dirty tube of dust, is this supposed to be a grenade?"
ITEM.requiresExplosives = true

function ITEM:GetFilters()
	return {
		["Is a grenade"] = "checkbox"
	}
end
