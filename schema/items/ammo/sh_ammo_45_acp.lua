local ITEM = ITEM

ITEM.calibre = ".45 ACP"
ITEM.name = Schema.ammo.GetCalibreName(ITEM.calibre)
ITEM.ammo = Schema.ammo.ConvertToAmmo(ITEM.calibre)
ITEM.price = 125
ITEM.model = "models/tacint/props_containers/supply_case-2.mdl"
ITEM.ammoAmount = 15
ITEM.description = "An average sized container with the calibre noted on the side"
