local ITEM = ITEM

ITEM.base = "base_armor_exoskeleton"
ITEM.price = 14000
ITEM.name = "Freedom Exoskeleton"
ITEM.description =
	"A Freedom™ branded exoskeleton. Provides you with great bullet resistance."
ITEM.replacement = "models/stalkertnb/exo_free.mdl"
ITEM.attribBoosts = {
	["medical"] = 35,
}
ITEM.requiresArmadillo = true

ix.anim.SetModelClass(ITEM.replacement, "player")
