local ITEM = ITEM

ITEM.calibre = ".357"
ITEM.name = Schema.ammo.GetCalibreName(ITEM.calibre)
ITEM.ammo = Schema.ammo.ConvertToAmmo(ITEM.calibre)
ITEM.price = 150
ITEM.model = "models/items/357ammo.mdl"
ITEM.ammoAmount = 24
ITEM.description = "A container with a big calibre bullet image on the side."
