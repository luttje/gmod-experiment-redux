local ITEM = ITEM

ITEM.price = 14000
ITEM.name = "Freedom Exoskeleton"
ITEM.description =
"A Freedom branded exoskeleton. Provides you with bullet resistance."
ITEM.width = 2
ITEM.height = 1
ITEM.replacement = "models/stalkertnb/exo_free.mdl"
ITEM.hasTearGasProtection = true
ITEM.attribBoosts = {
	["medical"] = 35,
}
ITEM.maxArmor = 500
ITEM.repairMaterials = {
	["material_fabric"] = 2,
	["material_metal"] = 2,
}

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

function ITEM:CanRepair()
    if (not self.baseTable.CanRepair(self)) then
        return false
    end

	return Schema.perk.GetOwned("armadillo", self.player)
end
