local ITEM = ITEM

ITEM.calibre = "5.7x28mm"
ITEM.name = Schema.ammo.GetCalibreName(ITEM.calibre)
ITEM.ammo = Schema.ammo.ConvertToAmmo(ITEM.calibre)
ITEM.price = 99
ITEM.shipmentSize = 10
ITEM.model = "models/items/boxmrounds.mdl"
ITEM.ammoAmount = 48
ITEM.description = "A decently sized container with the calibre on the side."
ITEM.requiresGunsmith = true
