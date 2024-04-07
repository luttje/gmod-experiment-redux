local ITEM = ITEM

ITEM.calibre = "12 Gauge"
ITEM.name = Schema.ammo.GetCalibreName(ITEM.calibre)
ITEM.ammo = Schema.ammo.ConvertToAmmo(ITEM.calibre)
ITEM.price = 220
ITEM.model = "models/items/boxbuckshot.mdl"
ITEM.ammoAmount = 20
ITEM.description = "A box filled with 12 gauge buckshot shells."
ITEM.requiresGunsmith = true
