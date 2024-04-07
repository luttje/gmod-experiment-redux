local ITEM = ITEM

ITEM.calibre = "5.7x28mm"
ITEM.name = Schema.ammo.GetCalibreName(ITEM.calibre)
ITEM.ammo = Schema.ammo.ConvertToAmmo(ITEM.calibre)
ITEM.price = 525
ITEM.model = "models/tacint/props_containers/supply_case-2.mdl"
ITEM.ammoAmount = 48
ITEM.description = "A decently sized container with the calibre on the side."
