local ITEM = ITEM

ITEM.name = "Shovel"
ITEM.description = "An old army shovel, designed to quickly dig trenches. Works great as a crude melee weapon."
ITEM.price = 85
ITEM.shipmentSize = 5
ITEM.model = "models/weapons/tacint_melee/w_shovel.mdl"
ITEM.width = 1
ITEM.height = 2
ITEM.category = "Melee"
ITEM.weaponCategory = "melee"
ITEM.class = "tacrp_m_shovel"

ITEM.isAttachment = true
ITEM.attachmentBone = "ValveBiped.Bip01_Pelvis"
ITEM.attachmentOffsetAngles = Angle(0, 180, 87)
ITEM.attachmentOffsetVector = Vector(0, 0, -7.2)

ITEM.mergeIntoSwep = {
	MeleeRange = 64,
}
