local ITEM = ITEM

ITEM.calibre = ".40 S&W"
ITEM.name = Schema.ammo.GetCalibreName(ITEM.calibre)
ITEM.ammo = Schema.ammo.ConvertToAmmo(ITEM.calibre)
ITEM.price = 120
ITEM.model = "models/items/boxsrounds.mdl"
ITEM.ammoAmount = 15
ITEM.description = "An average sized container with the calibre noted on the side"
