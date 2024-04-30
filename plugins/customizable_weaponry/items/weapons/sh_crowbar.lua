local ITEM = ITEM

ITEM.name = "Crowbar"
ITEM.description = "A scratched up and dirty metal crowbar. Useful for breaking your way through blockages."
-- ITEM.price = 100
ITEM.model = "models/weapons/tacint_melee/w_crowbar.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Melee"
ITEM.weaponCategory = "melee"
ITEM.class = "tacrp_m_crowbar"
ITEM.noBusiness = true -- We give everyone a crowbar for free, so they can free themselves from prop blocks
ITEM.noDrop = true -- We don't want people to drop their crowbars

ITEM.isAttachment = true
ITEM.attachmentBone = "ValveBiped.Bip01_Spine"
ITEM.attachmentOffsetVector = Vector(15.2, -2.2, -5.3)
ITEM.attachmentOffsetAngles = Angle(-57, 12.2, 0.7)

ITEM.mergeIntoSwep = {
	MeleeRange = 64,
}

function ITEM:CanTransfer(oldInventory, newInventory)
    -- Only allow moving within the same inventory
    return newInventory == nil
end
