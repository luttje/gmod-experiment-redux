local ITEM = ITEM

ITEM.calibre = ".357 SIG"
ITEM.name = Schema.ammo.GetCalibreName(ITEM.calibre)
ITEM.ammo = Schema.ammo.ConvertToAmmo(ITEM.calibre)
ITEM.price = 65
ITEM.shipmentSize = 10
ITEM.model = "models/items/357ammobox.mdl"
ITEM.ammoAmount = 24
ITEM.description = "A container with a big calibre bullet image on the side."
ITEM.requiresGunsmith = true
