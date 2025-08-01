local ITEM = ITEM

ITEM.calibre = "beanbag"
ITEM.name = Schema.ammo.GetCalibreName(ITEM.calibre)
ITEM.ammo = Schema.ammo.ConvertToAmmo(ITEM.calibre)
ITEM.price = 299
ITEM.shipmentSize = 10
ITEM.model = "models/weapons/tacint/ammoboxes/ammo_box-2.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.ammoAmount = 12
ITEM.description = "A sturdy container, filled with beanbag pellets."
ITEM.requiresGunsmith = true
