local ITEM = ITEM

ITEM.name = "Crowbar"
ITEM.description = "A scratched up and dirty metal crowbar. Useful for breaking things open."
ITEM.price = 100
ITEM.model = "models/weapons/tacint_melee/w_crowbar.mdl"
ITEM.width = 1
ITEM.height = 2
ITEM.category = "Melee"
ITEM.weaponCategory = "melee"
ITEM.class = "tacrp_m_crowbar"

ITEM.isAttachment = true
ITEM.attachmentBone = "ValveBiped.Bip01_Spine"
ITEM.attachmentOffsetVector = Vector(15.2, -2.2, -5.3)
ITEM.attachmentOffsetAngles = Angle(-57, 12.2, 0.7)

ITEM.mergeIntoSwep = {
	MeleeRange = 64,
}
