local ITEM = ITEM

ITEM.base = "base_armor"
ITEM.name = "Exoskeleton"
ITEM.description = "An exoskeleton suit. Provides you with bullet resistance."
ITEM.replacement = "models/stalkertnb/exo_free.mdl"
ITEM.hasTearGasProtection = true
ITEM.attribBoosts = {
	-- ["medical"] = 35,
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
	-- walk = footstepSounds,
	run = footstepSounds,
}

function ITEM:CanRepair()
    if (not self.baseTable.CanRepair(self)) then
        return false
    end

	return Schema.perk.GetOwned("armadillo", self.player)
end
