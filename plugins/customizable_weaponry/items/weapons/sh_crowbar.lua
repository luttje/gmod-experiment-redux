local ITEM = ITEM

ITEM.name = "Crowbar"
ITEM.description = "A scratched up and dirty metal crowbar."
ITEM.price = 100
ITEM.model = "models/weapons/tacint_melee/w_crowbar.mdl"
ITEM.width = 1
ITEM.height = 2
ITEM.category = "Melee"
ITEM.weaponCategory = "melee"
ITEM.class = "tacrp_m_crowbar"

ITEM.isAttachment = true
ITEM.attachmentBone = "ValveBiped.Bip01_Spine"
ITEM.attachmentOffsetAngles = Angle(200, 200, 0)
ITEM.attachmentOffsetVector = Vector(0, 5, 2)

ITEM.mergeIntoSwep = {
	MeleeRange = 64,
}
