local ITEM = ITEM

ITEM.calibre = "7.62x39mm"
ITEM.name = Schema.ammo.GetCalibreName(ITEM.calibre)
ITEM.ammo = Schema.ammo.ConvertToAmmo(ITEM.calibre)
ITEM.price = 275
ITEM.model = "models/weapons/tacint/ammoboxes/ammo_bag-1.mdl"
ITEM.ammoAmount = 20
ITEM.description = "A small bag filled with rounds of ammunition."
ITEM.requiresGunsmith = true
