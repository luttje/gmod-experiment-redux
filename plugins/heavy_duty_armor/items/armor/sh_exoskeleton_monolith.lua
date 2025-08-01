local ITEM = ITEM

ITEM.base = "base_armor_exoskeleton"
ITEM.price = 1500
ITEM.shipmentSize = 5
ITEM.name = "Monolith Exoskeleton"
ITEM.description =
"A Monolith™ branded exoskeleton. Provides you with great bullet resistance."
ITEM.replacement = "models/stalkertnb/exo_mono.mdl"
ITEM.attribBoosts = {
	["strength"] = 25,
}
ITEM.requiresArmadillo = true

ix.anim.SetModelClass(ITEM.replacement, "player")
