local ITEM = ITEM

ITEM.base = "base_armor_exoskeleton"
ITEM.price = 15000
ITEM.name = "Monolith Exoskeleton"
ITEM.description =
	"A Monolith™ branded exoskeleton. Provides you with great bullet resistance."
ITEM.replacement = "models/stalkertnb/exo_mono.mdl"
ITEM.attribBoosts = {
	["strength"] = 25,
}

ix.anim.SetModelClass(ITEM.replacement, "player")
