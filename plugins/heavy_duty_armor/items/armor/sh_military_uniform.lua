local ITEM = ITEM

ITEM.name = "Military Uniform"
ITEM.price = 950
ITEM.shipmentSize = 5
ITEM.description =
"A Military Uniform. Provides you with some bullet resistance."
ITEM.width = 2
ITEM.height = 1
ITEM.hasTearGasProtection = true
ITEM.replacement = "models/stalkertnb/beri_mili.mdl"
ITEM.maxArmor = 250
ITEM.repairMaterials = {
	["material_fabric"] = 4,
}
ITEM.attribBoosts = {
	["stamina"] = 10,
}
ITEM.requiresArmadillo = true

ix.anim.SetModelClass(ITEM.replacement, "player")
