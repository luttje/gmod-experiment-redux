local ITEM = ITEM

ITEM.price = 14000
ITEM.name = "Freedom Exoskeleton"
ITEM.description =
"A Freedom branded exoskeleton. Provides you with bullet resistance."
ITEM.maxArmor = 500
ITEM.hasTearGasProtection = true
ITEM.attribBoosts = {
	["medical"] = 35,
}
ITEM.width = 2
ITEM.height = 1
ITEM.replacement = "models/stalkertnb/exo_free.mdl"

local footstepSounds = {
	"npc/metropolice/gear1.wav",
	"npc/metropolice/gear2.wav",
	"npc/metropolice/gear3.wav",
	"npc/metropolice/gear4.wav",
	"npc/metropolice/gear5.wav",
	"npc/metropolice/gear6.wav",
}

ITEM.footstepSounds = {
	walk = footstepSounds,
	run = footstepSounds,
}

ix.anim.SetModelClass(ITEM.replacement, "player")
