local ITEM = ITEM

ITEM.calibre = "23x75mmR"
ITEM.name = Schema.ammo.GetCalibreName(ITEM.calibre)
ITEM.ammo = Schema.ammo.ConvertToAmmo(ITEM.calibre)
ITEM.price = 525 -- TODO: Set this value
ITEM.model = "models/tacint/props_containers/supply_case-2.mdl"
ITEM.ammoAmount = 20 -- TODO: Find out what this value should be
ITEM.description = "A decently sized container with the calibre on the side."
