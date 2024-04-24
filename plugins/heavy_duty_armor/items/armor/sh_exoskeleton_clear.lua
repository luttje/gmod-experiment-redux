local ITEM = ITEM

ITEM.base = "base_armor_exoskeleton"
ITEM.price = 15000
ITEM.name = "Clear Exoskeleton"
ITEM.description =
	"A Clear™ branded exoskeleton. Provides you with great bullet resistance."
ITEM.replacement = "models/stalkertnb/exo_lone.mdl"
ITEM.attribBoosts = {
	["medical"] = 10,
	["dexterity"] = 10,
}
ITEM.requiresArmadillo = true

ix.anim.SetModelClass(ITEM.replacement, "player")
