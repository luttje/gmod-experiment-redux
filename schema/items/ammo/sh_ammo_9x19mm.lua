local ITEM = ITEM

ITEM.calibre = "9x19mm"
ITEM.name = Schema.ammo.GetCalibreName(ITEM.calibre)
ITEM.ammo = Schema.ammo.ConvertToAmmo(ITEM.calibre)
ITEM.price = 120
ITEM.model = "models/items/boxsrounds.mdl"
ITEM.ammoAmount = 15
ITEM.description = "A decently sized container with the calibre noted on the side."
