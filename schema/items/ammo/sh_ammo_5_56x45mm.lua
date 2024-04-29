local ITEM = ITEM

ITEM.calibre = "5.56x45mm"
ITEM.name = Schema.ammo.GetCalibreName(ITEM.calibre)
ITEM.ammo = Schema.ammo.ConvertToAmmo(ITEM.calibre)
ITEM.price = 565
ITEM.model = "models/items/boxmrounds.mdl"
ITEM.ammoAmount = 64
ITEM.description = "A large container with the calibre on the side."
ITEM.requiresGunsmith = true
