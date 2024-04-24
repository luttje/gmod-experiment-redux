local ITEM = ITEM

ITEM.base = "base_armor_exoskeleton"
ITEM.price = 15000
ITEM.name = "Bandit Exoskeleton"
ITEM.description =
	"A Bandit™ branded exoskeleton. Provides you with great bullet resistance."
ITEM.replacement = "models/stalkertnb/cs2_goggles.mdl"
ITEM.attribBoosts = {
	["agility"] = 25,
}

ix.anim.SetModelClass(ITEM.replacement, "player")
