local ITEM = ITEM

ITEM.calibre = "16 Gauge"
ITEM.name = Schema.ammo.GetCalibreName(ITEM.calibre)
ITEM.ammo = Schema.ammo.ConvertToAmmo(ITEM.calibre)
ITEM.price = 55
ITEM.model = "models/items/boxbuckshot.mdl"
ITEM.ammoAmount = 20
ITEM.description = "A decently sized container with the calibre on the side."
ITEM.requiresGunsmith = true
